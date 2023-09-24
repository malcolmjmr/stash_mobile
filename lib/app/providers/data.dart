import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/tag.dart';

import '../../models/workspace.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';
import '../../services/firestore_database.dart';
import '../authentication/firebase_providers.dart';
import '../authentication/session_provider.dart';

final dataProvider = ChangeNotifierProvider<DataManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  final db = ref.watch(databaseProvider);
  if (user != null) {
    return DataManager(user: user, db: db);
  }
  throw UnimplementedError();
});

class DataManager extends ChangeNotifier {
  User user;
  FirestoreDatabase db;
  Map<String, Workspace> _workspaces = {};
  List<Workspace> get workspaces => _workspaces.values.toList();
  Map<String, Resource> _resources = {};
  List<Resource> get resources => _resources.values.toList();
  List<String?> loadedWorkspaces = [];
  Map<String, Domain> _domains = {};
  List<Domain> get domains => _domains.values.toList();
  Map<String, Set<Resource>> _tags = {};


  
  DataManager({required this.user, required this.db}) {
    _load();
  }

  bool _isLoaded = false;
  _load() async {
    await _getWorkspacesFromCloud();
    await _getRecentResources();
    await _getFavoriteResources();
    await _getDomains();
    _isLoaded = true;
    notifyListeners();
  }

  /*

    

  */


  List<Tag> get tags  {
    return _tags.entries
      .sorted((a, b) => b.value.length.compareTo(a.value.length))
      .map((e) => Tag(name: e.key, valueCount: e.value.length))
      .toList();
    
  }


  _getRecentResources() async {
    final aMonthAgo = DateTime.now().millisecondsSinceEpoch - (1000 * 60 * 60 * 24 * 30);
    final recentResources = await db.getResourcesByTime(user, aMonthAgo);
    for (final resource in recentResources) {
      if (_resources[resource.id] == null) {
        _resources[resource.id!] = resource;
        for (final tag in resource.tags) {
          if (_tags[tag] == null) _tags[tag] = Set();
          _tags[tag]!.add(resource);
        }

      }
    }
  }

  _getFavoriteResources() async {
    final favoriteResources = await db.getFavoriteResources(user);
    for (final resource in favoriteResources) {
      if (_resources[resource.id] == null) {
        _resources[resource.id!] = resource;
      }
    }
  }

  Workspace getWorkspace(String workspaceId) {
    return _workspaces[workspaceId]!;
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
    final workspaces = (await db.getUserWorkspaces(user)).where((w) => w.isIncognito != true).toList();
    for (final workspace in workspaces) {
      if (_workspaces[workspace.id] == null) {
        _workspaces[workspace.id] = workspace;
      }
    }
  }

  Future<List<Workspace>> getWorkspaces() async {
    if (workspaces.isEmpty) await _getWorkspacesFromCloud();
    return workspaces;
  }


  saveResource(Resource resource) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_resources[resource.id!] == null) {
      resource.created = now;
    }
    resource.updated = now;
    _resources[resource.id!] = resource;
    await db.setResource(user.id, resource);
  }

  deleteResource(Resource resource, {bool permanent = false}) async {
    _resources.remove(resource.id);
    if (permanent == true) {
      await db.deleteResource(user.id, resource.id!);
    } else {
      resource.deleted = DateTime.now().millisecondsSinceEpoch;
      await db.setResource(user.id, resource);
    }
  }


  saveWorkspace(Workspace workspace) async {
    
    workspace.updated = DateTime.now().millisecondsSinceEpoch;
    _workspaces[workspace.id] = workspace;
    await db.setUserWorkspace(user.id, workspace);
  }

  deleteWorkspace(Workspace workspace) async {
    _workspaces.remove(workspace.id);
    if (workspace.title == null) {
      await db.deleteWorkspace(user.id, workspace.id);
    } else {
      workspace.deleted = DateTime.now().millisecondsSinceEpoch;
      await db.setUserWorkspace(user.id, workspace);
    }
  }


   _getDomains() async  {
    List<Domain> domains = await db.getUserDomains(user);
    for (final domain in domains) {
      if (_domains[domain.url] == null) {
        _domains[domain.url] = domain;
      }
    }
  }
  
  saveDomain(Domain domain) async {
    _domains[domain.url] = domain;
    await db.setDomain(user.id, domain);
  }

  deleteDomain(String url) async {
    final domain = _domains[url];
    if (domain == null) return;
    await db.deleteDomain(user.id, domain.id!);
    _domains.remove(url);
  }




  

}