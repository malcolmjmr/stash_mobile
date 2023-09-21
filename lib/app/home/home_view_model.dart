import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../models/workspace.dart';


final homeViewProvider = ChangeNotifierProvider<HomeViewModel>(
  (ref) => HomeViewModel(ref.read, ref.watch(dataProvider))
);


class HomeViewModel with ChangeNotifier {

  Reader read;
  DataManager data;

  HomeViewModel(this.read, this.data) {
    data = read(dataProvider);
    load();
  }

  load() async {
    _setLoading(true);
    await refreshWorkspaces();
  }

  refreshWorkspaces() async {
    workspaces = data.workspaces
      .where((Workspace c) => c.isIncognito != true  && c.deleted == null).toList();
    workspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    recentSpaces = workspaces.sublist(0, min(5, workspaces.length));
    favorites = workspaces.where((w) => w.isFavorite == true && w.contexts.isEmpty).toList();
    _setLoading(false);
  }

  List<Workspace> workspaces = [];
  List<Workspace> favorites = [];
  List<Workspace> recentSpaces = [];


  bool isLoading = false;
  dynamic error;

  _setLoading(bool value){
    isLoading = value;
    notifyListeners();
  }

  String newWorkspaceTitle = '';
  String? newWorkspaceColor;

  bool showAllSpaces = true;
  setShowAllSpaces(value) {
    showAllSpaces = value;
    notifyListeners();
  }

  bool showFavoriteSpaces = true;
  toggleShowFavorites() {
    showFavoriteSpaces = !showFavoriteSpaces;
    notifyListeners();
  }



  createNewWorkspace (BuildContext buildContext, Workspace workspace) {
    //Workspace workspace = Workspace(title: newWorkspaceTitle, color: newWorkspaceColor);
    if (workspace.title == null || workspace.title!.isEmpty) return; // need to show error screen
    data.saveWorkspace(workspace);
    read(workspaceProvider).state = workspace.id;
    Navigator.pushNamed(buildContext, AppRoutes.workspace);
  }

  createNewTab(BuildContext buildContext) {
    Navigator.pushNamed(
      buildContext, 
      AppRoutes.workspace,
    );
  }

  openWorkspace(BuildContext buildContext, Workspace workspace) {
    buildContext.read(workspaceProvider).state = workspace.id;
    Navigator.pushNamed(buildContext, AppRoutes.workspace, arguments: WorkspaceViewParams(workspaceId: workspace.id));
  }

  toggleWorkspacePinned(Workspace workspace) async {
    workspace.isFavorite = !(workspace.isFavorite == true);
    print('workspace is favorite');
    print(workspace.isFavorite);
    await data.saveWorkspace(workspace);
    await refreshWorkspaces();
    notifyListeners();
  }

  deleteWorkspace(BuildContext context, Workspace workspace) {
    data.deleteWorkspace(workspace);
    refreshWorkspaces();
    Navigator.pop(context);
  }

  openLooseTabs(BuildContext context) {

  }

  openPublicWorkspaces(BuildContext context) {
    
  }
}
