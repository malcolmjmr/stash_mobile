
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../models/resource.dart';
import '../../models/workspace.dart';

final searchViewProvider = ChangeNotifierProvider<SearchViewModel>(
  (ref) => SearchViewModel(ref.read)
);


class SearchViewModel with ChangeNotifier {

  Reader read;
  late DataManager data;
  Workspace? workspace;

  SearchViewModel(this.read) {
    data = read(dataProvider);
  }

  load() {

    final currentWorkspaceId = read(workspaceProvider).state;
    workspaces = [];
    resources = [];
    suggestedResources = [];

    workspaces = [...data.workspaces.where((w) => w.deleted != true).toList()];
    workspaces.sort(sortWorkspaces);
    resources = [...data.resources];
    
    for (final workspace in workspaces) {
      workspaceMap[workspace.id] = workspace;
      resources.addAll(workspace.tabs.map((tab) { 
        tab.primaryWorkspace = workspace;
        return tab;
      }));
      if (workspace.tabs.length > 0 && currentWorkspaceId == null) {
        suggestedResources.add(workspace.tabs[min(workspace.tabs.length - 1, max(workspace.activeTabIndex ?? 0, 0))]);
      }
      
    }

    workspace = workspaceMap[currentWorkspaceId];
    print(currentWorkspaceId);
    if (workspace != null) { 
      suggestedResources = resources.where((r) => r.contexts.contains(workspace!.id)).toList();
      suggestedResources.sort(sortResources);
      visibleResources = suggestedResources;
    } else {
      visibleResources = resources;
    }
    

    resources.sort(sortResources);
    notifyListeners();

  }

  int sortResources(Resource a, Resource b) {

    if (workspace != null) {
      final workspaceComp = (a.contexts.contains(workspace!.id) ? 1 : 0)
        .compareTo(b.contexts.contains(workspace!.id) ? 1 : 0);
      if (workspaceComp != 0) return workspaceComp;
    }

    final visitedComp = (b.lastVisited ?? 0).compareTo(a.lastVisited ?? 0);
    if (visitedComp != 0) return visitedComp;

    final updatedComp = (b.updated ?? 0).compareTo(a.updated ?? 0);
    if (updatedComp != 0) return updatedComp;

    return (b.created ?? 0).compareTo(a.created ?? 0);
  }

  int sortWorkspaces(Workspace a, Workspace b) {
    return (b.updated ?? 0).compareTo(a.updated ?? 0);
  }

  Map<String, Workspace> workspaceMap = {};

  //TextEditingController controller = TextEditingController();

  List <Workspace> workspaces = [];
  List <Resource> resources = [];

  List<Workspace> visibleWorkspaces = [];
  List<Resource> visibleResources = [];
  List<Resource> suggestedResources = [];

  String searchString = '';
  updateSearchResults(String newSearchString) {
    searchString = newSearchString;
    final text = searchString.toLowerCase();
    
    visibleWorkspaces = workspaces.where((w) => w.title?.toLowerCase().contains(text) ?? false).toList();
    visibleWorkspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    visibleResources = resources.where((r) => text.isEmpty || (r.title?.toLowerCase().contains(text) ?? false)).toList();
    visibleResources.sort(sortResources);
    notifyListeners();
  }

  openResource(BuildContext context, Resource resource) {
    if (workspace != null && resource.contexts.contains(workspace!.id)) {
      Navigator.pop(context);
      
    } else {
      context.read(workspaceProvider).state = resource.primaryWorkspace?.id;
      Navigator.pushReplacementNamed(context, AppRoutes.workspace, 
          arguments: WorkspaceViewParams(
          workspaceId: resource.primaryWorkspace?.id, 
          parentId: workspace?.id,
          resourceToOpen: resource
        )
      );
    }
  }
}
