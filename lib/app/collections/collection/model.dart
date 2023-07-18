import 'package:flutter/material.dart';
import 'package:stashmobile/app/collections/collection/filters/default_filters.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/routing/app_router.dart';
import 'package:stashmobile/services/firestore_database.dart';

import 'description/view.dart';
import 'members/view.dart';

class CollectionViewModel extends ChangeNotifier {
  BuildContext context;
  Collection collection;
  late AppController app;
  late FirestoreDatabase db;
  late User user;

  CollectionViewModel(this.context, this.collection) {
    app = context.read(appProvider);
    db = app.content.db;
    user = app.content.user;
    setFilter(app.content.getContentById(defaultFilters.first));
    //loadSubPages();
  }

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  List<Content> filteredList = [];
  setFilter(Content filterObject) {
    setIsLoading(true);
    filteredList = app.content.getContentWithQuery(query: filterObject.filter!);
    setIsLoading(false);
  }

  onTapContent(Content content) {
    app.viewModel.open(context, content);
    Navigator.of(context).pop();
  }

  onDoubleTapContent(Content content) {
    app.viewModel.openMainView(context, content);
    Navigator.of(context).pop();
  }

  late CollectionHomeSubPage subPage;
  setPage(CollectionHomeSubPage newSubPage) {
    subPage = newSubPage;
    notifyListeners();
  }

  late List<CollectionHomeSubPage> subPages;
  loadSubPages() {
    subPages = [
      CollectionHomeSubPage(
        icon: Icons.notifications,
        name: 'Updates',
        view: (context) => Container(),
        condition: () => false,
      ),
      CollectionHomeSubPage(
        icon: Icons.short_text_outlined,
        name: 'Description',
        view: (context) => CollectionDescriptionView(this),
      ),
      CollectionHomeSubPage(
        icon: Icons.category,
        name: 'Categories',
        view: (context) => Container(),
      ),
      CollectionHomeSubPage(
        icon: Icons.style,
        name: 'Tags',
        view: (context) => Container(),
      ),
      CollectionHomeSubPage(
        icon: Icons.people_alt_outlined,
        name: 'Members',
        view: (context) => CollectionMembersView(collection),
      ),
      CollectionHomeSubPage(
        icon: Icons.people_alt_outlined,
        name: 'Settings',
        view: (context) => Container(),
        condition: () => false,
      ),
    ];
    subPages.removeWhere((p) => p.condition?.call() == false);
    subPage = subPages.first;
  }

  bool get userIsOwner =>
      collection.owners == null || collection.owners!.contains(user.id);

  bool showSearch = false;
  openSearch() {
    Navigator.of(context).pushNamed(AppRoutes.search);
  }

  setShowSearch(bool value) {
    showSearch = value;
    notifyListeners();
  }

  openSettings() =>
      Navigator.of(context).pushNamed(AppRoutes.collectionSettings);

  openRoot() {
    app.viewModel.open(context, app.content.root);
    Navigator.of(context).pop();
  }

  List<Content> tags = [];

  loadTags() {
    tags = app.content.allContent.values
        .where((c) => c.type == ContentType.tag)
        .toList();
    tags.sort(
        (a, b) => a.tag!.instances.length.compareTo(b.tag!.instances.length));
  }

  openTag(Content tag) {
    app.viewModel.open(context, tag);
    Navigator.of(context).pop();
  }

  saveCollection() {
    if (collection.isPublic)
      db.setSharedCollection(collection);
    else
      db.setPrivateCollection(user.id, collection);
  }
}

// Updates (conditional)
// Description
// Categories
// Tags
// Members
// Settings (conditional)

class CollectionHomeSubPage {
  IconData icon;
  String name;
  Function(BuildContext context) view;
  bool Function()? condition;
  CollectionHomeSubPage({
    required this.icon,
    required this.name,
    required this.view,
    this.condition,
  });
}
