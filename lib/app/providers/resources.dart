

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/models/resource.dart';


import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';

final resourceProvider = ChangeNotifierProvider<ResourceManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user != null) {
    return ResourceManager(
      reader: ref.read,
      user: user,
      db: ref.watch(databaseProvider),
    );
  }
  throw UnimplementedError();
});

// final contentUpdateStreamProvider = StreamProvider<List<Content>>((ref) {
//   final user = ref.watch(sessionProvider).user;
//   final db = ref.watch(databaseProvider);
//   if (user != null && user.currentCollection != null) {
//     return db.getContentStream(user.id, user.currentCollection!);
//   } else {
//     return Stream.empty();
//   }
// });

enum ContentManagerMode { disk, cloud }

class ResourceManager extends ChangeNotifier {
  User user;
  FirestoreDatabase db;
  Reader reader;

  ResourceManager({
    required this.reader,
    required this.user,
    required this.db,
  }) {
    load();
  }




  bool isLoading = true;
  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  load() async {


    setLoading(false);
  }

  saveResource(Resource resource) {
    db.setResource(user.id, resource);
  }


}
