
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../models/resource.dart';
import '../../models/workspace.dart';

final searchViewProvider = ChangeNotifierProvider<SearchViewModel>(
  (ref) => SearchViewModel(ref.read)
);


class SearchViewModel with ChangeNotifier {

  Reader read;
  late DataManager data;
  WorkspaceViewModel? workspaceModel;

  SearchViewModel(this.read) {
    data = read(dataProvider);
  }

  load() {


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
      if (workspace.tabs.length > 0 && workspaceModel == null) {
        suggestedResources.add(workspace.tabs[min(workspace.tabs.length - 1, max(workspace.activeTabIndex ?? 0, 0))]);
      }
      
    }

    if (workspaceModel != null) { 
      suggestedResources = resources.where((r) => r.contexts.contains(workspaceModel!.workspace.id)).toList();
      suggestedResources.sort(sortResources);
      visibleResources = suggestedResources;
    } else {
      visibleResources = resources;
    }
    
    resources.sort(sortResources);
    //notifyListeners();

  }

  int sortResources(Resource a, Resource b) {

    final matchingTagsComp = b.matchingTags.length.compareTo(a.matchingTags.length);
    if (matchingTagsComp != 0) return matchingTagsComp;

    if (workspaceModel != null) {
      final workspaceComp = (a.contexts.contains(workspaceModel!.workspace.id) ? 1 : 0)
        .compareTo(b.contexts.contains(workspaceModel!.workspace.id) ? 1 : 0);
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

  List<Tag> selectedTags = [];
  List<Tag> visibleTags = [];
  List<Tag> allTags = [];


  initBeforeNavigation({WorkspaceViewModel? workspace, List<Tag>? tags, String searchText = ''}) {
    workspaceModel = workspace;
    if (tags != null) {
      selectedTags = tags;
    }
    load();
    updateSearchResults(searchText);
  }

  String searchString = '';
  updateSearchResults(String newSearchString) {
    searchString = newSearchString;
    final text = searchString.toLowerCase();
    if (selectedTags.isEmpty) {
      visibleWorkspaces = workspaces
        .where((w) => w.title?.toLowerCase().contains(text) ?? false)
        .toList();
      visibleWorkspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    } else {
      visibleWorkspaces = [];
    }

    visibleTags = [...selectedTags];

    Map<String, int> tagCounts = {};

    
    visibleResources = resources.where((resource) {
      final matchesText = text.isEmpty || (resource.title?.toLowerCase().contains(text) ?? false);
      bool matchesTags = selectedTags.isEmpty || false;
      resource.matchingTags = [];
      for (final selectedTag in selectedTags) {
        final selectedTagPrefix = selectedTag.name.substring(0, 3);
        for (final resourceTag in resource.tags) {
          final foundMatch = resourceTag.startsWith(selectedTagPrefix);
          if (foundMatch) {
            if (!matchesTags) {
              matchesTags = true;
              for (final tag in resource.tags) {
                if (tagCounts[tag] == null) tagCounts[tag] = 0;
                tagCounts[tag] = tagCounts[tag]! + 1;
              }
            }
            resource.matchingTags.add(selectedTag);
          }
        }
      }
      return matchesText && matchesTags;
    }).toList();
    visibleResources.sort(sortResources);
    visibleTags = [...tagCounts.entries
      .map((e) => Tag(
        name: e.key, 
        valueCount: tagCounts[e.key]!, 
        isSelected: selectedTags.firstWhereOrNull((t) => t.name == e.key) != null))
      .sorted((a,b) {
        final selectedComp = (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0);
        if (selectedComp != 0) return selectedComp;
        return b.valueCount.compareTo(a.valueCount);
      })
      .toList()
    ];

    notifyListeners();
  }

  openResource(BuildContext context, Resource resource) {
    if (workspaceModel != null && resource.contexts.contains(workspaceModel!.workspace.id)) {
      Navigator.pop(context);
      workspaceModel!.openResource(context, resource);
    } else {
      Workspace? workspace = resource.primaryWorkspace;
      if (workspace == null && resource.contexts.isNotEmpty) {
        workspace = data.getWorkspace(resource.contexts.first);
      }

      context.read(workspaceProvider).state = workspace?.id;


      Navigator.pushNamed(context, AppRoutes.workspace, 
          arguments: WorkspaceViewParams(
          workspaceId: workspace?.id, 
          resourceToOpen: resource
        )
      );
    }
  }

  toggleTagSelection(Tag tag) {
    final index = selectedTags.indexWhere((t) => t.name == tag.name);
    if (index > -1) {
      selectedTags.removeAt(index);
    } else {
      selectedTags.add(tag);
    }
    updateSearchResults(searchString);
  }
}
