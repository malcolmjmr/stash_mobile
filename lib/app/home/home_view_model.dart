import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../models/workspace.dart';


final homeViewProvider = ChangeNotifierProvider<HomeViewModel>(
  (ref) => HomeViewModel(app: ref.watch(appProvider))
);


class HomeViewModel with ChangeNotifier {

  AppController app;

  HomeViewModel({required this.app}) {
    load();
  }

  load() async {
    _setLoading(true);
    workspaces = (await app.workspaceManager.getWorkspaces())
      .where((Workspace c) => c.isIncognito != true).toList();
    workspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    _setLoading(false);
  }

  List<Workspace> workspaces = [];

  bool isLoading = false;
  dynamic error;

  _setLoading(bool value){
    isLoading = value;
    notifyListeners();
  }

  String newWorkspaceTitle = '';
  String? newWorkspaceColor;

  createNewWorkspace (BuildContext buildContext, Workspace workspace) {
    //Workspace workspace = Workspace(title: newWorkspaceTitle, color: newWorkspaceColor);
    if (workspace.title == null || workspace.title!.isEmpty) return; // need to show error screen

    app.workspaceManager.saveWorkspace(workspace);
    app.setCurrentWorkspace(workspace);
    Navigator.pushNamed(buildContext, AppRoutes.workspace);
  }

  createNewTab(BuildContext buildContext) {
    // 
    app.setCurrentResource(null);
    Navigator.pushNamed(buildContext, AppRoutes.webView);
  }

  openWorkspace(BuildContext buildContext, Workspace workspace) {
    
    app.setCurrentWorkspace(workspace);
    Navigator.pushNamed(buildContext, AppRoutes.workspace);
  }


}
