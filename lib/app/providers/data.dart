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
        workspaceResources = resources.where((r) => r.contexts.contains(workspaceId)).toList();
      } else {
        workspaceResources = await db.getWorkspaceResources(user, workspaceId);
        resources.addAll(workspaceResources);
        loadedWorkspaces.add(workspaceId);
      }
    }
    
    
    return workspaceResources;
  }


  _getWorkspacesFromCloud() async  {
    workspaces = await db.getUserWorkspaces(user);
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

  deleteResource(Resource resource) async {
    await db.deleteResource(user.id, resource.id!);
    resources.removeWhere((r) => r.id == resource.id);
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
    await db.deleteWorkspace(user.id, workspace.id);
    workspaces.removeWhere((w) => w.id == workspace.id);
  }

  

}