import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../models/workspace.dart';


final homeViewProvider = ChangeNotifierProvider<HomeViewModel>(
  (ref) => HomeViewModel(ref.read)
);


class HomeViewModel with ChangeNotifier {

  Reader read;
  late DataManager data;

  HomeViewModel(this.read) {
    data = read(dataProvider);
    load();
  }

  load() async {
    _setLoading(true);
    await refreshWorkspaces();
    _setLoading(false);
  }

  refreshWorkspaces() async {
    workspaces = (await data.getWorkspaces())
      .where((Workspace c) => c.isIncognito != true).toList();
    workspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    favorites = workspaces.where((w) => w.isFavorite == true).toList();
  }

  List<Workspace> workspaces = [];
  List<Workspace> favorites = [];

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
    
    Navigator.pushNamed(buildContext, AppRoutes.webView);
  }

  openWorkspace(BuildContext buildContext, Workspace workspace) {
    // add setting 
    read(workspaceProvider).state = workspace.id;
    Navigator.pushNamed(buildContext, AppRoutes.workspace);
  }

  toggleWorkspacePinned(Workspace workspace) async {
    workspace.isFavorite = !(workspace.isFavorite == true);
    await data.saveWorkspace(workspace);
    await refreshWorkspaces();
    notifyListeners();
  }

  deleteWorkspace(BuildContext context, Workspace workspace) {
    data.deleteWorkspace(workspace);
    workspaces = data.workspaces.where((Workspace c) => c.isIncognito != true).toList();
    workspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));;
    Navigator.pop(context);
    notifyListeners();
  }

  openLooseTabs(BuildContext context) {

  }

  openPublicWorkspaces(BuildContext context) {
    
  }
}
