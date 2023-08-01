

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/context.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';
import '../../services/firestore_database.dart';
import '../authentication/firebase_providers.dart';
import '../authentication/session_provider.dart';

final contextProvider = ChangeNotifierProvider<ContextManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null) {
    return ContextManager(user: user, db: db);
  }
  throw UnimplementedError();
});

class ContextManager extends ChangeNotifier {
  User user;
  FirestoreDatabase db;
  List<Context> contexts = [];
  List<Resource> resources = [];
  ContextManager({required this.user, required this.db}) {
    loadActiveContext();  
  }

  Context? get currentContext => contexts.firstWhereOrNull(
      (context) => context.id == user.currentContext);

  bool loading = true;
  loadActiveContext() async {
    if (user.currentContext != null) {
      loadContext(user.currentContext!);
    }
    loading = false;
    notifyListeners();
  }

  loadContext(String contextId) async {
    resources = await db.getContextResources(user, contextId);
  }

  createNewContext() {

  }

  saveContext(Context context) async {

  }

  setUserCollection(Context newCollection) async {
    user.currentContext = newCollection.id;
    await db.saveUser(user);
    notifyListeners();
  }

  

}
