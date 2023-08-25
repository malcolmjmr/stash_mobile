
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/user.dart';

import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../constants/color_map.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';


class Views {
  static String tabs = 'tabs';
  static String recent = 'recent';
  static String folders = 'folders';
  static String queue = 'queue';
  static String highlights = 'highlights';
}

class WorkspaceViewModel extends ChangeNotifier {
  late DataManager data;

  late User user;

  late Workspace workspace;
  Workspace? parentWorkspace;
  List<Workspace> subWorkspaces = [];
  List<Resource> allResources = [];
  //List<Resource> folders = [];
  List<Workspace> folders = [];
  List<Resource> queue = [];
  List<Resource> favorites = [];
  List<Resource> resources = [];

  List<TabView> tabs = [];

  

  String view = Views.tabs;
  PageController? tabPageController;

  BuildContext context;

  Function(Function()) setState;
  bool showWebView = false;
  bool showHorizontalTabs = false;

  WorkspaceViewParams? params;

  WorkspaceViewModel({
    required this.context, 
    this.params,
    required Function(Workspace) onLoaded, 
    required this.setState,
  }) {
    data = context.read(dataProvider);
    user = context.read(userProvider).state!; 
    loadWorkspace(onLoaded);
  
  }

  loadWorkspace(Function(Workspace) onLoaded) async {
    if (params?.workspaceId == Workspace.all().id) {
      workspace = Workspace.all();
    } else {
      workspace = params?.workspaceId != null ? await data.getWorkspace(params!.workspaceId!) : Workspace(); 
    }
    if (params?.parentId != null) parentWorkspace = await data.getWorkspace(params!.parentId!);
    if (workspace.title == null ) {
      workspace.tabs = [Resource(url: 'https://www.google.com/', title: 'New Tab')];
      showWebView = true;
    }

    if (workspace.activeTabIndex == null) {
      workspace.activeTabIndex = 0;
    }

    
    allResources =  await data.getWorkspaceResources(workspace.id);
    await fixData();
    processResources();

    loadTabs();

    //setLoading(false);


    onLoaded(workspace);
  }


  loadTabs() {

    bool lazyLoad = true;
    if (workspace.title  == null && workspace.tabs.length == 1) {
      lazyLoad = false;
    }
    tabs = workspace.tabs.map((tab) {
      return TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: tab,
        ), 
        lazyLoad: lazyLoad,
      );
    }).toList();

    //tabPageController.jumpToPage(workspace.activeTabIndex ?? 0);
  }

  String get workspaceHexColor => colorMap[workspace.color ?? 'grey']!;

  
  bool isLoading = true;


  fixData() async {
    List<String> urls = [];
    List<String> ids = [];
    List<Resource> resourcesToRemove = [];
    List<Resource> resourcesToUpdate = [];
    subWorkspaces = [];
    for (final resource in allResources)  {
      if (resource.url == null) {
        if (ids.contains(resource.id)) {
          resourcesToRemove.add(resource);
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
      
      
      for (final resource in resourcesToRemove) {
        //await app.workspaceManager.db.deleteResource(user.id, resource.id!);
      }
      allResources.removeWhere((r) => resourcesToRemove.contains(r.id));
    }

    if (resourcesToUpdate.isNotEmpty) {
      for (final resource in resourcesToUpdate) {
        await data.saveResource(resource);
      }
    }
  }

  processResources() async  {
    workspace.tabs = workspace.tabs.map((t) {
      Resource? savedResource = allResources.firstWhereOrNull((r) => r.url == t.url);
      if (savedResource != null) savedResource.isSaved = true;
      return savedResource != null ? savedResource : t;
    }).toList();



    queue = [];
    folders = (await data.getWorkspaces())
      .where((w) => w.contexts.contains(workspace.id))
      .toList();

    resources = [];

    // folders = workspace
    //   .contexts
    //   .map((workspaceId) => data.getWorkspace(workspaceId))
    //   .toList();
    
    

    for (final resource in allResources) {
      if (resource.url == null) {
        //folders.add(resource);
        if (resource.title == workspace.title) continue;
        Workspace folder = Workspace(title: resource.title);
        folder.contexts.add(workspace.id);
        folders.add(folder);
      } else if (resource.isQueued == true) {
        queue.add(resource);
      } else {
        resources.add(resource);
      }
    }

    resources.sort(sortResources);
    queue.sort(sortResources);

    for (final w in subWorkspaces) {
      final mainContext = w.contexts.lastOrNull;
      if (mainContext == workspace.id) {
        folders.add(w);
      }
    }

    folders.sort((a, b) => (a.updated ?? 0).compareTo(b.updated ?? 0));

  }

  int sortResources(Resource a, Resource b) {
    int comp = (a.lastVisited ?? 0).compareTo(b.lastVisited ?? 0);
    if (comp == 0) {
      comp = (a.updated ?? 0).compareTo(b.lastVisited ?? 0);
    }

    if (comp == 0) {
      comp = (a.created ?? 0).compareTo(b.created ?? 0);
    }

    return comp;
  }

 

  goBackToHome(BuildContext context) {
 
    Navigator.pop(context);
  }

  List<Resource> visibleResources = [];

  String searchText = '';

  bool showTabs = true;
  toggleShowTabs() {
    setState(() {
      showTabs = !showTabs;
    });
    
    
  }

  bool showFolders = true;
  toggleShowFolders() {
    setState(() {
      showFolders = !showFolders;
    });
    
  }

  bool showQueue = true;
  toggleShowQueue() {
    setState(() {
      showQueue = !showQueue;
    });
  }

  openTab(Resource resource) {

    final index = tabs.indexWhere((tab) => tab.model.resource.id == resource.id);
    if (index > -1) {
      workspace.activeTabIndex = index;
      final tabModel = tabs[index].model;
      if (!tabModel.loaded) {
        tabModel.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(tabModel.resource.url!)));
      }
    } else {
      if (resource.isQueued == true) {
        resource.isQueued = false;
        resource.isSaved = false;
        queue.removeWhere((r) => resource.id == r.id);
        data.deleteResource(resource);
      }
      tabs.add(TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: resource,
        ),
        lazyLoad: false));
      workspace.activeTabIndex = workspace.tabs.length;
    }
    
    if (workspace.title != null) updateWorkspaceTabs();
    setState(() {
      workspace.activeTabIndex;
      showWebView = true;
      resources;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  openResource(BuildContext context, Resource resource) {

    // check that resource isn't already in tabs
    setState(() {
      final index = workspace.tabs.indexWhere((r) => r.id == resource.id);
      if (index > -1) {
        workspace.activeTabIndex = index;
      } else {
        resource.isSaved = true;
        workspace.tabs.add(resource);
        if (workspace.title != null) data.saveWorkspace(workspace);
        tabs.add(
          TabView(
            model: TabViewModel(
              workspaceModel: this,
              initialResource: resource,
            ),
          )
        );
        workspace.activeTabIndex = workspace.tabs.length - 1;
      }

      showWebView = true;

    });
 
    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  onTabUpdated(TabViewModel model, InAppWebViewController controller, Uri? uri) async {
    // find resource
    
    print('tab updated');
    if (!model.loaded) model.loaded = true;
    // final int resourceIndex = tabs.indexWhere((tab) => tab.model.resource.id == model.resource.id);
    // Resource resource;
    // if (resourceIndex == -1) {
    //   print('could not find tab');
    //   return;
    // }
    // resource = tabs[resourceIndex].model.resource;
    final url = uri.toString();

    if (url != model.resource.url) {
      // update tab resouce (look for existing resource or create new resourc)
      model.resource = Resource(
        url: url,
        favIconUrl: await model.getFaviconUrl(controller),
        title: await controller.getTitle(),
      );

    } else {
      // update resource if favicon != null || title != null 
      //if (resource.favIconUrl == null) {
        final favIconUrl = await model.getFaviconUrl(controller);
        if (favIconUrl != null) {
          model.resource.favIconUrl = favIconUrl;
        }
      //}

      //if (resource.title == null) {
        final title = await controller.getTitle();
        if (title != null) {
          model.resource.title = title;
        }
      //}

      //if (resource.image == null) {
      //if (workspace.title == null) {
        final image = await controller.takeScreenshot();
        if (image != null) {
          model.resource.image = image;
        }
      //}
      //}
    }

    if (model.resource.url!.contains('search') && model.resource.isSearch != true) model.resource.isSearch = true;

    setState(() {
      workspace;
      model.resource;
      tabs;
    });
    
  }

  addTabFromNewWindow(Resource parent, int windowId) {
    print(' new window created');
    print(windowId);
    tabs.add(
      TabView(
        windowId: windowId,
        model: TabViewModel(workspaceModel: this, ),
        lazyLoad: false,
      )
    );

    setState(() {
      tabs;
      workspace.activeTabIndex = tabs.length - 1;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  updateTabFromUrlField(Resource resource, String url) async {
    
    TabView tab = tabs.firstWhere((t) => t.model.resource.id == resource.id);
    await tab.model.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));

  }

  updateTabResource({String? title, }) {

  }

  onPageChanged(int index) {

    workspace.activeTabIndex = index;
    bool newTabCreated = false;
    if (tabs.length == index) {
      tabs.add(TabView(
        model: TabViewModel(workspaceModel: this),
        lazyLoad: false)
      );
      newTabCreated = true;
    }

    
    final tabModel = tabs[index].model;
    if (!tabModel.loaded) {
      Timer(Duration(milliseconds: newTabCreated ? 300 : 0), () {
        tabModel.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(tabModel.resource.url!)));
      });
    }
  

    setState(() {
      workspace.activeTabIndex = index;
      tabs;
    });

  }

  removeTab(Resource resource) async {
    setState(() {
      final index = tabs.indexWhere((t) => t.model.resource.id == resource.id);
      final currentIndex = workspace.activeTabIndex!;
      workspace.activeTabIndex = currentIndex > 0 ? currentIndex - 1 : currentIndex;
      tabPageController?.jumpToPage(workspace.activeTabIndex!);
      tabs.removeAt(index);
      if (workspace.title != null) updateWorkspaceTabs();
    });

  }

  stashTab(Resource resource) {
    setState(() {
      final index = tabs.indexWhere((tab) => tab.model.resource.id == resource.id);
      tabs.removeAt(index);
      final currentIndex = workspace.activeTabIndex!;
      workspace.activeTabIndex = currentIndex > 0 ? currentIndex - 1 : currentIndex;
      tabPageController?.jumpToPage(workspace.activeTabIndex!);
      updateWorkspaceTabs();
      resource.isQueued = true;
      queue.add(resource);
      if (resource.contexts.isEmpty) {
        resource.contexts.add(workspace.id);
      }
      data.saveResource(resource);
      
    });
    
  }

  reloadTab(Resource? resource) {
    final tab = resource != null 
      ? tabs.firstWhereOrNull((tab) => tab.model.resource.id == resource.id)
      : tabs[workspace.activeTabIndex!];
    if (tab == null) return;
    tab.model.controller.reload();
  }

  updateWorkspaceTabs({bool save = true}) {
    workspace.tabs = tabs.map((t) => t.model.resource).toList();
    if (save) {
      workspace.updated = DateTime.now().millisecondsSinceEpoch;
      data.saveWorkspace(workspace);
    }
  }

  saveTab(Resource resource) {
    if (resource.contexts.isEmpty) {
      resource.contexts.add(workspace.id);
    }
    resources.add(resource);
    data.saveResource(resource);
    

    setState(() {
      resource.isSaved = true;
    });

  }

  saveSpace(Workspace workspaceInfo) {
    setState(() {
      workspace.title = workspaceInfo.title?.trim();
      workspace.color = workspaceInfo.color;
      updateWorkspaceTabs();
    });
  }

  createNewFolder(BuildContext context, String title) {
    Workspace newFolder = Workspace(title: title);
    newFolder.contexts.add(workspace.id);
    data.saveWorkspace(newFolder);
    //workspace = newFolder;
    processResources();
    Navigator.pushNamed(context, AppRoutes.workspace, 
      arguments: WorkspaceViewParams(
        workspaceId: newFolder.id, 
        parentId: workspace.id
      )
    );
  }

  createNewTab(BuildContext context) {
    
    // if(workspace.activeTabIndex != null && workspace.tabs.isNotEmpty) {
    //   print('inserting tab');
    //   workspace.activeTabIndex = workspace.activeTabIndex! + 1;
    //   final newIndex = workspace.activeTabIndex!;
    //   //workspace.tabs.insert(newIndex, newTab);
    //   tabs.insert(newIndex, 
    //     TabView(
    //       model: TabViewModel(workspaceModel: this),
    //       lazyLoad: false,
    //     )
    //   );
    // } else {
      //workspace.tabs.add(newTab);
      
      tabs.add(
        TabView(
          model: TabViewModel(workspaceModel: this),
          lazyLoad: false,
        )
      );
      workspace.activeTabIndex = tabs.length - 1;
    //}
    setState(() {
      tabs;
      workspace.activeTabIndex;
      showWebView = true;
    });
   
    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  createNewTabFromUrl(String url) {
    tabs.add(
      TabView(
        model: TabViewModel(workspaceModel: this, initialResource: Resource(url: url)),
        lazyLoad: false,
      )
    );
    workspace.activeTabIndex = tabs.length - 1;
    //}
    setState(() {
      tabs;
      workspace.activeTabIndex;
      
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  deleteResource(Resource resource) {
    setState(() {
      bool deletePermanently = false;
      if (resource.isQueued == true) {
        queue.removeWhere((r) => r.id == resource.id);
        deletePermanently = true;
      } else {
         resources.removeWhere((r) => r.id == resource.id);
      }
      data.deleteResource(resource, permanent: deletePermanently);
    });
  }

  clearTabs({bool createNewTab = false}) {

    
    setState(() {
      workspace.tabs = [];
      tabs = [];  

      if (createNewTab) {
        tabs.add(TabView(model: TabViewModel(workspaceModel: this), lazyLoad: false,));
        showWebView = true;
      }

    });
  }

  closeTab(Resource resource) {

      tabs.removeWhere((t) => t.model.resource.id == resource.id);
      if (workspace.activeTabIndex == tabs.length) {
        workspace.activeTabIndex == tabs.length - 1;
      }
      tabPageController?.jumpToPage(workspace.activeTabIndex!);
      updateWorkspaceTabs();

    setState(() {
      tabs;
      workspace.activeTabIndex;
    });
  }


  saveResource(Resource resource) {
    if (resource.isQueued == true) {
      queue.add(resource);
    } else {
      resources.add(resource);
    }
    resource.contexts = [workspace.id];
    data.saveResource(resource);

    setState(() {
      resources;
      queue;
    });

  }


  toggleTabView() {
    setState(() {
      showHorizontalTabs = !showHorizontalTabs;
    });

    if (showHorizontalTabs) {
      tabPageController = null;
    }
  }
  
}


