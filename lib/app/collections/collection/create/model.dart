import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/random_generator.dart';

class CollectionCreateViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  Collection collection = Collection(name: '');
  CollectionCreateViewModel(this.context) {
    app = context.read(appProvider);
    loadContacts();
    loadImages();
  }

  /* Header */
  cancel() => Navigator.of(context).pop();
  bool isLoading = false;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  done() async {
    setIsLoading(true);
    await app.collections.saveNewCollection(collection);
    Navigator.of(context).pop();
  }

  /* Name */
  onNameChanged(String value) {
    collection.name = value;
  }

  onNameSubmitted(String value) {
    collection.name = value;
  }

  /* Icon */

  List<String> imageUrls = [];
  bool imageUrlsAreLoading = true;
  loadImages() async {
    imageUrls = await RandomGenerator().imageUrls(count: 100);
    imageUrls = imageUrls.reversed.toList();
    imageUrlsAreLoading = false;
    notifyListeners();
  }

  updateIconUrl(String imageUrl) {
    collection.iconUrl = imageUrl;
    notifyListeners();
  }

  /* Members */

  List<User> contacts = [];
  bool contactsAreLoading = true;
  loadContacts() {
    contacts = app.users.contacts;
    contactsAreLoading = false;
    notifyListeners();
  }

  toggleMember(User user) {
    if (collection.contributors == null) collection.contributors = [];

    final memberIndex = collection.contributors!.indexOf(user.id);
    if (memberIndex < 0) {
      collection.contributors!.add(user.id);
    } else {
      collection.contributors!.removeAt(memberIndex);
    }
    notifyListeners();
  }
}
