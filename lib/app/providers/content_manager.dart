import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/filter/default_filters.dart';
import 'package:stashmobile/app/providers/collections.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/links.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';
import 'package:stashmobile/models/content/updates.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';

final contentProvider = ChangeNotifierProvider<ContentManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user != null) {
    return ContentManager(
      reader: ref.read,
      collectionManager: ref.watch(collectionProvider),
      user: user,
      db: ref.watch(databaseProvider),
      mode: ContentManagerMode.cloud,
    );
  }
  throw UnimplementedError();
});

final contentUpdateStreamProvider = StreamProvider<List<Content>>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null && user.currentCollection != null) {
    return db.getContentStream(user.id, user.currentCollection!);
  } else {
    return Stream.empty();
  }
});

enum ContentManagerMode { disk, cloud }

class ContentManager extends ChangeNotifier {
  User user;
  CollectionManager collectionManager;
  FirestoreDatabase db;
  ContentManagerMode mode;
  Reader reader;

  ContentManager({
    required this.reader,
    required this.user,
    required this.collectionManager,
    required this.db,
    this.mode = ContentManagerMode.cloud,
  }) {
    load();
  }

  late Content root;
  late Content dailyPage;

  late Collection collection;
  bool collectionIsShared = false;

  Map<String, Content> allContent = Map();

  Map<String, Content> publicPosts = Map();
  loadPublicPosts() async {
    final List<Content> allPosts = await db.getPublicPosts();
    final followingIds = user.following.map((s) => s.userId);
    final relevantContent = allPosts.where(
        (c) => c.createdBy == user.id || followingIds.contains(c.createdBy));
    publicPosts =
        Map.fromIterable(relevantContent, key: (c) => c.id, value: (c) => c);
  }

  List<Content> filteredPosts = [];
  getPublicPosts({FilterFields? filter}) {
    final allPosts = publicPosts.values;
    print('Post count: ${publicPosts.length}');
    filteredPosts = filter != null
        ? allPosts.where(filter.criteriaAreSatisfied).toList()
        : allPosts.toList();
    return filteredPosts;
  }

  bool isLoading = true;
  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  load() async {
    if (collectionManager.currentCollection == null) return;
    collection = collectionManager.currentCollection!;
    collectionIsShared = collection.contributors != null;

    List<Content> results = [];

    if (collectionIsShared) {
      print('getting shared collection');
      results = await db.getAllContentFromSharedCollection(collection.id);
    } else {
      results =
          await db.getAllContentFromPrivateCollection(user.id, collection.id);
    }
    allContent = Map.fromIterable(results, key: (c) => c.id, value: (c) => c);

    await checkForRoot();
    await checkForDefaultFilters();
    await checkForDailyPage();

    setLoading(false);
  }

  checkForRoot() async {
    final rootExists = allContent.containsKey(collection.root);
    if (rootExists)
      root = allContent[collection.root]!;
    else
      await createRoot();
  }

  createRoot() async {
    root = Content(
      name: 'My Root',
      type: ContentType.root,
      links: ContentLinks(forward: []),
      isNew: false,
    );

    Content gettingStarted = Content(
      name: 'Getting Started',
      links: ContentLinks(back: [root.id]),
      isNew: false,
    );
    await saveContent(gettingStarted);

    Content history = Content(
      name: 'History',
      links: ContentLinks(back: [root.id]),
      isNew: false,
    );
    history.id = 'History';
    await saveContent(history);

    root.links!.forward!.addAll([gettingStarted.id, history.id]);
    await saveContent(root);

    collection.root = root.id;

    if (collectionIsShared) {
      await db.setSharedCollection(collection);
    } else {
      await db.setPrivateCollection(user.id, collection);
    }
  }

  checkForDefaultFilters() {
    final isFilter = (content) => content.type == ContentType.filter;
    final missingDefaultFilters =
        allContent.values.where(isFilter).length < defaultFilters.length;
    if (missingDefaultFilters) createDefaultFilters();
  }

  createDefaultFilters() => defaultFilters.forEach((filter) async {
        filter.id = filter.name!;
        await saveContent(filter);
      });

  checkForDailyPage() async {
    final now = DateTime.now();
    Content? searchResult = allContent.values.firstWhereOrNull((content) {
      final isDailyPage = content.type == ContentType.dailyPage;

      final created = DateTime.fromMillisecondsSinceEpoch(content.created);
      final isFromToday = created.year == now.year &&
          created.month == now.month &&
          created.day == now.day;

      return (isDailyPage && isFromToday);
    });
    if (searchResult == null) {
      dailyPage = Content(type: ContentType.dailyPage);
      await saveContent(dailyPage);
    } else {
      dailyPage = searchResult;
    }
  }

  Stream get updateStream => db.getCollectionUpdateStream(
        collection,
        DateTime.now().millisecondsSinceEpoch,
      );

  List<Content> get recentContent {
    final aMonthAgo =
        DateTime.now().subtract(Duration(days: 30)).microsecondsSinceEpoch;
    List<Content> results = allContent.values
        .where((c) =>
            (c.visits == null && c.created > aMonthAgo) ||
            (c.visits?.lastVisited ?? 0) > aMonthAgo)
        .toList();
    results.sort((a, b) =>
        (a.visits?.lastVisited ?? 0).compareTo(b.visits?.lastVisited ?? 0));
    return results;
  }

  List<Content> searchContent(String text) {
    return allContent.values.where((content) {
      return content.title.toLowerCase().contains(text.toLowerCase());
    }).toList();
  }

  List<Content> getContentWithQuery(
      {String searchText = '', required FilterFields query}) {
    List<Content> results = allContent.values
        .where((content) =>
            query.criteriaAreSatisfied(content) &&
            content.toJson().toString().toLowerCase().contains(searchText))
        .toList();

    results.sort(query.sortContent);
    return results;
  }

  saveContent(Content content,
      {bool updated = true, bool saveToDb = true}) async {
    print('Saving content:\n$content');
    allContent[content.id] = content;

    if (content.isIncognito || !saveToDb) return;
    if (updated) addContentUpdate(content);

    if (collectionIsShared) {
      db.setSharedContent(
        collection.id,
        content,
      );
    } else {
      await db.setPrivateContent(
        user.id,
        collection.id,
        content,
      );
    }
  }

  addContentUpdate(Content content) {
    final updateTime = DateTime.now().millisecondsSinceEpoch;
    if (content.updates == null) {
      content.updates = ContentUpdates();
    }
    final isSharedCollection =
        collectionManager.currentCollection!.contributors != null;
    if (isSharedCollection) {
      if (content.updates!.all == null) content.updates!.all = [];
      content.updates!.all!
          .add(UserUpdate(user: user.id, updateTime: updateTime));
    }
    content.updates!.last = updateTime;
  }

  deleteContent(Content content) async {
    print('deleting content');
    // remove links
    if (content.links != null) {
      if (content.links!.forward != null) {
        content.links!.forward!.forEach((linkedContentId) async {
          final linkedContent = allContent[linkedContentId];
          if (linkedContent != null) {
            linkedContent.links!.back!.remove(content.id);
            await saveContent(linkedContent);
          }
        });
      } else if (content.links!.back != null) {
        content.links!.back!.forEach((linkedContentId) async {
          final linkedContent = allContent[linkedContentId];
          if (linkedContent != null) {
            linkedContent.links!.forward!.remove(content.id);
            await saveContent(linkedContent);
          }
        });
      }
    }

    if (content.type == ContentType.tag) {
      content.tag!.instances.forEach((linkedContentId) async {
        final linkedContent = allContent[linkedContentId];
        if (linkedContent != null) {
          linkedContent.tags!.values.remove(content.id);
          await saveContent(linkedContent);
        }
      });
    }

    allContent.remove(content.id);
    await db.deleteContent(
        user.id, collectionManager.currentCollection!.id, content);
  }

  Future<Content> addLinkedContent(
      {required Content parent,
      ContentType type = ContentType.note,
      Content? child,
      BuildContext? context,
      bool saveToDb = true}) async {
    if (child == null) {
      child = Content(
        type: type,
        links: ContentLinks(back: [parent.id]),
        editName: true,
      );
    } else {
      if (child.links == null) child.links = ContentLinks();
      child.links!.addBackLinkId(parent.id);
    }

    child.isIncognito = parent.isIncognito;
    await saveContent(child, saveToDb: saveToDb);
    if (parent.links == null) parent.links = ContentLinks();
    parent.links!.addForwardLinkId(child.id);
    await saveContent(parent, saveToDb: saveToDb);
    return child;
  }

  removeLinkedContent({
    required Content parent,
    required Content child,
    BuildContext? context,
  }) async {
    child.links!.back!.remove(parent.id);
    await saveContent(child);
    parent.links!.forward!.remove(child.id);
    await saveContent(parent);
  }

  shareContent(Content content) async {
    print('sharing content: $content');
    content.createdBy = user.id;
    await db.postContent(content);
  }

  Content getContentById(String id) => allContent[id]!;

  List<Content> getContentByIds(List<String> ids) => ids
      .map((id) => allContent[id] ?? Content(type: ContentType.empty))
      .where((content) => content.type != ContentType.empty)
      .toList();

  Content? getContentByUrl(String url) =>
      allContent.values.firstWhereOrNull((content) => content.url == url);
}
