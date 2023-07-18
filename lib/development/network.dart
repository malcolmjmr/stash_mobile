import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/collection/category.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore.dart';
import 'package:stashmobile/services/firestore_path.dart';
import 'package:stashmobile/services/random_generator.dart';
import 'package:recase/recase.dart';

final testNetworkProvider = Provider((ref) => TestNetwork());

class TestNetwork {
  final db = FirestoreService.instance;
  final primaryUserId = '6732042f8c90';
  TestNetwork();

  Map<String, User> users = Map();
  Map<String, Category> categories = Map();
  Map<String, Collection> collections = Map();

  createNetwork({
    int userCount = 100,
    int categoryCount = 20,
    int collectionCount = 5,
  }) async {
    await createUsers(count: userCount);
    await createCollections(count: collectionCount);
    await createCategories(count: categoryCount);
    //await saveNetwork();
  }

  fetchUsers() async {
    users.addAll(Map.fromIterable(
      await db.collection(
        path: FirestorePath.users,
        builder: (id, json) => User.fromDatabase(id, json),
      ),
      key: (user) => user.id,
      value: (user) => user,
    ));
    users.removeWhere((key, value) => key == primaryUserId);
  }

  createUsers({int count = 20}) async {
    print('creating users');
    users.addAll(Map.fromIterable(
      await RandomGenerator.multipleUsers(count: count),
      key: (user) => user.id,
      value: (user) => user,
    ));
    for (User user in users.values)
      if (users.length > 1) followOtherUsers(user);
  }

  followOtherUsers(User user, {double maxFollowers = 0.5}) {
    final networkSize = users.length;
    final numberOfUsersExposedTo = max(Random().nextInt(networkSize), 1);
    final numberOfUsersFollowing = min(Random().nextInt(numberOfUsersExposedTo),
        (maxFollowers * networkSize).round());
    List<User> following = users.values.toList()..shuffle();
    following.removeWhere((u) => u.id == user.id);
    following = following.sublist(0, numberOfUsersExposedTo);
    following.sort((a, b) => b.followers.length.compareTo(a.followers.length));
    following = following.sublist(0, numberOfUsersFollowing);
    user.following =
        following.map((otherUser) => UserSubscription(otherUser.id)).toList();
    user.following
        .forEach((userSub) => users[userSub.userId]!.followers.add(user.id));
  }

  deleteUsers({bool fromDb = false}) async {
    if (fromDb) await fetchUsers();

    for (User user in users.values)
      await db.deleteData(path: FirestorePath.user(userId: user.id));
    users.clear();
  }

  createCollections({int count = 10}) async {
    print('creating collections');
    final List<String> iconUrls =
        await RandomGenerator().imageUrls(count: count);
    final List<String> descriptions =
        await RandomGenerator().kanyeQuotes(count: count);

    final contributors = getRandomListOfUsers(max: (users.length / 5).round())
        .map((user) => user.id)
        .toList();
    final subscribers = getRandomListOfUsers(max: users.length)
        .where((user) => !contributors.contains(user.id))
        .map((user) => user.id)
        .toList();

    for (int i = 0; i < count; i++) {
      Collection collection = Collection(
        name: createNameFromDescription(descriptions[i]),
        description: descriptions[i],
        iconUrl: iconUrls[i],
        createdBy: users.values.elementAt(Random().nextInt(users.length)).id,
        contributors: contributors,
        subscribers: subscribers,
      );
      collections[collection.id] = collection;
    }
  }

  deleteCollections({bool fromDb = false}) async {
    collections.clear();
    if (fromDb) await db.deleteCollection(path: FirestorePath.collections);
  }

  String createNameFromDescription(String description) {
    final wordsSortedByLength = description.replaceAll('.', '').split(' ')
      ..sort((a, b) => b.length.compareTo(a.length));
    if (wordsSortedByLength.length > 1)
      return wordsSortedByLength.sublist(0, 2).join(' ').titleCase;
    else
      return wordsSortedByLength.join(' ').titleCase;
  }

  List<User> getRandomListOfUsers({int max = 10}) => users.values.toList()
    ..shuffle()
    ..sublist(0, Random().nextInt(max));

  createCategories({int count = 25}) async {
    final randomText =
        await RandomGenerator().text(wordLength: 1000, type: 'gibberish');
    List<String> categoryNames =
        randomText.replaceAll('.', '').split(' ').toSet().toList();
    categoryNames.removeWhere((element) => element.length <= 5);
    categoryNames = categoryNames.sublist(0, count);

    categories = Map.fromIterable(categoryNames,
        key: (name) => name, value: (name) => Category(name: name));

    for (Category category in categories.values) {
      category.collections = collections.values
          .where((collection) => 2 > Random().nextInt(10))
          .map((category) => category.id)
          .toList();

      category.collections.forEach((collectionId) {
        if (collections[collectionId]!.categories == null)
          collections[collectionId]!.categories = [];
        collections[collectionId]!.categories!.add(category.name);
      });
    }
  }

  deleteCategories({bool fromDB = false}) async {
    categories.clear();
    if (fromDB) await db.deleteData(path: FirestorePath.categories);
  }

  saveNetwork() async {
    print('saving network...');

    print('psyche');
  }

  saveUsers() async {
    final usersToSave = users.values;
    await db.setBatch(
        paths: usersToSave
            .map((user) => FirestorePath.user(userId: user.id))
            .toList(),
        documents: usersToSave.map((user) => user.toJson()).toList());
  }

  saveCollections() async {
    final collectionsToSave = collections.values;
    await db.setBatch(
        paths: collectionsToSave
            .map((collection) =>
                FirestorePath.sharedCollection(collectionId: collection.id))
            .toList(),
        documents: collectionsToSave
            .map((collection) => collection.toJson())
            .toList());
  }

  saveCategories() async {
    final categoriesToSave = categories.values;
    await db.setBatch(
        paths: categoriesToSave
            .map(
                (category) => FirestorePath.category(categoryId: category.name))
            .toList(),
        documents:
            categoriesToSave.map((category) => category.toJson()).toList());
  }

  simulateDailyActivity() {
    createUserPosts();
    createUserActivity();
  }

  Map<String, Content> publicPosts = Map();
  fetchPublicPosts() async => publicPosts.addAll(
        Map.fromIterable(
          await db.collection(
            path: FirestorePath.publicPosts,
            builder: (id, json) => Content.fromDatabase(id, json),
          ),
        ),
      );

  createUserPosts() async {
    for (User user in getRandomListOfUsers(max: users.length)) {
      List<Content> highlights = await RandomGenerator()
          .hypothesisAnnotations(count: Random().nextInt(20));
      await db.setBatch(
        paths: highlights
            .map((Content highlight) =>
                FirestorePath.publicPost(postId: highlight.id))
            .toList(),
        documents: highlights.map((highlight) {
          highlight.createdBy = user.id;
          return highlight.toJson();
        }).toList(),
      );
    }
  }

  deletePublicPosts() async =>
      await db.deleteCollection(path: FirestorePath.publicPosts);

  createUserActivity() {
    // openContent();
    // addContent();
    // tagContent();
    // rateContent();
  }
}
