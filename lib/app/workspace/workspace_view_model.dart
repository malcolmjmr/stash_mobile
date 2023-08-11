
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../constants/color_map.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';

final workspaceViewProvider = ChangeNotifierProvider<WorkspaceViewModel>((ref) {
  return WorkspaceViewModel(
      read: ref.read);
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

  Reader read;
  late User user;

  WorkspaceViewModel({required this.read}) {
    app = read(appProvider);
    user = app.userManager.currentUser;
  }

  String get workspaceHexColor => colorMap[workspace.color ?? 'grey']!;

  
  bool isLoading = true;

  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  setWorkspace(Workspace newWorkspace) async {
    setLoading(true);
    workspace = newWorkspace;
    allResources = await app.workspaceManager.db.getWorkspaceResources(app.userManager.currentUser, workspace.id);
    await fixData();
    processResources();
    //updateVisibleResources();
    setLoading(false);
  }

  fixData() async {
    List<String> urls = [];
    List<String> ids = [];
    List<Resource> resourcesToRemove = [];
    List<Resource> resourcesToUpdate = [];
    print(user.id);
    subWorkspaces = [];
    for (final resource in allResources)  {
      if (resource.url == null) {
        if (ids.contains(resource.id)) {
          //resourcesToRemove.add(resource);
        } else {
          
          
          if (resource.bookmarkId == workspace.folderId) {
            resourcesToRemove.add(resource);
            continue;
          }
          ids.add(resource.id!);
          print(resource.id);
          Workspace newWorkspace = Workspace(title: resource.title);
          newWorkspace.id = resource.id!;
          newWorkspace.contexts = [workspace.id];
          if (resource.parentId != null && resource.parentId != workspace.folderId) {
            newWorkspace.contexts.add(resource.parentId!);
          }
          app.workspaceManager.workspaces.add(newWorkspace);
          subWorkspaces.add(newWorkspace);
        }
      } else {
        if (urls.contains(resource.url)) {
          resourcesToRemove.add(resource);
        } else {
          urls.add(resource.url!);
        }

        if (resource.title!.startsWith('* ')) {
          resource.isQueued = true;
          resource.title = resource.title!.replaceFirst('* ', '');
          resourcesToUpdate.add(resource);
        }
      }
    }

    if (resourcesToRemove.isNotEmpty) {
      print('resource to remove');
      print(resourcesToRemove.length);
      for (final resource in resourcesToRemove) {
        //await app.workspaceManager.db.deleteResource(user.id, resource.id!);
      }
      //allResources.removeWhere((r) => resourcesToRemove.contains(r.id));
    }

    if (resourcesToUpdate.isNotEmpty) {
      print('resource to update');
      print(resourcesToUpdate.length);
      for (final resource in resourcesToUpdate) {
        await app.workspaceManager.db.setResource(user.id, resource);
      }
    }
  }

  processResources() {
    print('processing resources');
    print(allResources.length);
    tabs = workspace.tabs.map((t) {
      final savedResource = allResources.firstWhereOrNull((r) => r.url == t.url);
      t.isSaved = savedResource != null;
      return t;
    }).toList();

    queue = [];
    folders = [];
    resources = [];

    for (final resource in allResources) {
      if (resource.url == null) {
        //folders.add(resource);
      } else if (resource.isQueued == true) {
        queue.add(resource);
      } else if (resource.parentId == null) {
        resources.add(resource);
      }
    }

    for (final w in subWorkspaces) {
      final mainContext = w.contexts.lastOrNull;
      if (mainContext == workspace.id) {
        folders.add(w);
      }
    }
    print(subWorkspaces.map((w) => w.contexts));


  }

  Workspace workspace  = Workspace();
  List<Workspace> subWorkspaces = [];
  List<Resource> allResources = [];
  //List<Resource> folders = [];
  List<Workspace> folders = [];
  List<Resource> queue = [];
  List<Resource> resources = [];

  List<Resource> tabs = [];

  String view = Views.tabs;

  goBackToHome(BuildContext context) {
    // app.setCurrentWorkspace(null);
    // app.setCurrentResource(null);
    Navigator.pop(context);
  }

  List<Resource> visibleResources = [];

  String searchText = '';
  // updateVisibleResources() {
  //   if (searchText.length > 0) {
  //     final text = searchText.toLowerCase();
  //     visibleResources = [...resources, ...workspace.tabs].where((r) {
  //       return ((r.title ?? '') + (r.url ?? '')).contains(text);
  //     }).toList();
  //   } else {
  //     if (view == Views.tabs) {
  //       visibleResources = workspace.tabs;
  //     } else if (view == Views.recent) {
  //       visibleResources = resources.where((r) => r.url != null).toList();
  //       visibleResources.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
  //     } else if (view == Views.folders) {
  //       visibleResources = resources.where((r) => r.url == null && r.parentId != workspace.folderId).toList();
  //     }
  //   }
    
  //   notifyListeners();
  // }


  bool showTabs = true;
  toggleShowTabs() {
    showTabs = !showTabs;
    notifyListeners();
  }

  bool showFolders = true;
  toggleShowFolders() {
    showFolders = !showFolders;
    notifyListeners();
  }

  bool showQueue = true;
  toggleShowQueue() {
    showQueue = !showQueue;
    notifyListeners();
  }

  openTab(BuildContext context, Resource resource) {
    workspace.activeTabIndex = workspace.tabs.length - 1;
    // save workspace
    print('opening tab');
    read(webViewProvider).openWebView(context);
    notifyListeners();
  }

  openResource(BuildContext context, Resource resource) {
    resource.isSaved = true;
    tabs.add(resource);
    workspace.tabs = tabs;
    workspace.activeTabIndex = workspace.tabs.length - 1;
    // save workspace
    print('opening resource');
    read(webViewProvider).openWebView(context);
    notifyListeners();
  }

  removeTab(Resource resource) {
    workspace.tabs = workspace.tabs.where((r) => r.id != resource.id).toList();
    tabs = workspace.tabs;
    app.workspaceManager.saveWorkspace(workspace);
    notifyListeners();
  }

  stashTab(Resource resource) {
    workspace.tabs = workspace.tabs.where((r) => r.id != resource.id).toList();
    resource.isQueued = true;
    saveTab(resource);
    notifyListeners();
  }

  saveTab(Resource resource) {
    if (resource.contexts.isEmpty) {
      resource.contexts.add(workspace.id);
    }
    app.workspaceManager.db.setResource(user.id, resource);
    notifyListeners();
  }

  createNewFolder(BuildContext context, String title) {
    Workspace newFolder = Workspace(title: title);
    newFolder.contexts.add(workspace.id);
    app.workspaceManager.db.setUserWorkspace(user.id, newFolder);
    workspace = newFolder;
    processResources();
    notifyListeners();

  }

  createNewTab(BuildContext context) {
    Resource newTab = Resource(url: 'https://www.google.com');
    if(workspace.activeTabIndex != null && workspace.tabs.isNotEmpty) {
      final newIndex = workspace.activeTabIndex! + 1;
      workspace.tabs.insert(newIndex, newTab);
    } else {
      workspace.tabs.add(newTab);
      workspace.activeTabIndex = workspace.tabs.length - 1;
    }
    notifyListeners();
    read(webViewProvider).openWebView(context);
    //print(read(webViewProvider).controllers.values.map((InAppWebViewController c) async => await c.getUrl()));
  }

  updateTab(int tabIndex, Resource resource) {
    workspace.tabs[tabIndex] = resource;
    tabs = workspace.tabs;
    print(tabs);
    notifyListeners();
    // save workspace
  }

  deleteResource(Resource resource) {
    resources.removeWhere((r) => r.id == resource.id);
    //app.resourceManager.db.deleteResource(user.id, resource.id!);
    notifyListeners();
  }

  clearTabs() {
    workspace.tabs = [];
    tabs = workspace.tabs;
    notifyListeners();
  }

}


