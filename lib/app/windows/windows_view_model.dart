/*

  
*/

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/main.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/models/workspace.dart';

final windowsProvider = ChangeNotifierProvider<WindowsViewModel>((ref) {
  final data = ref.watch(dataProvider);
  return WindowsViewModel(data: data, read: ref.read);
});


class WindowsViewModel extends ChangeNotifier {

  List <WorkspaceView> workspaces = [];

  Reader read;
  PageController pageController = PageController();

  DataManager data;
  int activeWindowIndex = 0;

 

  WindowsViewModel({
    required this.data,
    required this.read,
  }) {
    workspaces = [ 
      WorkspaceView(
        
        model: WorkspaceViewModel(dataManager: data)
      )
    ];
  }

  WorkspaceView get activeWindow  => workspaces[activeWindowIndex];

  openWorkspace(Workspace? workspace, {Resource? resource, Domain? domain, bool isIncognito = false}) {
    final showHome = read(showHomeProvider);
    print('opening workspace');

    if (showHome.state) {
      read(showHomeProvider).state = false;
    }

    bool creatingWorkspace = false;
    if (workspace == null) {
      workspace = workspaces
        .firstWhereOrNull((w) => w.model.isNewSpace)?.model.workspace;
      creatingWorkspace = true;
    }


    final index = workspaces.indexWhere((wv) => wv.model.workspaceIsSet && wv.model.workspace.id == workspace?.id);
    if (index > -1) {
      activeWindowIndex = index;
      if (creatingWorkspace) {
        workspaces.add(
          WorkspaceView(model: WorkspaceViewModel(dataManager: data))
        );
      }
      
    } else {
      print('opening existing space');
      final index = activeWindowIndex > 1 
        ? workspaces.length > activeWindowIndex 
          ? activeWindowIndex + 1
          : activeWindowIndex
        : 0;
      final wv = WorkspaceView(
        model: WorkspaceViewModel(
          params: WorkspaceViewParams(
            workspace: workspace,
            isIncognito: isIncognito,
            resourceToOpen: resource
          )
        ),
      );
      //workspaces.insert(index, wv);
      workspaces = [
        ...workspaces.sublist(0, index),
        wv,
        ...workspaces.sublist(index, workspaces.length)
      ];
      
      activeWindowIndex = index;
    }
   
    pageController.jumpToPage(activeWindowIndex);
    notifyListeners();
  }

  closeWorkspace(Workspace workspace) {
    HapticFeedback.mediumImpact();
    pageController.jumpToPage(max(0, activeWindowIndex - 1));
    workspaces.removeWhere((wv) => wv.model.workspace.id == workspace.id );
    activeWindowIndex = workspaces.length - 1;
    notifyListeners();
  }

  closeAll() {
    HapticFeedback.mediumImpact();
    workspaces = [ 
        WorkspaceView(model: WorkspaceViewModel(dataManager: data))
      ];
    final showHome = read(showHomeProvider);
    if (showHome.state) {
      read(showHomeProvider).state = true;
    }
    notifyListeners();
  }

  onPageChanged(index) {
    activeWindowIndex = index;
    final activeTab = activeWindow.model.currentTab;
    // if(activeTab.model.isNewTab) {
    //   activeWindow.model.openTabEditModal();
    // }
  }

   bool isScrollable = false;

   setIsScrollable(bool value) {
    isScrollable = value;
    notifyListeners();
   }
}
  