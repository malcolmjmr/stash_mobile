
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../constants/color_map.dart';
import '../../models/resource.dart';

final workspaceViewProvider = ChangeNotifierProvider<WorkspaceViewModel>((ref) {
  return WorkspaceViewModel(
      reader: ref.read);
});


class Views {
  static String tabs = 'tabs';
  static String recent = 'recent';
  static String folders = 'folders';
  static String queue = 'queue';
  static String highlights = 'highlights';
}

class WorkspaceViewModel extends ChangeNotifier {
  late AppController app;

  Reader reader;

  WorkspaceViewModel({required this.reader}) {
    app = reader(appProvider);
  }

  String get workspaceHexColor => colorMap[workspace.color ?? 'grey']!;

  setWorkspace(Workspace newWorkspace) async {
    workspace = newWorkspace;
    resources = await app.workspaceManager.db.getWorkspaceResources(app.userManager.currentUser, workspace.id);
    print('setting workspace');
    print(resources.map((r) => r.title));
    updateVisibleResources();
    print(visibleResources.map((r) => r.title));
  }

  Workspace workspace  = Workspace();
  List<Resource> resources = [];

  String view = Views.tabs;

  goBackToHome(BuildContext context) {
    app.setCurrentWorkspace(null);
    app.setCurrentResource(null);
    Navigator.pop(context);
  }

  List<Resource> visibleResources = [];

  String searchText = '';
  updateVisibleResources() {
    if (searchText.length > 0) {
      final text = searchText.toLowerCase();
      visibleResources = [...resources, ...workspace.tabs].where((r) {
        return ((r.title ?? '') + (r.url ?? '')).contains(text);
      }).toList();
    } else {
      if (view == Views.tabs) {
        visibleResources = workspace.tabs;
      } else if (view == Views.recent) {
        visibleResources = resources.where((r) => r.url != null).toList();
        visibleResources.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
      } else if (view == Views.folders) {
        visibleResources = resources.where((r) => r.url == null && r.parentId != workspace.folderId).toList();
      }
    }
    
    notifyListeners();
  }

  openResource(BuildContext context, Resource resource) {
    app.webManager.setResource(resource);
    Navigator.pushNamed(context, AppRoutes.webView);
  }


}


