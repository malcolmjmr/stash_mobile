

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/workspace.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';
import '../../services/firestore_database.dart';
import '../authentication/firebase_providers.dart';
import '../authentication/session_provider.dart';

final workspaceProvider = ChangeNotifierProvider<WorkspaceManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null) {
    return WorkspaceManager(user: user, db: db);
  }
  throw UnimplementedError();
});

class WorkspaceManager extends ChangeNotifier {
  User user;
  FirestoreDatabase db;
  List<Workspace> workspaces = [];
  List<Resource> resources = [];
  WorkspaceManager({required this.user, required this.db}) {
    loadActiveWorkspace();
   
  }

  Workspace? get currentWorkspace => workspaces.firstWhereOrNull(
      (workspace) => workspace.id == user.currentWorkspace);

  bool loading = true;
  loadActiveWorkspace() async {
    loading = false;
    notifyListeners();
  }

  loadWorkspace(String workspaceId) async {
    resources = await db.getWorkspaceResources(user, workspaceId);
  }

  refreshWorkspaces() async  {
    workspaces = await db.getUserWorkspaces(user);
  }

  Future<List<Workspace>> getWorkspaces() async {
    if (workspaces.isEmpty) await refreshWorkspaces();
    return workspaces;
  }



  saveWorkspace(Workspace workspace) async {

    Workspace? workspaceToUpdate = workspaces.firstWhereOrNull((w) => w.id == workspace.id);
    if (workspaceToUpdate == null) {
      workspaces.add(workspace);
    } else {
      workspaceToUpdate = workspace;
    }

    await db.setUserWorkspace(user.id, workspace);
  }

  deleteWorkspace(Workspace workspace) async {
    db.deleteWorkspace(user.id, workspace.id);
    workspaces.removeWhere((w) => w.id == workspace.id);
    //if (workspace.size > 0 )
    // need to delete save resourced 
  }

  setUserCollection(Workspace newCollection) async {
    user.currentWorkspace = newCollection.id;
    await db.saveUser(user);
    notifyListeners();
  }

  

}
