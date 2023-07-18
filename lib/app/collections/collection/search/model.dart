import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/collection/category.dart';
import 'package:stashmobile/models/collection/model.dart';

class CollectionSearchViewModel extends ChangeNotifier {
  BuildContext context;
  late CollectionManager collectionManager;
  CollectionSearchViewModel(this.context) {
    collectionManager = context.read(collectionProvider);
    loadCategories();
    //loadCollections();
  }

  TextEditingController textController = TextEditingController();
  bool userIsSearching = false;
  setUserIsSearching(bool value) {
    userIsSearching = value;
    notifyListeners();
  }

  onSearchOpen() async {
    await loadCollections();
    setUserIsSearching(true);
  }

  onSearchChange(String text) => search();
  onSearchSubmit(String text) => null;

  Category? category;
  setCategory(Category? value) {
    category = value;
    notifyListeners();
    loadCollectionsFromCategory();
  }

  List<Category> categories = [];
  bool categoriesAreLoading = true;
  loadCategories() async {
    categories = await collectionManager.db.getCategories();
    categories.sort((a, b) => b.children.length.compareTo(a.children.length));
    categoriesAreLoading = false;
    notifyListeners();
  }

  Map<String, Collection> allCollections = Map();
  bool collectionsAreLoading = false;
  setCollectionsAreLoading(bool value) {
    collectionsAreLoading = value;
    notifyListeners();
  }

  loadCollections() async {
    allCollections = Map.fromIterable(
        await collectionManager.db.getPublicCollections(),
        key: (collection) => collection.id,
        value: (collection) => collection);
  }

  List<Collection> collections = [];
  loadCollectionsFromCategory() async {
    setCollectionsAreLoading(true);
    if (allCollections.isEmpty) {
      collections = await collectionManager.db.getPublicCollections(
          queryBuilder: (query) =>
              query.where('categories', arrayContains: category!.name));
      collections.sort((a, b) =>
          (b.subscribers?.length ?? 0).compareTo(a.subscribers?.length ?? 0));
    } else {
      collections = allCollections.values
          .where((collection) =>
              collection.categories?.contains(category!) ?? false)
          .toList();
    }
    setCollectionsAreLoading(false);
  }

  List<Collection> searchResults = [];
  bool searchIsLoading = false;
  setSearchIsLoading(bool value) {
    searchIsLoading = value;
    notifyListeners();
  }

  search() {
    setSearchIsLoading(true);
    searchResults = allCollections.values
        .where((collection) => collection.name
            .toLowerCase()
            .contains(textController.text.toLowerCase()))
        .toList();
    setSearchIsLoading(false);
  }
}
