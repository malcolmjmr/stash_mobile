import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/workspace.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';
import '../../services/firestore_database.dart';
import '../authentication/firebase_providers.dart';
import '../authentication/session_provider.dart';

final dataProvider = Provider<DataManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null) {
    return DataManager(user: user, db: db);
  }
  throw UnimplementedError();
});

class DataManager {
  User user;
  FirestoreDatabase db;
  List<Workspace> workspaces = [];
  List<Resource> resources = [];
  List<String?> loadedWorkspaces = [];

  
  DataManager({required this.user, required this.db}) {

  }

  Workspace getWorkspace(String workspaceId) {
    return workspaces.firstWhere((w) => w.id == workspaceId);
  }

  getWorkspaceResources(String? workspaceId) async {
    List<Resource> workspaceResources = [];

    if (workspaceId == null) { // m
      if (loadedWorkspaces.contains(workspaceId)) {
        workspaceResources = resources.where((r) => r.contexts.isEmpty).toList();
      } else {
        workspaceResources = await db.getMiscResources(user);
        resources.addAll(workspaceResources);
        loadedWorkspaces.add(null);
      }
    } else {
      if (loadedWorkspaces.contains(workspaceId)) {
        print('getting workspace resource from memory');
        workspaceResources = resources.where((r) => r.contexts.contains(workspaceId)).toList();
      } else {
        print('getting workspace resource from server');
        workspaceResources = await db.getWorkspaceResources(user, workspaceId);
        resources.addAll(workspaceResources);
        loadedWorkspaces.add(workspaceId);

      }
    }
    
    
    return workspaceResources;
  }


  _getWorkspacesFromCloud() async  {
    workspaces = (await db.getUserWorkspaces(user)).where((w) => w.isIncognito != true).toList();
    Workspace miscWorkspace = Workspace.miscellaneous();
    final foundMiscWorkspace = workspaces.firstWhereOrNull((workspace) => miscWorkspace.id == workspace.id);
    if (foundMiscWorkspace == null) {
      workspaces.add(miscWorkspace);
    }
  }

  Future<List<Workspace>> getWorkspaces() async {
    if (workspaces.isEmpty) await _getWorkspacesFromCloud();
    return workspaces;
  }


  saveResource(Resource resource) async {
    Resource? resourceToUpdate = resources.firstWhereOrNull((w) => w.id == resource.id);
    if (resourceToUpdate == null) {
      resources.add(resource);
    } else {
      resourceToUpdate = resource;
    }

    await db.setResource(user.id, resource);
  }

  deleteResource(Resource resource, {bool permanent = false}) async {
    resources.removeWhere((r) => r.id == resource.id);
    if (permanent == true) {
      await db.deleteResource(user.id, resource.id!);
    } else {
      resource.deleted = DateTime.now().millisecondsSinceEpoch;
      await db.setResource(user.id, resource);
    }
  }


  saveWorkspace(Workspace workspace) async {

    Workspace? workspaceToUpdate = workspaces.firstWhereOrNull((w) => w.id == workspace.id);
    if (workspaceToUpdate == null) {
      workspaces.add(workspace);
    } else {
      workspaceToUpdate = workspace;
    }

    workspace.updated = DateTime.now().millisecondsSinceEpoch;

    await db.setUserWorkspace(user.id, workspace);
  }

  deleteWorkspace(Workspace workspace) async {
    workspace.deleted = DateTime.now().millisecondsSinceEpoch;
    await db.setUserWorkspace(user.id, workspace);
    workspaces.removeWhere((w) => w.id == workspace.id);
  }

  

}