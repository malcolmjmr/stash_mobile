
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/text_selection/copy_modal.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/providers/search.dart';


import 'package:stashmobile/app/web/tab.dart';

import 'package:stashmobile/app/web/tab_edit_modal.dart';

import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/web/tab_summary_modal.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/main.dart';

import 'package:stashmobile/models/chat.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/services/llm.dart';
import '../../constants/color_map.dart';
import '../../models/resource.dart';



class Views {
  static String tabs = 'tabs';
  static String recent = 'recent';
  static String folders = 'folders';
  static String queue = 'queue';
  static String highlights = 'highlights';
}

class WorkspaceViewModel extends ChangeNotifier {
  late DataManager data;


  late Workspace workspace;
  Workspace? parentWorkspace;
  List<Workspace> subWorkspaces = [];
  List<Resource> allResources = [];

  bool hasSavedResources = false;
  bool hasQueue = false;
  bool hasHighlights = false;
  bool hasFavorites = false;
  bool hasDomains = false;
  bool hasTags = false;
  bool hasImages = false;
  bool hasNote = false;
  bool hasChat = false;

  ResourceView? resourceView = ResourceView.history;
  //List<Resource> folders = [];
  List<Workspace> folders = [];
  List<Resource> favorites = [];
  List<Tag> tags = [];
  List<Tag> selectedTags = [];
  List<Tag> visibleTags = [];
  List<Resource> visibleResources = [];
  List<Domain> domains = [];
  List<TabView> tabs = [];
  List<TabView> selectedTabs = [];
  late Key key;

  String view = Views.tabs;
  PageController? tabPageController;

  late BuildContext context;

  late Function(Function()) setState;
  bool showWebView = false;
  bool showHorizontalTabs = false;

  late ReadAloudController readAloud;


  ScrollController scrollController = ScrollController();


  WorkspaceViewParams? params;

  WorkspaceViewModel({
    this.params,
    DataManager? dataManager,
  }) {
    if (dataManager != null) {
      data = dataManager;
      //setWorkspace();
    }

    key = UniqueKey();


    if (params?.workspace != null) {
      workspace = params!.workspace!;
      workspaceIsSet = true;
    }
    //readAloud = 
  }

  bool workspaceLoaded = false;

  init(BuildContext buildContext, Function(Function()) setStateFunction) async {
    
    context = buildContext;
    setState = setStateFunction;
    scrollController.addListener(scrollListener);
    data = context.read(dataProvider);
    readAloud = context.read(readAloudProvider);
 
    await loadWorkspace();

    isLoading = false;
  }

  @override
  dispose() {
    // if (!isLoading) {
    //   keyboardSubscription.cancel();
    // }
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  bool showCollapsedHeader = false;
 

  scrollListener() {

    final threshold = 50;
    if (scrollController.offset > threshold && !showCollapsedHeader) {
      setState(() {
        showCollapsedHeader = true;
      });

    } else if (scrollController.offset < threshold && showCollapsedHeader) {
      setState(() {
        showCollapsedHeader = false;
      });
    }
    // if (scrollController.offset >= scrollController.position.maxScrollExtent &&
    //     !scrollController.position.outOfRange) {
    //   // You've reached the bottom of the scroll view
    //   print("Reached the bottom");
    // } else if (scrollController.offset <= scrollController.position.minScrollExtent &&
    //            !scrollController.position.outOfRange) {
    //   // You've reached the top of the scroll view
    //   if ()
    // }
  }

  bool isNewSpace = true;

  bool workspaceIsSet = false;
  setWorkspace() async {
    //addKeyboardListener();
    if (workspaceIsSet) return;

    if (params?.workspaceId == Workspace.all().id) {
      workspace = Workspace.all();
      isNewSpace = false;
    } else if (params?.workspaceId != null) {
      workspace = await data.getWorkspace(params!.workspaceId!);
      isNewSpace = false;
    } else {
      workspace = Workspace(
          //color: colorMap.keys.toList()[(new Random()).nextInt(9)], 
          isIncognito: params?.isIncognito
        ); 
      workspace.showWebView = true;
    }
    workspaceIsSet = true;

  }
  loadWorkspace() async {
    if (workspaceLoaded) return;
    
    await setWorkspace();

    //context.read(workspaceProvider).state = workspace.id;
    if (params?.parentId != null) parentWorkspace = await data.getWorkspace(params!.parentId!);
    
    allResources =  await data.getWorkspaceResources(workspace.id);
    await fixData();
    await loadTabs();
    await loadFolders();
    await refreshResources();
    await updateVisibleResources();

    workspaceLoaded = true;

    setState(() {
      isLoading = false;
    });
    
  }


  late StreamSubscription<bool> keyboardSubscription;
  KeyboardVisibilityController keyboardVisibility = KeyboardVisibilityController();
  bool keyboardIsVisible = false;

  addKeyboardListener() {
    keyboardIsVisible = keyboardVisibility.isVisible;
    keyboardSubscription = keyboardVisibility.onChange.listen((bool visible) {
      keyboardIsVisible = visible;
      if (visible && showToolbar) {
        setShowToolbar(false);
      }
    });
  }

  

  loadTabs() {
    // check workspace params for new tab
    if (params?.resourceToOpen != null) {

      final index = workspace.tabs
        .indexWhere((t) => (t.url != null && t.url == params!.resourceToOpen!.url) || t.id == params!.resourceToOpen!.id);

      if (index > -1) {
        workspace.activeTabIndex = index;
      } else {
        print('adding new resource to workspace');
        workspace.tabs.add(params!.resourceToOpen!);
        workspace.activeTabIndex = workspace.tabs.length - 1;
      }
      workspace.showWebView = true;
    } else if (workspace.title == null) {
      workspace.tabs = [Resource(title: 'New Tab')];
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
      final view = tab.url == null && tab.chat != null ? TabViewType.chat : TabViewType.web;
      return TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: tab.title != 'New Tab' ? tab : null,
          isIncognito: workspace.isIncognito ?? false,
        ), 
        lazyLoad: isOpenedTab ? false : lazyLoad,
        
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
        if (resource.chat == null && resource.note == null && ids.contains(resource.id)) {
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

    // Todo: integrate highlight count and favorites 

    int comp = (b.lastVisited ?? 0).compareTo(a.lastVisited ?? 0);
    if (resourceView == ResourceView.favorites) {
      final favoriteComp = b.highlights
        .where((h) => h.favorites > 0).length
        .compareTo(a.highlights.where((h) => h.favorites > 0).length);
      if (favoriteComp == 0) {
        final highlighComp = b.highlights.length.compareTo(a.highlights.length);
        if (highlighComp == 0) {
          final ratingComp = b.rating.compareTo(a.rating);
          comp = ratingComp;
        } else {
          comp = highlighComp;
        }
    
      } else {
        comp = favoriteComp;
      }
      
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

      if (resource.isSaved && !hasSavedResources) {
        hasSavedResources = true;
      }

      if (resource.highlights.isNotEmpty && !hasHighlights) {
        hasHighlights = true;
      }

      if ((resource.rating > 0 || resource.highlights.any((h) => h.likes > 0 || h.favorites > 0)) && !hasFavorites) {
        hasFavorites = true;
      }

      if (resource.isQueued == true && !hasQueue) {
        hasQueue = true;
      }

      if (resource.note != null && !hasNote) {
        hasNote = true;
      }

      if (resource.chat != null && !hasChat) {
        hasChat = true;
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

        if (!hasTags) hasTags = true;

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
    sortedTags.sort(sortTags);

    if (hasQueue && !hasSavedResources) {
      resourceView = ResourceView.queue;
    }

    tags = sortedTags;
    visibleTags = tags.sublist(0, min(20, tags.length)).toList();
    
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
    print('toggle');
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

        if ((resourceView == null || resourceView == ResourceView.history) && !resource.isSaved && resource.isQueued == true) {
          matchesFilter = false;
        }

        if (resourceView == ResourceView.favorites) {
          if (resource.rating < 1 && resource.highlights.length < 3) {
            matchesFilter = false;
          }
        }

        if (resourceView == ResourceView.chats && resource.chat != null) {
          matchesFilter = false;
        }

        if (resourceView == ResourceView.notes && resource.note != null) {
          matchesFilter = false;
        }

        if (resourceView == ResourceView.images && resource.images.isEmpty) {
          matchesFilter = false;
        } 


        final tagFound =  selectedTags.isEmpty || (selectedTags.every((t) => resource.tags.contains(t.name)));
        if (tagFound && matchesFilter) {
          tempResources.add(resource);
          for (final tagName in resource.tags) {
            Tag? tag = tempTags[tagName];
            if (tag == null) {
              tag = Tag(
                name: tagName, 
                lastViewed: resource.lastVisited ?? resource.updated ?? resource.created ?? 0,
                isSelected: selectedTags.firstWhereOrNull((selectedTag) => selectedTag.name == tagName) != null
              );
            }
            tag.valueCount += 1;
            tempTags[tagName] = tag;
          }
        }
      }

      

      print('finished iterating through resources');

      if (tempResources.isEmpty && selectedTags.isNotEmpty) {
        selectedTags = [];
        updateVisibleResources();
        return;
      }
      tempResources.sort(sortResources);
      visibleResources = tempResources;
      List<Tag> sortedTags = tempTags.values.where((t) => view == ResourceView.history ? t.valueCount == 2 : t.valueCount > 1).toList();
      
      if (selectedTags.isNotEmpty && sortedTags.isEmpty) {
        sortedTags = selectedTags;
      }
      sortedTags.sort(sortTags);
      
      
      visibleTags = selectedTags.isEmpty
        ? sortedTags.sublist(0, min(20, sortedTags.length)).toList()
        : sortedTags;
    });
  }

  TabView get currentTab => tabs[workspace.activeTabIndex!];

  openTab(Resource resource) {
    final index = tabs.indexWhere((tab) => tab.model.resource.id == resource.id);
    if (index > -1) {
      workspace.activeTabIndex = index;
      final tabModel = tabs[index].model;
      if (tabModel.resource.url != null && !tabModel.loaded) {
        tabModel.controller.loadUrl(urlRequest: URLRequest(url: WebUri(tabModel.resource.url!)));
      }
    } else {
      if (resource.isQueued == true) {
        resource.isQueued = false;
        resource.deleted = DateTime.now().millisecondsSinceEpoch;
        data.deleteResource(resource, permanent: true);
      }
      tabs.add(TabView(
        model: TabViewModel(
          workspaceModel: this,
          initialResource: resource,
          isIncognito: workspace.isIncognito ?? false,
        ),
        
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

  openResource(BuildContext context, Resource resource, {String? highlightId}) {
    if (highlightId != null) setSelectedHighlight(highlightId);
    

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
              isIncognito: workspace.isIncognito ?? false,
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

    context.read(showHomeProvider).state = false;
  }

  List<String> selectedResources = [];

  toggleSelectAllTabs() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (selectedResources.length == tabs.length) {
        selectedResources = [];
      } else {
        selectedResources = tabs.map((t) => t.model.resource.id!).toList();
        
      }
      
    });
  }

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
    HapticFeedback.mediumImpact();
    setState(() {
      selectedResources = [];
    });
  }

  removeSelectedTabs() {
    HapticFeedback.mediumImpact();
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
    final now = DateTime.now().millisecondsSinceEpoch;

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

      final newfavIconUrl = await model.getFaviconUrl(controller);
      final newTitle = await controller.getTitle();
      
      
      model.resource = model.resources[url] 
        ?? allResources.firstWhereOrNull((r) => r.url == url) 
        ?? Resource(
          url: url,
          favIconUrl: newfavIconUrl != model.resource.favIconUrl ? newfavIconUrl : null,
          title: newTitle != model.resource.title ? newTitle : null,
        );
      model.resource.lastVisited = now;

      if (model.resource.isQueued == true) {
        deleteResource(model.resource);
      }

      model.canGoForward = model.queue.isNotEmpty || model.resource.highlights.isNotEmpty || (await controller.canGoForward());
      model.canGoBack = await controller.canGoBack();

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

        model.resource.lastVisited = now;
        
    }

    if (tabLoaded) {

      if (workspace.title != null) {
        if (model.resource.lastVisited == null || (now - model.resource.lastVisited!) > (1000 * 60 * 60 * 2) ) {
          resourceUpdated = true;
        }
        
        if (resourceUpdated && model.resource.isSaved) {
          
          data.saveResource(model.resource);
          updateVisibleResources();
        }
        updateWorkspaceTabs();
      }

      if (model.resource.scrollPosition != null) {
        print('scrolling to past scroll position');
        await controller.scrollTo(x: 0, y: model.resource.scrollPosition!);
        print(model.resource.scrollPosition);
      }
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
      windowId: windowId,
      model: TabViewModel(
        viewType: TabViewType.web,
        isIncognito: tabs.firstWhere((t) => t.model.resource.id == parent.id).model.isIncognito,
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
      if (!showToolbar) showToolbar = true;
    });

    tabPageController?.jumpToPage(workspace.activeTabIndex!);


    tabPageController?.jumpToPage(workspace.activeTabIndex!);
  }

  updateTabFromUrlField(Resource resource, String url) async {

    TabView tab = tabs.firstWhere((t) => t.model.resource.id == resource.id);
    if (tab.model.loaded) {
      await tab.model.controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    } else {
      tab.model.resource.title = url;
      tab.model.resource.url = url;
      await tab.model.setViewType(TabViewType.web);
    }
    

  }

  updateTabResource({String? title, }) {

  }

  onPageChanged(int index, {bool newTabCreated = false }) {
    saveTabsScrollPositionOnExit();
    workspace.activeTabIndex = index;
    if (tabs.length == index) {
      tabs.add(TabView(
        model: TabViewModel(
          workspaceModel: this,
          isIncognito: workspace.isIncognito ?? false,
        ),
        lazyLoad: false,
        )
      );
      newTabCreated = true;
      showOmnibox = true;
    }

    
    final tab = tabs[index];
    if (tab.lazyLoad && !tab.model.loaded && tab.model.resource.url != null) {
      Timer(Duration(milliseconds: newTabCreated ? 300 : 0), () {
        tab.model.controller.loadUrl(urlRequest: URLRequest(url: WebUri(tab.model.resource.url!)));
      });
    }
  

    setState(() {
      workspace.activeTabIndex = index;
      tabs;
      showOmnibox;
    });

  }

  removeTab(Resource resource) async {
    HapticFeedback.mediumImpact();
    
    setState(() {
      final index = tabs.indexWhere((t) => t.model.resource.id == resource.id);
      workspace.activeTabIndex = index > 0 ? index - 1 : index;
      
      tabs = tabs.where((tab) => tab.model.resource.id != resource.id).toList();
      updateWorkspaceTabs();
    });
    tabPageController?.jumpToPage(workspace.activeTabIndex!);

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
    saveResource(resource);
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
  }

  bool showCreateOptions = false;
  setShowCreateOptions(bool value) {
    setState(() {
      showCreateOptions = value;
    });
  }

  createNewTab({
    Resource? resource, 
    String? url, 
    bool lazyload = false, 
    bool? incognito, 
    TabViewType? viewType,
  }) {

    
    
    TabView tab = TabView(
      model: TabViewModel(
        workspaceModel: this,
        viewType: url != null ? TabViewType.web : viewType,
        isIncognito: incognito ?? workspace.isIncognito ?? false,
        initialResource: resource != null 
          ? resource
          : url != null 
            ? Resource(url: url) 
            : null,
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

      // if (resource == null && url == null) {
      //   showToolbar = false;
      // }
    });

    // if (resource == null && url == null) {
    //   openTabEditModal();
    // }

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
      if (workspace.title == null) {
        context.read(windowsProvider).closeWorkspace(workspace);
      }
      if (createNewTab) {
        tabs.add(
          TabView(
            model: TabViewModel(
                workspaceModel: this,
                isIncognito: workspace.isIncognito ?? false,
              ), 
              lazyLoad: false, 
              
            )
          );
        workspace.showWebView = true;
      }

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
      selectedResources = [];
      updateWorkspaceTabs();
    });
  }

  mergeSelectedTabs() {
    final selectedTabs = tabs.where((t) => selectedResources.contains(t.model.resource.id)).toList();
    final mainTab = selectedTabs.removeAt(0);

    mainTab.model.addResourcesToQueue(selectedTabs.map((t) => t.model.resource).toList());
  
    setState(() {
      tabs.removeWhere((t) => selectedTabs.any((st) => st.model.id == t.model.id));
      final index = tabs.indexWhere((t) => t.model.id == mainTab.model.id);
      if (index > -1) {
        workspace.activeTabIndex = index;
        tabPageController?.jumpToPage(workspace.activeTabIndex!);
        tabs = tabs;
        selectedResources = [];
        updateWorkspaceTabs();

      }
    });

  }

  stashSelectedTabs() {
    
    for (String resourceId in selectedResources) {
      final tab = tabs.firstWhere((t) => t.model.resource.id == resourceId);
      Resource resource = tab.model.resource;
      resource.isQueued = true;
      saveResource(resource);
    }

    tabs.removeWhere((t) => selectedResources.contains(t.model.resource.id));

    setState(() {
      tabs = tabs;
      selectedResources = [];
      updateVisibleResources();
      updateWorkspaceTabs();

    });

  }



  saveResource(Resource resource) {
    
    if (allResources.firstWhereOrNull((r) => r.id == resource.id) == null) {
      allResources.add(resource);
    }

    if (!resource.contexts.contains(workspace.id)) {
      resource.contexts.add(workspace.id);
      if (resource.tags.isEmpty && resource.isQueued != true) {
        resource = extractTagsFromSelectedText(resource: resource);
      }
    }

    if (resource.article != null) {
      resource.text = resource.article.toString();
    }
   
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
    setState(() {
      selectedText = text;
      showTextSelectionMenu = true;
    });
  }

  setShowTextSelectionMenu(bool value) {
    setState(() {
      showTextSelectionMenu = value;
    });
  }


  searchSelectedText({String? text, bool openInNewTab = false}) {

    TabView currentTab = tabs[workspace.activeTabIndex!];
    currentTab.model.clearSelectedText();
    setState(() {
      showTextSelectionMenu = false;
      selectedHighlight = null;
      showToolbar = true;
    });

    if (text != null) {
      selectedText = text;
    }

    String url = '';
    if (selectedText!.length  > 30 || selectedText!.split('.').length > 1) {
      if (openInNewTab) {
        createNewTab(url: context.read(searchProvider).getExaSearchUrlforResource(prompt: selectedText));
      } else {
        currentTab.model.getRelatedContent(searchText: selectedText);
      }
     
    } else {
      url = 'https://www.google.com/search?q=' + Uri.encodeComponent(selectedText!);
      if (currentTab.model.viewType == TabViewType.web) {
        currentTab.model.controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
      } else {
        createNewTab(url: url);
      }
    }
    if (text != null) {
      setState(() {
        selectedText = null;
      });
      
    }
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
      if (selectedHighlight == null) {
        showNotification(NotificationParams(
          title: 'Added ${selectedTags.map((t) => '"'+t+'"').join('and ')} to tags',
          action: editBookmarkAction,
          actionLabel: 'Edit'
        ));
      } else {
        updateSelectedHighlightTags();
      }
      

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

    extractTagsFromSelectedText();

    Resource resource = currentTab.model.resource;
    setState(() {
      resource.highlights.add(highlight);
      resource.updated = now;
      if (workspace.title != null && !resource.contexts.contains(workspace.id)) {
        resource.contexts.add(workspace.id);
      }
      data.saveResource(resource);
      currentTab.model.controller.clearFocus();
      if (!currentTab.model.canGoForward) {
        currentTab.model.canGoForward = true;
      }
      showTextSelectionMenu = false;
    });

    HapticFeedback.mediumImpact();

    if (resource.highlights.length == 3) {
      currentTab.model.getRelatedContent();
    }

    if (!hasHighlights) hasHighlights = true;
    updateVisibleResources();
  }

  extractTagsFromSelectedText({String? textToUse, Resource? resource}) {

    if (resource == null) resource = currentTab.model.resource;

    const punctuation = ['.',',',';','!','?','"','(',')',':'];
    String text = (textToUse ?? selectedText!).toLowerCase();

    for (final mark in punctuation) {
      text = text.replaceAll(mark, '');
    }

   text = text.replaceAll('-', ' ').replaceAll('\n', ' ');
   
    for (final term in text.split(' ')) {
      for (final tag in tags) {
        final termPrefix = term.substring(0, min(term.length, 4));
        final tagPrefix = tag.name.substring(0, min(tag.name.length, 4));
        if (termPrefix.contains(tagPrefix)) {
          if (resource.tags.firstWhereOrNull((t) => t.contains(termPrefix)) == null) {
            resource.tags.add(term);
          }
        }
      }
    }

    return resource;
  }

  searchSelectedTags({Tag? tag, bool isSemantic = false}) {
    final tagsToSearch = [...selectedTags, if (tag != null) tag].map((t) => t.name).toList();
    final searchQuery = tagsToSearch.join(' ');

    String url = '';
    if (isSemantic) {
      url = context.read(searchProvider).getExaSearchUrlforResource(prompt: searchQuery);
    } else {
      url = 'https://www.google.com/search?q=' + Uri.encodeComponent(searchQuery);
    }

    createNewTab(url: url);
  }

  onTabContentClicked() async {
    if (showTextSelectionMenu) {
      setState(() {
        showTextSelectionMenu = false;
      });
    } 

    if (selectedHighlight != null) {
      setState(() {
        selectedHighlight = null;
      });
    }

    if (showCreateOptions) {
      setShowCreateOptions(false);
    }

    if (showQuickActions) {
      setShowQuickActions(false);
    }

    if (selectedText != null) {
      final currentSelection = await currentTab.model.controller.getSelectedText();
      if (currentSelection == null || currentSelection.isEmpty) {
        setState(() {
          selectedText = null;
        });
      }
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
    if (resource.favIconUrl == null) {
      resource.favIconUrl = [
        ...tabs.map((t) => t.model.resource).toList(), 
        ...allResources
      ].firstWhereOrNull((r) {
        if (r.favIconUrl == null) return false;

        final rHost = Uri.parse(r.url!).host;
        final linkHost = Uri.parse(resource.url!).host;
        return linkHost == rHost;

      })?.favIconUrl;
    }
    saveResource(resource);

    final queueIndex = currentTab.model.queue.indexWhere((i) => i == resource.url);
    if (queueIndex > -1) {
      currentTab.model.queue.removeAt(queueIndex);
      currentTab.model.queue.insert(0, resource);
    } else {
      currentTab.model.queue.insert(0, resource);
    }

    if (!currentTab.model.canGoForward) {
      currentTab.model.canGoForward = true;
    }


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
    await getTabImages();
    setState(() {
      workspace.showWebView = false;
    });
  }

  getTabImages() async {
    if (workspace.title != null) return;

    for (int i = 0; i < tabs.length; i++) {
      final needToGetImage = (
        tabs[i].model.resource.image == null 
        || tabs[i] == currentTab);
      if (needToGetImage) {
        tabs[i].model.resource.image = await tabs[i].model.controller.takeScreenshot();
      }
    }
  }

  saveTabsScrollPositionOnExit() async {

    final tab = tabs[workspace.activeTabIndex!];
    if (!tab.model.loaded) return;

    Resource resource = tab.model.resource;
    
    //updateWorkspaceTabs();
    if (resource.isSaved && resource.chat == null || resource.note == null) {
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

    if  (resourceView != ResourceView.folders) {
      updateVisibleResources();
    }
    
  }


  bool isInEditMode = false;
  setEditMode(value) {
    setState(() {
      isInEditMode = value;
    });
  }

  bool showQuickActions = false;
  setShowQuickActions(bool value) {
    setState(() {
      showQuickActions = value;
    });
  }


  moveTabToNewSpace(BuildContext context) { 
    context.read(windowsProvider).openWorkspace(null, resource: currentTab.model.resource);            

    removeTab(currentTab.model.resource);
  }

  bool showFindInPage = false;
  setShowFindInPage(bool value) {
    setState(() {
      showFindInPage = value;
    });
  }

  moveTabToBottom() {
    final index = tabs.indexWhere((t) => t.model.resource.id == currentTab.model.resource.id);
    final tab = tabs.removeAt(index);
    setState(() {
      tabs = [...tabs, tab];
      workspace.activeTabIndex = tabs.length - 1;
    });
  }

  moveTabToTop() {
    final index = tabs.indexWhere((t) => t.model.resource.id == currentTab.model.resource.id);
    final tab = tabs.removeAt(index);
    setState(() {
      tabs = [tab, ...tabs];
      workspace.activeTabIndex = 0;
    }); 
  }

  Highlight? selectedHighlight;
  List<String> highlightKeywords = []; 
  List<String> relatedKeywords = [];
  setSelectedHighlight(String? highlightId) {
    // Todo 

    highlightKeywords = []; 
    relatedKeywords = [];
    selectedHighlight = currentTab.model.resource
        .highlights.firstWhereOrNull((h) => h.id == highlightId);
    final terms = selectedHighlight?.text.toLowerCase().split(' ') ?? [];

    for (final tag in currentTab.model.resource.tags) {
      final textIncludesTag = terms.any((term) => term.contains(tag.substring(0, min(tag.length, 5))));
      if (textIncludesTag) {
        highlightKeywords.add(tag);
      }
    }

    //getRelatedKeywords();

    setState(() {
      selectedHighlight;
      highlightKeywords;
      relatedKeywords;
    });
  
  }

  getRelatedKeywords() {
      
      Map<String,Tag> tempTags = {}; 

      for (final resource in allResources) {

        final tagFound =  highlightKeywords.any((k) => resource.tags.any((t) => t.contains(k.substring(0, min(k.length, 5)))));
        if (tagFound) {
          for (final tagName in resource.tags) {
            Tag? tag = tempTags[tagName];
            if (tag == null) {
              tag = Tag(
                name: tagName, 
                lastViewed: resource.lastVisited ?? resource.updated ?? resource.created ?? 0,
                isSelected: selectedTags.firstWhereOrNull((selectedTag) => selectedTag.name == tagName) != null
              );
            }
            tag.valueCount += 1;
            tempTags[tagName] = tag;
          }
        }
      }


      List<Tag> sortedTags = tempTags.values.where((t) => t.valueCount > 1).toList();
      
      if (selectedTags.isNotEmpty && sortedTags.isEmpty) {
        sortedTags = selectedTags;
      }
      sortedTags.sort(sortTags);
      
      relatedKeywords = sortedTags
        .sublist(0, min(20, sortedTags.length))
        .map((t) => t.name)
        .toList();
  }

  updateSelectedHighlightTags({String? tagName}) {

    if (tagName != null) {
       Resource resource = currentTab.model.resource;
      final tagIndex = resource.tags.indexWhere((t) => t == tagName);
      if (tagIndex > -1) {
        resource.tags.removeAt(tagIndex);
        highlightKeywords.remove(tagName);
      } else {
        resource.tags.add(tagName);
        highlightKeywords.add(tagName);
      }
      saveResource(resource);

      setState(() {
        highlightKeywords;
      });
    } else if (selectedHighlight != null) {
      setSelectedHighlight(selectedHighlight!.id);
    }
   

    
  }

  bool canGoBack = false;

  bool showToolbar = true;
  setShowToolbar(bool value) {
    
    setState(() {
      showToolbar = value;
    });
  }

  createNote() {
    createNewTab(resource: Resource(note: Note()), viewType: TabViewType.note);
  }

  createChat({bool withLastPrompt = true, bool getSummary = false}) async {

    Resource resource = currentTab.model.resource;


    if (getSummary) {

      if (resource.summary != null) return;

      if (resource.text == null) {
        resource.text = await currentTab.model.controller.evaluateJavascript(source: 'document.body.innerText');
      }

      final prompt = """
        
        Could you please provide a concise and comprehensive summary of the given text? The summary should capture the main points and key details of the text while conveying the author's intended meaning accurately. Please ensure that the summary is well-organized and easy to read, with clear headings and subheadings to guide the reader through each section. The length of the summary should be appropriate  to capture the main points and key details of the text, without including unnecessary information or becoming overly long.   Then explain the implications of the articles main propositions or arguments. Please go beyond reiterating what the author has identified as being the main implications. Then play devils advocate and address any deficiencies of the article. What is author missing or not considering that undermines their argument. The output should be in the following form:

        Summary:
        Implications:
        Deficiencies:

        ${resource.text}

      """;

      resource.summary = await LLM().mistralChatCompletion(prompt: prompt);


    }

    createNewTab(
      resource: Resource(
        chat: Chat(
          selectedText: getSummary
            ? null 
            : selectedHighlight != null
              ? resource.highlights.firstWhere((h) => h.id == selectedHighlight).text 
              : selectedText, 
          parentId: resource.id,
          messages: [
            if (getSummary)
            Message.text(text: resource.summary, role: Role.assistant),
          ]
        ), 
        title: 'New Chat',
        parentId: resource.id,
      ), 
      viewType: TabViewType.chat,
    );
  }

  openTabEditModal() {
    Navigator.push(context, 
      PageTransition<dynamic>(
        type: PageTransitionType.bottomToTop,
        curve: Curves.easeInExpo,
        child: TabEditModal(
          tab: currentTab.model.resource,
          workspaceModel: this,
        ),
        fullscreenDialog: true,
      )
    );
  }

  openSummaryModal() {
    Navigator.push(context, 
      PageTransition<dynamic>(
        type: PageTransitionType.bottomToTop,
        curve: Curves.easeInExpo,
        child: TabSummaryModal(
          model: currentTab.model,
        ),
        fullscreenDialog: true,
      )
    );
  }

  generateTerms() async {
    
    String prompt = '''
      Generate a list of related terms given a list of very important terms
      and less importnat terms. 
      
      Important: ${selectedTags.map((t) => t.name).join(', ')}

      Less important: ${visibleTags.where((t) => !t.isSelected).map((t) => t.name).join(', ')}

      
    ''';

    print(prompt);

    // String response = await LLM().getCompletion(prompt);

    // print(response);
  }

  openRelatedContent() {

    /*
      Todo: 
        - make multiple queries
        - get links that are present in more than one results page
        - open tab with queue of links 
    */

        String prompt = '';
    List<Highlight> highlights = [];
    for (final resource in visibleResources) {
      highlights.addAll(
        resource.highlights.where((h) => selectedTags.any((tag) => h.text.toLowerCase().contains(tag.name))).toList()
      );
    }
    
    if (highlights.isEmpty) {
      prompt = '''
      Articles related to the following topics: 
      ${selectedTags.map((t) => t.name).join(', ')}
      ''';
    } else {
      prompt = '''
      Articles related to the following excerpts: 
      ${highlights.map((h) => '"${h.text}"').join('\n')}
      ''';
    }
    
    String url = 'https://exa.ai/search?q=' + Uri.encodeComponent(prompt);


    createNewTab(url: url);
  }

 


  List<Prompt> selectionPrompts = [];

  List<Prompt> suggestedPrompts = [];

  copySelectionToLastLocation() {

  }

  openCopyModal(BuildContext context) {
    Navigator.push(context, 
      PageTransition<dynamic>(
        type: PageTransitionType.bottomToTop,
        curve: Curves.easeInExpo,
        child: CopyModal()
      )
    );
  }

  updateHighlight(Highlight highlight) {
    setState(() {
       data.saveResource(currentTab.model.resource);
    });
   
  }

  int sortTags(Tag a, Tag b) { 

    final selectionComp = (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0);
    if (selectionComp == 0) {
      if (resourceView != ResourceView.history) {
        final valueCountComp = b.valueCount.compareTo(a.valueCount);
        if (valueCountComp == 0) {
          final viewComp = b.lastViewed.compareTo(a.lastViewed);
          return viewComp;
        } else {
          return valueCountComp;
        }
      } else {
        final viewComp = b.lastViewed.compareTo(a.lastViewed);
        if (viewComp == 0) {
          final valueCountComp = b.valueCount.compareTo(a.valueCount);
          return valueCountComp;
        } else {
          return viewComp;
        }
      }
      
    } else {
      return selectionComp;
    }

  }

  bool isPlayingJourney = false;
  setIsPlayingJourney(bool value) {
    setState(() {
      isPlayingJourney = value;
    });
  }

  bool showOmnibox = false;
  setShowOmnibox(bool value) { 
    final viewType = currentTab.model.viewType;
    if (viewType != null && viewType != TabViewType.web ) {
      if (!value) {
        setState(() {
          showOmnibox = value;
        });
      }
      return;
    }

    setState(() {
      
      showOmnibox = value;
      if (showOmnibox) {
        if (viewType == null) {
          omniboxController.text = '';
        } else if (viewType == TabViewType.web) {
          omniboxController.text = currentTab.model.resource.url ?? '';
        }
      }
      
    });
  }

  TextEditingController omniboxController = TextEditingController();
  onOmniboxInputChanged(String value) {
    
  }

  onOmniboxInputSubmitted(String value) {
    showOmnibox = false;
    updateTabFromUrlField(currentTab.model.resource, getUrlFromInput());

  }

  addSpecialSymbolToOmniboxInput(String value) {
    omniboxController.text += value;
  }

  getUrlFromInput() {
    final input = omniboxController.text;
    String url = input;

    if (input.contains('.')) {
      final missingProtocol = !input.contains('http://') && !input.contains('https://');
      if (missingProtocol) url = 'https://www.' + input;
    } else {
      url = 'https://www.google.com/search?q=' + Uri.encodeComponent(input);
    }
    return url;
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
  favorites,
  history,
  images,
  folders,
  tagged,
  notes,
  chats

}