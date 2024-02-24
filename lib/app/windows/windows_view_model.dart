/*

  
*/

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
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

  }

  openWorkspace(Workspace? workspace, {Resource? resource, Domain? domain, bool isIncognito = false}) {
    final showHome = read(showHomeProvider);
    print('opening workspace');
    print(showHome.state);
    if (showHome.state) {
      read(showHomeProvider).state = false;
    }

    final index = workspaces.indexWhere((wv) => wv.model.workspace.id == workspace?.id);
    if (index > -1) {
      activeWindowIndex = index;
    } else {
       workspaces = [...workspaces,
        WorkspaceView(
          model: WorkspaceViewModel(
            params: WorkspaceViewParams(
              workspaceId: workspace?.id,
              isIncognito: isIncognito,
              resourceToOpen: resource
            )
          ),
        )
      ];
      activeWindowIndex = workspaces.length - 1;
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
}
  