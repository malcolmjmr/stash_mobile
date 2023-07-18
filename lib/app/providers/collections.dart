import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';
import 'package:collection/collection.dart';

final collectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  final user = ref.watch(sessionProvider).user;
  final database = ref.watch(databaseProvider);
  if (user != null) {
    return database.getCollectionsStream(user);
  } else {
    return Stream.empty();
  }
});

final collectionProvider = ChangeNotifierProvider<CollectionManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null) {
    return CollectionManager(user: user, db: db);
  }
  throw UnimplementedError();
});

class CollectionManager extends ChangeNotifier {
  User user;
  FirestoreDatabase db;
  CollectionManager({required this.user, required this.db}) {
    loadCollections();
  }

  Collection? get currentCollection => collections.firstWhereOrNull(
      (collection) => collection.id == user.currentCollection);

  bool loading = true;
  loadCollections() async {
    if (user.currentCollection == null) await createDefaultCollection();
    await getPersonalCollections();
    await getSharedCollections();
    loading = false;
    notifyListeners();
  }

  createDefaultCollection() async {
    Collection defaultCollection = Collection(name: 'My Collection');
    user.currentCollection = defaultCollection.id;
    await db.saveUser(user);
    await db.setPrivateCollection(user.id, defaultCollection);
  }

  saveNewCollection(Collection collection) async {
    final collectionIndex = collections
        .indexWhere((storedCollection) => storedCollection.id == collection.id);
    if (collectionIndex < 0) {
      collections.add(collection);
    } else {
      collections[collectionIndex] = collection;
    }

    if (collection.contributors == null &&
        collection.contributors!.isNotEmpty) {
      await db.setPrivateCollection(user.id, collection);
    } else {
      if (!collection.contributors!.contains(user.id))
        collection.contributors!.add(user.id);
      await db.setSharedCollection(collection);
    }
    setUserCollection(collection);
  }

  setUserCollection(Collection newCollection) async {
    user.currentCollection = newCollection.id;
    await db.saveUser(user);
    notifyListeners();
  }

  List<Collection> collections = [];
  getPersonalCollections() async =>
      collections.addAll(await db.getPrivateCollections(user));
  getSharedCollections() async =>
      collections.addAll(await db.getSharedCollections(user));
}
