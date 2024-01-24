
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/user.dart';
import 'package:stashmobile/app/providers/workspace.dart';

import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/web/text_selection_menu.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/tag.dart';
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

  bool hasQueue = false;
  bool hasHighlights = false;
  bool hasFavorites = false;
  bool hasDomains = false;
  bool hasTags = false;
  bool hasImages = false;

  ResourceView? resourceView;
  //List<Resource> folders = [];
  List<Workspace> folders = [];
  List<Resource> favorites = [];
  List<Tag> tags = [];
  List<Tag> selectedTags = [];
  List<Tag> visibleTags = [];
  List<Resource> visibleResources = [];
  List<Domain> domains = [];
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
      workspace = params?.workspaceId != null 
        ? await data.getWorkspace(params!.workspaceId!) 
        : Workspace(
            color: colorMap.keys.toList()[(new Random()).nextInt(9)], 
            isIncognito: params?.isIncognito
          ); 
    }

    //context.read(workspaceProvider).state = workspace.id;
    if (params?.parentId != null) parentWorkspace = await data.getWorkspace(params!.parentId!);


    
    allResources =  await data.getWorkspaceResources(workspace.id);
    await fixData();
    await loadTabs();
    await loadFolders();
    await refreshResources();
    await updateVisibleResources();

    setState(() {
      isLoading = false;
    });
  }

  

  loadTabs() {
    // check workspace params for new tab
    if (params?.resourceToOpen != null) {

      final index = workspace.tabs.indexWhere((t) => t.url == params!.resourceToOpen!.url);

      if (index > -1) {
        workspace.activeTabIndex = index;
      } else {
        workspace.tabs.add(params!.resourceToOpen!);
        workspace.activeTabIndex = workspace.tabs.length - 1;
      }
      workspace.showWebView = true;
    } else if (workspace.title == null) {
      workspace.tabs = [Resource(url: 'https://www.google.com/', title: 'New Tab')];
      workspace.showWebView = true;
    }

    if (workspace.activeTabIndex == null) {
      workspace.activeTabIndex = 0;
    }

    

    workspace.tabs = workspace.tabs.map((t) {
      Resource? savedResource = allResources.firstWhereOrNull((r) => r.url == t.url);
      return savedResource != null ? savedResource : t;
    }).toList();

    bool lazyLoad = true;
    if (workspace.title  == null && workspace.tabs.length == 1) {
      lazyLoad = false;
    }

    if (workspace.activeTabIndex! > workspace.tabs.length - 1) {
      workspace.activeTabIndex = workspace.tabs.length - 1;
    }

    if (workspace.activeTabIndex == -1) {
      workspace.activeTabIndex = 0;
    }

    final openedTab = workspace.showWebView ? workspace.tabs[workspace.activeTabIndex!] : null;

    tabs = workspace.tabs.map((tab) {
      final isOpenedTab = openedTab != null && openedTab.url == tab.url;
      return TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: tab,
        ), 
        lazyLoad: isOpenedTab ? false : lazyLoad,
        incognito: workspace.isIncognito ?? false,
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

        if (resource.title?.startsWith('* ') ?? false) {
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

  loadFolders() async {
    folders = data.workspaces
      .where((w) => w.contexts.contains(workspace.id))
      .toList();
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
    if (resourceView == ResourceView.important) {
      comp = b.rating.compareTo(a.rating);
    }
    if (comp == 0) {
      comp = (b.updated ?? b.created ?? 0).compareTo(a.updated ?? a.created ?? 0);
    }

    return comp;
  }

  refreshResources() {

    Map<String, Tag> tagMap = {};
    Map<String, Domain> domainMap = {};

    allResources.sort(sortResources);


    
    for (final resource in allResources) {
      if (resource.url == null) continue;

      if (resource.highlights.isNotEmpty && !hasHighlights) {
        hasHighlights = true;
      }

      if (resource.rating > 0 && !hasFavorites) {
        hasFavorites = true;
      }

      if (resource.isQueued == true && !hasQueue) {
        hasQueue = true;
      }

      final uri = Uri.parse(resource.url!);
      if (domainMap[uri.host] == null) domainMap[uri.host] = Domain(
        title: uri.host,
        url: 'https://' + uri.host
      );
      domainMap[uri.host]!.count += 1;
      if (!hasDomains && domainMap[uri.host]!.count == 2) {
        hasDomains = true;
      }

      if (resource.images.isNotEmpty && !hasImages) {
        hasImages = true;
      }


      if (resource.tags.isNotEmpty) {

        final lastViwed = resource.updated ?? resource.created ?? resource.lastVisited ?? 0;
        for (final tagName in resource.tags) {
          if (tagName == workspace.title) continue;
          Tag? tag = tagMap[tagName];
          if (tag == null) { 
            tag = Tag(
              name: tagName, 
              lastViewed: lastViwed,
              isSelected: selectedTags.contains(tag),
            );
          }
          if (tag.lastViewed < lastViwed) {
            tag.lastViewed = lastViwed;
          }
          tag.valueCount += 1;
          tagMap[tagName] = tag;
        }
      }
    }

    domains = domainMap.values.where((domain) {
      return domain.count > 1;
    }).toList();


    List<Tag> sortedTags = tagMap.entries.where((e) => e.value.valueCount > 1).map((e) => e.value).toList();
    sortedTags.sort((a, b) { 
      final selectionComp =(b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0);
      if (selectionComp == 0) {
        final valueCountComp = b.valueCount.compareTo(a.valueCount);
        if (valueCountComp == 0) {
          final viewComp = b.lastViewed.compareTo(a.lastViewed);
          return viewComp;
        } else {
          return valueCountComp;
        }
      } else {
        return selectionComp;
      }

    });
    tags = sortedTags;
    visibleTags = tags;
    
  }

 

  goBackToHome(BuildContext context) {
 
    Navigator.pop(context);
  }

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
    showQueue = !showQueue;
    selectedTags = [];
    updateVisibleResources();
  }

  

  toggleTagSelection(Tag selectedTag) {
    final index = selectedTags.indexWhere((t) => t.name == selectedTag.name);
    if (index > -1) {
      selectedTags.removeAt(index);
    } else {
      selectedTags.add(selectedTag);
    }
    updateVisibleResources();
  }

  updateVisibleResources() {
    setState(() {
      List<Resource> tempResources = []; ; 
      Map<String,Tag> tempTags = {}; 

      for (final resource in allResources) {
        bool matchesFilter = true;
        if (resourceView == ResourceView.queue) {

          if (resource.isQueued != true || resource.isSaved)
            matchesFilter = false;
          
        }
        if (resourceView == ResourceView.highlights && resource.highlights.isEmpty) {
          matchesFilter = false;
        }

        if (resourceView == null && resource.isQueued == true) {
          matchesFilter = false;
        }

        if (resourceView == ResourceView.important && resource.rating < 1) {
          matchesFilter = false;
        }

        if (resourceView == ResourceView.images && resource.images.isEmpty) {
          matchesFilter = false;
        }


        final tagFound = selectedTags.isEmpty || (selectedTags.firstWhereOrNull((t) => resource.tags.contains(t.name)) != null);
        if (tagFound && matchesFilter) {
          tempResources.add(resource);
          for (final tagName in resource.tags) {
            Tag? tag = tempTags[tagName];
            if (tag == null) {
              tag = Tag(name: tagName, lastViewed: resource.lastVisited ?? resource.updated ?? resource.created ?? 0);
            }
            tag.valueCount += 1;
            tempTags[tagName] = tag;
          }
        }
      }
      tempResources.sort(sortResources);
      visibleResources = tempResources;
      List<Tag> sortedTags = tempTags.values.toList();
      sortedTags.sort((a, b) => b.valueCount.compareTo(a.valueCount));
      visibleTags = sortedTags;
    });
  }

  TabView get currentTab => tabs[workspace.activeTabIndex!];

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
        allResources.removeWhere((r) => resource.id == r.id);
        data.deleteResource(resource, permanent: true);
      }
      tabs.add(TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: resource,
        ),
        incognito: workspace.isIncognito ?? false,
        lazyLoad: false));
      workspace.activeTabIndex = workspace.tabs.length;
    }
    
    updateWorkspaceTabs();
    
    setState(() {
      workspace.activeTabIndex;
      workspace.showWebView = true;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);

    updateVisibleResources();
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
            incognito: workspace.isIncognito ?? false,
            model: TabViewModel(
              workspaceModel: this,
              initialResource: resource,

            ),
          )
        );
        workspace.activeTabIndex = workspace.tabs.length - 1;
      }

      if (resource.isQueued == true) {
        deleteResource(resource);
      }

      workspace.showWebView = true;

    });
 
    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  List<String> selectedResources = [];

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

    if (tabLoaded) checkTabForSearch(model, controller, uri);

    bool resourceUpdated = false;
    final url = uri.toString();

    if (url != model.resource.url) {
      // Todo: check if resource is from queue

      final newfavIconUrl = await model.getFaviconUrl(controller);
      final newTitle = await controller.getTitle();
      model.resource = allResources.firstWhereOrNull((r) => r.url == url) ?? Resource(
        url: url,
        favIconUrl: newfavIconUrl != model.resource.favIconUrl ? newfavIconUrl : null,
        title: newTitle != model.resource.title ? newTitle : null,
      );

      if (model.resource.isQueued == true) {
        deleteResource(model.resource);
       
      }

    } else {
      // update resource if favicon != null || title != null 
      
        //if (model.resource.favIconUrl == null) {
          final favIconUrl = await model.getFaviconUrl(controller);
          if (favIconUrl != null && favIconUrl != model.resource.favIconUrl) {
            model.resource.favIconUrl = favIconUrl;
            resourceUpdated = true;
          }
        //}
       
        final title = await controller.getTitle();
        if (title != null && title.isNotEmpty && title != model.resource.title) {
          model.resource.title = title;
          resourceUpdated = true;
        }
        
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
          updateVisibleResources();
        }
        updateWorkspaceTabs();
      } else {
        final image = await controller.takeScreenshot();
        if (image != null) {
          model.resource.image = image;
        }
      }

      if (model.resource.scrollPosition != null) {
        print('scrolling to past scroll position');
        await controller.scrollTo(x: 0, y: model.resource.scrollPosition!);
        print(model.resource.scrollPosition);
      }
    } else {
      
       
       
    }

    if (model.resource.url!.contains('search') && model.resource.isSearch != true) model.resource.isSearch = true;

    setState(() {
      workspace;
      model.resource;
      tabs;
    });
    
  }

  addTabFromNewWindow(Resource parent, int windowId) {
    TabView tab = TabView(
      incognito: tabs.firstWhere((t) => t.model.resource.id == parent.id).incognito,
      windowId: windowId,
      model: TabViewModel(
        workspaceModel: this,
      ),
      lazyLoad: false,
    );
    setState(() {
      if(workspace.activeTabIndex != null && workspace.tabs.isNotEmpty) {
        workspace.activeTabIndex = workspace.activeTabIndex! + 1;
        tabs.insert(workspace.activeTabIndex!, tab);
      } else {
        tabs.add(tab);
        workspace.activeTabIndex = tabs.length - 1;
      }
      
      if (!showWebView) workspace.showWebView = true;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);


    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  updateTabFromUrlField(Resource resource, String url) async {
    print('updating tab');
    print(url);
    TabView tab = tabs.firstWhere((t) => t.model.resource.id == resource.id);
    await tab.model.controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));

  }

  updateTabResource({String? title, }) {

  }

  onPageChanged(int index, {bool newTabCreated = false }) {
    saveTabsScrollPositionOnExit();
    workspace.activeTabIndex = index;
    if (tabs.length == index) {
      tabs.add(TabView(
        model: TabViewModel(workspaceModel: this),
        lazyLoad: false,
        incognito: workspace.isIncognito ?? false,
        )
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
    HapticFeedback.mediumImpact();
    tabPageController?.jumpToPage(workspace.activeTabIndex! - 1 );
    setState(() {
      final index = tabs.indexWhere((t) => t.model.resource.id == resource.id);
      workspace.activeTabIndex = index > 0 ? index - 1 : index;
      
      tabs = tabs.where((tab) => tab.model.resource.id != resource.id).toList();
      updateWorkspaceTabs();
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
      allResources.add(resource);
      if (resource.contexts.isEmpty) {
        resource.contexts.add(workspace.id);
      }
      data.saveResource(resource);
      
    });

    if (!hasQueue) hasQueue = true;
    updateVisibleResources();
    
  }

  reloadTab(Resource? resource) {
    final tab = resource != null 
      ? tabs.firstWhereOrNull((tab) => tab.model.resource.id == resource.id)
      : tabs[workspace.activeTabIndex!];
    if (tab == null) return;
    tab.model.controller.reload();
  }

  updateWorkspaceTabs() {
    workspace.tabs = tabs.map((t) => t.model.resource).toList();
    if (workspace.title != null) {
      workspace.updated = DateTime.now().millisecondsSinceEpoch;
      data.saveWorkspace(workspace);
    }
  }

  saveTab(Resource resource) async {
    HapticFeedback.mediumImpact();

    if (resource.imageUrl == null) {
      final tab = tabs.firstWhereOrNull((tab) => tab.model.resource.id == resource.id);
      if (tab != null) {
        await tab.model.getImageUrl();
      }
    }
    

    setState(() {
      if (resource.contexts.isEmpty) {
        resource.contexts.add(workspace.id);
      }
      allResources.add(resource);
      data.saveResource(resource);
    });

    if (resource.images.isNotEmpty && !hasImages) hasImages = true;

    updateVisibleResources();

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
    refreshResources();
    Navigator.pushNamed(context, AppRoutes.workspace, 
      arguments: WorkspaceViewParams(
        workspaceId: newFolder.id, 
        parentId: workspace.id
      )
    );
  }

  createNewTab({String? url, bool lazyload = false, bool incognito = false}) {
    TabView tab = TabView(
      incognito: workspace.isIncognito ?? incognito,
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
      
      if (!showWebView) workspace.showWebView = true;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);
    
  }

  deleteResource(Resource resource) {
    
      bool deletePermanently = false;
      if (resource.isQueued == true) {
        deletePermanently = true;
      } 
      allResources.removeWhere((r) => r.id == resource.id);
      data.deleteResource(resource, permanent: deletePermanently);

      updateVisibleResources();
    
  }

  clearTabs({bool createNewTab = false}) {
    
    setState(() {
      tabs = [];  
      updateWorkspaceTabs();
      if (createNewTab) {
        tabs.add(TabView(model: TabViewModel(workspaceModel: this), lazyLoad: false, incognito: workspace.isIncognito ?? false,));
        workspace.showWebView = true;
      }

      print(workspace.tabs);

    });
  }

  closeTab(Resource resource) {
    saveTabsScrollPositionOnExit();
    HapticFeedback.mediumImpact();
    tabPageController?.jumpToPage(max(0, workspace.activeTabIndex! - 1));
    setState(() {
      tabs.removeWhere((t) => t.model.resource.id == resource.id);
      if (workspace.activeTabIndex == tabs.length) {
        workspace.activeTabIndex == tabs.length - 1;
      }
    });

    
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
    allResources.add(resource);
    resource.contexts = [workspace.id];
    data.saveResource(resource);

    updateVisibleResources();

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
    print('text selected');
    print(text);
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
    HapticFeedback.mediumImpact();
    List<String> selectedTags = selectedText!.toLowerCase().trim().split(' ');
    setState(() {
      TabView currentTab = tabs[workspace.activeTabIndex!];
      Resource resource = currentTab.model.resource;
      for (String tag in selectedTags) {
        final tagIndex = resource.tags.indexWhere((t) => t == tag);
        if (tagIndex > -1) {
          resource.tags.removeAt(tagIndex);
        } else {
          resource.tags.add(tag);
        }
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      if (!resource.isSaved) {
        resource.created = now;
        resource.lastVisited = now;
      } 
      if (workspace.title != null && !resource.contexts.contains(workspace.id)) resource.contexts.add(workspace.id);
      if (resource.deleted != null) resource.deleted = null;
      if (resource.isQueued == true) resource.isQueued = null;

      data.saveResource(resource);
      currentTab.model.controller.clearFocus();
      showTextSelectionMenu = false;
      showNotification(NotificationParams(
        title: 'Added ${selectedTags.map((t) => '"'+t+'"').join('and ')} to tags',
        action: editBookmarkAction,
        actionLabel: 'Edit'
      ));

      // if (tags.firstWhereOrNull((t) => t.name == tag) == null) {
      //   tags.add(Tag(lastViewed: resource.lastVisited ?? 0, name: tag));
      // }
    });
  }

  createHighlight({String? id}) async  {
    TabView currentTab = tabs[workspace.activeTabIndex!];
    final now = DateTime.now().millisecond;
    final highlight = Highlight(
        text: selectedText!,
        id: id,
    );

    Resource resource = currentTab.model.resource;
    setState(() {
      resource.highlights.add(highlight);
      resource.updated = now;
      if (workspace.title != null && !resource.contexts.contains(workspace.id)) {
        resource.contexts.add(workspace.id);
      }
      data.saveResource(resource);
      currentTab.model.controller.clearFocus();
      showTextSelectionMenu = false;
    });

    showNotification(NotificationParams(
      title: 'Highlight Added', 
      action: () => editBookmarkAction(resource: resource), 
      actionLabel: 'Edit')
    );

    if (!hasHighlights) hasHighlights = true;
    updateVisibleResources();
  }

  onTabContentClicked() {
    if (showTextSelectionMenu) {
      setState(() {
        showTextSelectionMenu = false;
      });
    }
  }

  onShare(Resource resource) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.shareUri(
      Uri.parse(resource.url!)
    );
  }


  InputData? lastInput;

  onInputEntered(TabView tab, String text) {
    lastInput = InputData(
      text: text, 
      time: DateTime.now().millisecondsSinceEpoch, 
      tabId: tab.model.id, 
      url: tab.model.resource.url!
    );
  }



  checkTabForSearch(TabViewModel model, InAppWebViewController controller, Uri? uri) async {

    final now = DateTime.now().microsecondsSinceEpoch;

    if (lastInput == null || (now - lastInput!.time < 20000)) return;
    
    Domain? searchDomain;
    final matchingDomain = data.domains.firstWhereOrNull((d) => d.url == uri?.origin);
    
    if (matchingDomain != null) {

      if (matchingDomain.favIconUrl == null) {
        matchingDomain.favIconUrl = await model.getFaviconUrl(controller);
      }

      bool isSearch = false;
      if (matchingDomain.searchTemplate != null) {
        isSearch = matchingDomain.checkIfUrlIsSearch(uri.toString());
      } else  {
        final searchTemplate = Domain.checkIfUrlContainsInput(lastInput!, uri!);
        if (searchTemplate != null) {
          matchingDomain.searchTemplate = searchTemplate;
          isSearch = true;
        }
      }

      if (isSearch) {
        matchingDomain.searchCount += 1;
        matchingDomain.lastVisited = DateTime.now().millisecondsSinceEpoch;
        searchDomain = matchingDomain;
      }
    } else {

      final searchTemplate = Domain.checkIfUrlContainsInput(lastInput!, uri!);
      
      if (searchTemplate != null) {
          searchDomain = Domain(
            url: Uri.parse(lastInput!.url).host.toString(),
            title: model.resource.title,
            favIconUrl: model.resource.favIconUrl,
            searchTemplate: searchTemplate,
          );
          searchDomain.lastVisited = lastInput!.time;
      }
    }

    if (searchDomain != null) {
        data.saveDomain(searchDomain);
    }
  }

  bool get activeTabHasSavedDomain {
    TabView activeTab = tabs[workspace.activeTabIndex!];
    final uri = Uri.parse(activeTab.model.resource.url!);
    final savedDomain = data.domains.firstWhereOrNull((d) => d.url == uri.origin);
    if(savedDomain != null) return true;
    return false;
  }

  addDomain(Resource resource) {
    final uri = Uri.parse(resource.url!);
    data.saveDomain(
      Domain(
        url: uri.origin,
        favIconUrl: resource.favIconUrl,
      )
    );
    Navigator.pop(context);
  }

  removeDomain(Resource resource) {
    final uri = Uri.parse(resource.url!);
    data.deleteDomain(uri.origin);
    Navigator.pop(context);
  }

  bool notificationIsVisible = false;
  NotificationParams? notificationParams;

  showNotification(NotificationParams params) {
    
    notificationParams = params;
    setState(() {
      notificationIsVisible = true;
    });
    
    Timer(Duration(milliseconds:  2500 ), () {
      setState(() {
        notificationIsVisible = false;
      });
    });
  }

  editBookmarkAction({Resource? resource}) {
    
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => EditBookmarkModal(
        workspaceViewModel: this, 
        resource: resource ?? tabs[workspace.activeTabIndex!].model.resource
      ) 
    );
    
  }


  saveLink(Resource resource) {

    resource.isQueued = true;
    saveResource(resource);
    showNotification(NotificationParams(
      title: 'Link saved for later',
      action: () => editBookmarkAction(resource: resource),
      actionLabel: 'Edit',
    ));

    HapticFeedback.mediumImpact();

    if (!hasQueue) hasQueue = true;
    updateVisibleResources();
  }

  goBackToWorkspaceView() async {
    saveTabsScrollPositionOnExit();
    setState(() {
      workspace.showWebView = false;
    });
  }

  saveTabsScrollPositionOnExit() async {
    final tab = tabs[workspace.activeTabIndex!];
    Resource resource = tab.model.resource;
    
    //updateWorkspaceTabs();
    if (resource.isSaved) {
      resource.scrollPosition = await tab.model.controller.getScrollY();
      data.saveResource(resource);
    } 
  }

  setResourceView(ResourceView? view) {

    setState(() {
      if (resourceView == view) {
        resourceView = null;
      } else {
        resourceView = view;
      }
    });

    updateVisibleResources();
    
  }


  bool isInEditMode = false;
  setEditMode(value) {
    setState(() {
      isInEditMode = value;
    });
  }

}

class InputData {
  String tabId;
  String text;
  int time;
  String url;

  InputData({
    required this.text,
    required this.time,
    required this.tabId,
    required this.url,
  });

}

class NotificationParams {
  String title;
  Function()? action;
  String? actionLabel;
  NotificationParams({required this.title, this.action, this.actionLabel});
}

enum ResourceView {
  saved,
  queue,
  highlights,
  important,
  images,
}