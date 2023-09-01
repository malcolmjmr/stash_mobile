

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class MoveToSpaceModel {

  
  BuildContext context;
  WorkspaceViewModel workspaceModel;
  Resource? selectedResource;
  List<Resource> resources = [];



  Function(Function()) setState;
  MoveToSpaceModel(this.context, this.setState, {required this.workspaceModel, this.selectedResource}) {
    if (selectedResource != null) {
      resources.add(selectedResource!);
    } else {
      resources = workspaceModel.selectedResources
        .map((resourceId) => workspaceModel.tabs.firstWhere((tab) =>  tab.model.resource.id == resourceId ).model.resource).toList();
    }
    data = context.read(dataProvider);
    load();
  }

  late DataManager data;

  
  List<Workspace> recentSpaces = [];
  List<Workspace> workspaceSpaces = [];

  List<Workspace> visibleSpaces = [];
  List<Workspace> visibleWorkspaceSpaces = [];

  bool isLoaded = false;
  load() async {

    final allSpaces = (await data.getWorkspaces()).where((s) => s.title != null && s.title!.isNotEmpty).toList();
    recentSpaces = allSpaces;
    recentSpaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    visibleSpaces = recentSpaces;

    setState(() {
      isLoaded = true;
    });
  }

  String searchText = '';


  updateSearchResults(String updatedSearchText) {
    setState(() {
    searchText = updatedSearchText;
    final text = searchText.toLowerCase();
    final filter = (Workspace f) => f.title?.toLowerCase().contains(text) ?? false;
      visibleSpaces = recentSpaces.where(filter).toList();
    });
  }

  moveToSpace(BuildContext context, { 
    required Workspace destinationSpace, 
    Function(Workspace)? callback
  }) async {
    workspaceModel.removeSelectedTabs();
    destinationSpace.tabs.addAll(resources);
    await data.saveWorkspace(destinationSpace);
    context.read(homeViewProvider).refreshWorkspaces();
    Navigator.pop(context);
    callback?.call(destinationSpace);
  }
  

}