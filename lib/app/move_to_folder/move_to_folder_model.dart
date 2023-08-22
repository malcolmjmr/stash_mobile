

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class MoveToFolderModel {

  
  BuildContext context;
  WorkspaceViewModel? workspaceModel;

  Function(Function()) setState;
  MoveToFolderModel(this.context, this.setState, {this.workspaceModel}) {
    data = context.read(dataProvider);
    load();
  }

  late DataManager data;

  
  List<Workspace> recentFolders = [];
  List<Workspace> workspaceFolders = [];

  List<Workspace> visibleRecentFolders = [];
  List<Workspace> visibleWorkspaceFolders = [];

  bool isLoaded = false;
  load() async {

    final allFolders = await data.getWorkspaces();

    if (workspaceModel != null) {
      workspaceFolders = allFolders.where((f) => f.contexts.contains(workspaceModel!.workspace.id)).toList();
      visibleWorkspaceFolders = workspaceFolders;
      recentFolders = allFolders.where((f) => f.contexts.contains(workspaceModel!.workspace.id)).toList();
      
    } else {
      recentFolders = allFolders;
    }

    visibleRecentFolders = recentFolders;

    recentFolders.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));

    setState(() {
      isLoaded = true;
    });
  }


  updateSearchResults(String searchString) {
    final text = searchString.toLowerCase();
    final filter = (Workspace f) => f.title!.toLowerCase().contains(text);

    setState(() {
      visibleRecentFolders = recentFolders.where(filter).toList();
      visibleWorkspaceFolders = workspaceFolders.where(filter).toList();
    });
  }

  moveToFolder(BuildContext context, { 
    Workspace? targetFolder, 
    Resource? targetResource, 
    required Workspace destinationFolder, 
    Function(Workspace)? callback
  }) async {

    print('moving folder');

    if (targetFolder != null) {
      targetFolder.contexts.add(destinationFolder.id);
      await data.saveWorkspace(targetFolder);
    }

    if (targetResource != null) {
      targetResource.contexts.add(destinationFolder.id);
      await data.saveResource(targetResource);
    }

    context.read(homeViewProvider).refreshWorkspaces();

    Navigator.pop(context);

    callback?.call(destinationFolder);
  }
  

  createFolder() {

  }

  

  

}