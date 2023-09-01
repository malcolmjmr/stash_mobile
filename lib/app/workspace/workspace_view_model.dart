
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/user.dart';
import 'package:stashmobile/app/providers/workspace.dart';

import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/web/text_selection_menu.dart';
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
    required this.setState,
  }) {
    data = context.read(dataProvider);
    user = context.read(userProvider).state!; 
    
    loadWorkspace();
  
  }

  loadWorkspace() async {
    if (params?.workspaceId == Workspace.all().id) {
      workspace = Workspace.all();
    } else {
      workspace = params?.workspaceId != null ? await data.getWorkspace(params!.workspaceId!) : Workspace(); 
    }

    //context.read(workspaceProvider).state = workspace.id;
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
    await processResources();

    loadTabs();

    //setLoading(false);

    setState(() {
      isLoading = false;
    });
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
      
      // print('resource to remove');
      // print(resourcesToRemove.length);
      // print(allResources.length);
      for (final resource in resourcesToRemove) {
        await data.deleteResource(resource, permanent: true);
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
        // if (resource.title == workspace.title) continue;
        // Workspace folder = Workspace(title: resource.title);
        // folder.contexts.add(workspace.id);
        // folders.add(folder);
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

    folders.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));

  }

  int sortResources(Resource a, Resource b) {
    int comp = (b.lastVisited ?? 0).compareTo(a.lastVisited ?? 0);
    if (comp == 0) {
      comp = (b.updated ?? 0).compareTo(a.lastVisited ?? 0);
    }

    if (comp == 0) {
      comp = (b.created ?? 0).compareTo(a.created ?? 0);
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

  bool showQueue = false;
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
        workspace.tabs.add(resource);
        if (workspace.title != null) data.saveWorkspace(workspace);
        tabs.add(
          TabView(
            lazyLoad: false,
            model: TabViewModel(
              workspaceModel: this,
              initialResource: resource,
            ),
          )
        );
        workspace.activeTabIndex = workspace.tabs.length - 1;
      }

      if (resource.isQueued == true) {
        resource.contexts = [];
        queue.removeWhere((r) => r.id == resource.id);
        data.deleteResource(resource, permanent: true);
      }

      showWebView = true;

    });
 
    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  List<String> selectedResources = [];
  /*
    - move 
    - save
    - close
  */

  toggleResourceSelection(Resource resource) {
    setState(() {
      final index = selectedResources.indexWhere((id) => id == resource.id);
      if (index > -1) {
        selectedResources.removeAt(index);
      } else {
        selectedResources.add(resource.id!);
      }
      HapticFeedback.mediumImpact();
    });
  }

  cancelTabSelection() { 
    setState(() {
      selectedResources = [];
    });
  }

  removeSelectedTabs() {
    setState(() {
      tabs.removeWhere((t) => selectedResources.contains(t.model.resource.id));
      workspace.activeTabIndex = 0;
      selectedResources = [];
    });

    updateWorkspaceTabs();
  }

  

  onTabUpdated(TabViewModel model, InAppWebViewController controller, Uri? uri, {bool tabLoaded = false}) async {

    if (tabLoaded) {
      print('tab finished loading');
    } else {
      print ('tab is loading');
    }
    if (!model.loaded) model.loaded = true;
    // final int resourceIndex = tabs.indexWhere((tab) => tab.model.resource.id == model.resource.id);
    // Resource resource;
    // if (resourceIndex == -1) {
    //   print('could not find tab');
    //   return;
    // }
    // resource = tabs[resourceIndex].model.resource;


    bool resourceUpdated = false;
    final url = uri.toString();
    print (url);
    print (model.resource.url);

    if (url != model.resource.url) {
      // Todo: check if resource is from queue

      final newfavIconUrl = await model.getFaviconUrl(controller);
      final newTitle = await controller.getTitle();

      model.resource = resources.firstWhereOrNull((r) => r.url == url) ?? Resource(
        url: url,
        favIconUrl: newfavIconUrl != model.resource.favIconUrl ? newfavIconUrl : null,
        title: newTitle != model.resource.title ? newTitle : null,
      );

    } else {
      // update resource if favicon != null || title != null 
      
        if (model.resource.favIconUrl == null) {
          final favIconUrl = await model.getFaviconUrl(controller);
          if (favIconUrl != null) {
            model.resource.favIconUrl = favIconUrl;
            resourceUpdated = true;
          }
        }
       

        if (model.resource.title == null) {
          final title = await controller.getTitle();
        
          if (title != null) {
            model.resource.title = title;
            resourceUpdated = true;
          }
        }

        print('tab metadata'); 
        print(await controller.getMetaTags());
    }

    if (tabLoaded) {

      if (workspace.title != null) {
         final now = DateTime.now().millisecondsSinceEpoch;
        if (model.resource.lastVisited == null || (now - model.resource.lastVisited!) > (1000 * 60 * 60 * 2) ) {
          resourceUpdated = true;
        }
        if (resourceUpdated && model.resource.isSaved) {
          model.resource.lastVisited = now;
          data.saveResource(model.resource);
          resources.sort(sortResources);
        }
        updateWorkspaceTabs();
      } else {
        final image = await controller.takeScreenshot();
        if (image != null) {
          model.resource.image = image;
        }
      }
    }

    if (model.resource.url!.contains('search') && model.resource.isSearch != true) model.resource.isSearch = true;

    print(model.resource);

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

  onPageChanged(int index, {bool newTabCreated = false }) {

    workspace.activeTabIndex = index;
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
      // final index = tabs.indexWhere((tab) => tab.model.resource.id == resource.id);
      // tabs.removeAt(index);

      tabs = tabs.where((tab) => tab.model.resource.id != resource.id).toList();
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
    setState(() {
      if (resource.contexts.isEmpty) {
        resource.contexts.add(workspace.id);
      }
      resources.add(resource);
      data.saveResource(resource);
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

  createNewTab({String? url, bool lazyload = false}) {
    TabView tab = TabView(
      model: TabViewModel(
        workspaceModel: this,
        initialResource: url != null ? Resource(url: url) : null,
      ),
      lazyLoad: lazyload,
    );
    setState(() {
      if(workspace.activeTabIndex != null && workspace.tabs.isNotEmpty) {
        workspace.activeTabIndex = workspace.activeTabIndex! + 1;
        tabs.insert(workspace.activeTabIndex!, tab);
      } else {
        tabs.add(tab);
        workspace.activeTabIndex = tabs.length - 1;
      }
      
      if (!showWebView) showWebView = true;
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
    setState(() {
      tabs = tabs.where((t) => t.model.resource.id != resource.id).toList();
      if (workspace.activeTabIndex == tabs.length) {
        workspace.activeTabIndex == tabs.length - 1;
      }
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);
    updateWorkspaceTabs();
  }
  
  closeSelectedTabs() {
    setState(() {
      tabs.removeWhere((t) => selectedResources.contains(t.model.resource.id));
      if (workspace.activeTabIndex == tabs.length) {
        workspace.activeTabIndex == tabs.length - 1;
      }
      tabPageController?.jumpToPage(workspace.activeTabIndex!);
      updateWorkspaceTabs();
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

  String? selectedText;
  bool showTextSelectionMenu = false;

  showTextSelectionModal(String text) {
    setState(() {
      selectedText = text;
      showTextSelectionMenu = true;
    });
  }


  searchSelectedText() {

    TabView currentTab = tabs[workspace.activeTabIndex!];
    currentTab.model.controller.clearFocus();
    setState(() {
      showTextSelectionMenu = false;
    });
    createNewTab(url: 'https://www.google.com/search?q=' + Uri.encodeComponent(selectedText!));
  }

  tagTabWithSelectedText() {
    setState(() {
      String tag = selectedText!.toLowerCase().trim();
      TabView currentTab = tabs[workspace.activeTabIndex!];
      Resource resource = currentTab.model.resource;
      final tagIndex = resource.tags.indexWhere((t) => t == tag);
      if (tagIndex > -1) {
        resource.tags.removeAt(tagIndex);
      } else {
        resource.tags.add(tag);
      }
      if (!resource.isSaved) {
        resource.contexts.add(workspace.id);
      } 
      data.saveResource(resource);
      currentTab.model.controller.clearFocus();
      showTextSelectionMenu = false;
    });
    

   
  }

  onTabContentClicked() {
    if (showTextSelectionMenu) {
      setState(() {
        showTextSelectionMenu = false;
      });
    }
  }

}


