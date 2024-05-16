

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/providers/search.dart';
import 'package:stashmobile/app/web/js.dart';
import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/models/article.dart';
import 'package:stashmobile/models/chat.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/services/hypothesis.dart';
import 'package:stashmobile/services/llm.dart';
import 'package:stashmobile/services/search.dart';

class TabViewModel {
 
  late InAppWebViewController controller;

  late Resource resource;
  WorkspaceViewModel workspaceModel;

  List<Resource> queue = [];
  bool canGoBack = false;
  setCanGoBack(bool value) {
    setState(() {
      canGoBack = value;
    });
  }
  setCanGoForward(bool value) {
    setState(() {
      canGoForward = value;
    });
  }


  bool canGoForward = false;

  TabViewType? viewType;

  String id = UniqueKey().toString();

  TabViewModel({
    required this.workspaceModel, 
    Resource? initialResource, 
    this.viewType, 
    this.isIncognito = false 
  }) {

    if (initialResource != null) {
      resource = initialResource;
      if (resource.url != null && resource.url!.isNotEmpty) {
        if (viewType == null) viewType = TabViewType.web;
        if (initialResource.isQueued == true) {
          
          queue = workspaceModel.allResources
            .where((r) => r.isQueued == true 
              && !r.isSaved 
              && (r.created ?? 0) < (resource.created ?? 0)
            ).toList();

          if (queue.isNotEmpty) canGoForward = true;
        }

        if (resource.highlights.isNotEmpty) {
          canGoForward = true;
          //getRelatedContent();
        }

        if (viewType == TabViewType.chat) {

        }
      } else if (resource.note != null) {
        viewType = TabViewType.note;

      } else if (resource.chat != null) {
        viewType = TabViewType.chat;
      }
    
    } else {
      resource = Resource(title: 'New Tab');
    }
  }

  late Function(Function()) setState;
  late BuildContext context;

  init(_setState, _context) {
    setState = _setState;
    context = _context;
    if (resource.highlights.isNotEmpty || (resource.isQueued == true && workspaceModel.hasQueue)) {
        canGoForward = true;
        //getRelatedContent();
    }
    if (resource.url != null && viewType == null) {
      viewType = TabViewType.web;
    }

  }

  dispose() {
    
  }

  bool isIncognito = false;

  setViewType(TabViewType value) {
    setState(() {
      viewType = value;
    });
  }

  bool loaded = false;

  bool isNewTab = true;

  Future<String?> getFaviconUrl(InAppWebViewController controller) async {
    final favIcons = await controller.getFavicons();
    return favIcons.isNotEmpty ? favIcons.first.url.toString() : null;
  }


  bool controllerSet = false;
  setController(InAppWebViewController newController) {

    controller = newController;
    controllerSet = true;
  }

  bool isNotAWebsite(Resource? content) =>
      content == null || content.url == null;
 

  WebHistory history = WebHistory();
  List<Resource> get backItems {
    //print(history.list);
    if (history.currentIndex == null) return [];
    return  history.list?.sublist(0, (history.currentIndex ?? 0))
      .map((i) => resources[i.url.toString()] ?? Resource(url: i.url.toString())).toList() ?? [];
  }

  List<Resource> get forwardItems {
    if (history.currentIndex == null) return [];

    return history.currentIndex != null && ((history.currentIndex!) < (history.list?.length ?? 0))
      ? history.list?.sublist(history.currentIndex! + 1,  history.list?.length)
      .map((i) => resources[i.url.toString()] ?? Resource(url: i.url.toString())).toList() ?? []
      : [];
  }

  List<Resource> get queueItems {
    if (queue.isEmpty) return [];
    return queue //.where((url) => forwardHistory.firstWhereOrNull((h) => h.url.toString() != url) == null)
      .map((queuedResource) => workspaceModel.allResources.firstWhereOrNull((r) => r.url == queuedResource.url) ?? resources[queuedResource.url]!).toList();

  }

  bool showTabJourney = false;
  setShowJourney(bool value) {
    setState(() {
      showTabJourney = value;
    });
  }

  toggleShowJourney() {
    setState(() {
      showTabJourney = !showTabJourney;
      workspaceModel.setShowToolbar(!showTabJourney);
    });

    
  }


  Function()? goBackFunction;
  Function()? goForwardFunction;

  goTo(Resource selectedResource) {
    if (selectedResource.isQueued == true) {
      if (queue.length > 1) {
        final index = queue.indexWhere((url) => url == selectedResource.url);
        queue = queue.sublist(index + 1, queue.length - 1);
      } else {
        queue = [];
      }
      controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(selectedResource.url!))));
    } else {
      final historyItem = history.list?.firstWhereOrNull((item) => item.url.toString() == selectedResource.url);
      if (historyItem != null) {
        controller.goTo(historyItem: historyItem);
        resource = selectedResource;
      } else {
        controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(selectedResource.url!))));
      }
      
    }
    setState(() {
      showTabJourney = false;
    });
    
  }


  goBack({Function()? altFunction}) {
    if (altFunction != null) {
      altFunction.call();
    }
    if (!canGoBack) return;
    HapticFeedback.mediumImpact();
    controller.goBack();
    //resource = 
    // need to move this function to tab model and ensure that previous resource is restored
    setState(() {
      showTabJourney = false;
    });
  }

  goToStart() async {
    if (!canGoBack) return;
    HapticFeedback.mediumImpact();
    final history = await controller.getCopyBackForwardList();
    final historyItem = history?.list?[0];
    if (historyItem != null) {
      controller.goTo(historyItem: historyItem);
    }
     setState(() {
      showTabJourney = false;
    });
  }

  goForward({Function()? altFunction}) async {
    if (altFunction != null) {
      altFunction.call();
    }
    if (!canGoForward) return;
    HapticFeedback.mediumImpact();
    final hasForwardHistoryItem = await controller.canGoForward();
    if (hasForwardHistoryItem) {
      await controller.goForward();
    } else if (queue.isNotEmpty) {
      final nextItem = queue.removeAt(0);
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(nextItem.url!)
        )
      );
    } else if (workspaceModel.hasQueue) {
      queue = workspaceModel.allResources.where((r) => r.isQueued == true).toList();
      final nextItem = queue.removeAt(0);
      await controller.loadUrl(
        urlRequest: URLRequest(
          url: WebUri(nextItem.url!)
        )
      );
    } else {

        String prompt = '';

        
        if (!resource.highlights.isEmpty) {
          prompt = '''
          Articles related to the following excerpts: 
          ${resource.highlights.map((h) => '"${h.text}"').join('\n')}
          ''';

        } else {

          prompt = '''
          Articles related to the following topics: 
          ${resource.tags.map((t) => t).join(', ')}
          ''';

        }
        
        String url = 'https://exa.ai/search?q=' + Uri.encodeComponent(prompt);

        controller.loadUrl(urlRequest: URLRequest(url: WebUri((url))));
    
    }

    setState(() {
      showTabJourney = false;
    });

  }



  Map<String, Resource> resources = {};

  onWebsiteLoadStart(BuildContext context, InAppWebViewController _controller, Uri? uri) async {
    if (!controllerSet) {
      controller = _controller;
      controllerSet = true;
    }

    history  = (await controller.getCopyBackForwardList()) ?? history;

   
    workspaceModel.onTabUpdated(this, controller, uri);
  

    scrollX = 0;
    //updateTabData(context, controller);
  }

  handleNewLink(BuildContext context, Uri? uri, {String? text}) async {
    
  }

  onWebsiteProgressChanged(BuildContext context, InAppWebViewController controller, int progress) {
    
  }

  onWebsiteLoadStop(BuildContext context, InAppWebViewController controller, Uri? uri) async {
    //workspaceModel.onTabUpdated(this, controller, uri);
    workspaceModel.onTabUpdated(this, controller, uri, tabLoaded: true);
    await addJsListeners();
    await addEventHandlers(context);
    await addAnnotationFunctions();
    await getAnnotations();
    resources[resource.url!] = resource;
    
  }

  onUpdateVisitedHistory(InAppWebViewController controller, WebUri? url, bool? isReloaded) async {
    print('updating visit history');
    history  = (await controller.getCopyBackForwardList()) ?? history;
  }

  Future<void>? getSummary() async {
    if (resource.summary != null) return;

    if (resource.text == null) {
      resource.text = await controller.evaluateJavascript(source: 'document.body.innerText');
    }

    final prompt = """
      
      Could you please provide a concise and comprehensive summary of the given text? The summary should capture the main points and key details of the text while conveying the author's intended meaning accurately. Please ensure that the summary is well-organized and easy to read, with clear headings and subheadings to guide the reader through each section. The length of the summary should be appropriate  to capture the main points and key details of the text, without including unnecessary information or becoming overly long.   Then explain the implications of the articles main propositions or arguments. Please go beyond reiterating what the author has identified as being the main implications. Then play devils advocate and address any deficiencies of the article. What is author missing or not considering that undermines their argument. The output should be in the following form:

      Summary:
      Implications:
      Deficiencies:

      ${resource.text}

    """;

    resource.summary = await LLM().mistralChatCompletion(prompt: prompt);

    //workspaceModel.saveResource(resource);
  }

  getAnnotations() async {
    List annotations = [];
    if (resource.annotationsLoaded) {
      annotations = resource.highlights.map((h) {
        return {
          'id': h.id,
          'target': h.target,
          'color': colorMap[workspaceModel.workspace.color ?? 'grey']
        };
      }).toList();
    } else if (resource.highlights.length > 0) {
      final searchResults = await Hypothesis().search(params: {
        'url': resource.url,
        'user': 'acct:malcolmjmr@hypothes.is'
      });

      Map<String, dynamic> annotationMap = {};
      for (final annotation in searchResults) {
        annotationMap[annotation['id']] = annotation;
      }
      for (int i = 0; i < resource.highlights.length; i++) {
        final annotation = annotationMap[resource.highlights[i].id];
        if (annotation != null) {
            final target = annotation['target'][0];
            resource.highlights[i].target = target;
            annotations.add({
              'id': annotation['id'],
              'target': target,
              'color': colorMap[workspaceModel.workspace.color ?? 'grey']
            });
        }
      }
    }

    controller.evaluateJavascript(
      source: JS.createRootDocument(
        sectionCount: 1,
        links: [],
        annotations: annotations,
      ),
    );
  }

  onCloseWindow(BuildContext context, InAppWebViewController controller) {

  }

  int? lastNavigationCheck; 
  Future<NavigationActionPolicy> checkNavigation(BuildContext context, NavigationAction navigationAction) async {

    final url = navigationAction.request.url.toString();
    final prevenNewTabCreation = (
      !navigationAction.isForMainFrame 
      || navigationAction.iosWKNavigationType == IOSWKNavigationType.OTHER 
      || navigationAction.request.url.toString() == 'about:blank'
    );
    if (url == resource.url || resource.isSearch != true || prevenNewTabCreation) {
      return NavigationActionPolicy.ALLOW;
    } else {
      workspaceModel.createNewTab(url: url, viewType: TabViewType.web);
      return NavigationActionPolicy.CANCEL;
    } 
  }

  Future<bool?> onCreateWindow(BuildContext context, InAppWebViewController controller, CreateWindowAction createWindowAction) async {
    workspaceModel.addTabFromNewWindow(resource, createWindowAction.windowId);
    return true;
    //  return showCupertinoModalBottomSheet(
    //       context: context,
    //       builder: (context) {
    //         return Material(
    //           type: MaterialType.transparency,
    //           child: InAppWebView(
    //                 // Setting the windowId property is important here!
    //                 windowId: createWindowAction.windowId,
    //                 initialOptions: InAppWebViewGroupOptions(
    //                     crossPlatform: InAppWebViewOptions(
    //                         //userAgent: 'stash',
    //                     ),
    //                 ),
    //               ),
    //         );
    //       },
    //     );

  }

  addJsListeners() async {

    controller.evaluateJavascript(
        source: JS.scrollListener
          + JS.touchEndListener
          + JS.checkForList
          + JS.clickListener
          + JS.inputListener
          + JS.imageSelectionListener
          
    );
  }

  addAnnotationFunctions() {
    controller.evaluateJavascript(
        source: JS.annotationFunctions + JS.hypothesisHelpers);
  }

  addEventHandlers(BuildContext context) {
    controller.addJavaScriptHandler(
      handlerName: 'onTouchStart',
      callback: onTouchStart,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onLinkSelected',
      callback: onLinkSelected,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onLinkLongPress',
      callback: onLinkLongPress,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentBodyDoubleClicked',
      callback: onPageDoubleClicked,
    );

    controller.addJavaScriptHandler(
      handlerName: 'onTextSelection',
      callback: onTextSelection,
    );

    controller.addJavaScriptHandler(
      handlerName: 'onScrollEnd',
      callback: onScrollEnd,
    );
    controller.addJavaScriptHandler(
      handlerName: 'foundList',
      callback: onFoundList,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onAnnotationTarget',
      callback: onAnnotationTarget,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onInputEntered',
      callback: onInputEntered,
    );
    controller.addJavaScriptHandler(
      handlerName: 'imageSelected',
      callback: onImageSelected,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onHighlightClicked',
      callback: onHighlightClicked,
    );
    controller.addJavaScriptHandler(
      handlerName: 'scrollDirectionChanged',
      callback: onScrollDirectionChanged,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentContent',
      callback: onDocumentContent,
    );


    
  }

  onInputEntered(args) {
    print('input entered');
    final textInput = args[0];
    print(textInput);
    workspaceModel.lastInput = InputData(
      text: textInput, 
      time: DateTime.now().millisecondsSinceEpoch, 
      tabId: id, 
      url: resource.url!
    );
  }

  onFoundList(args) {
    resource.isSearch = true;
  }

  clearSelectedText() async {
    await controller.evaluateJavascript(source: JS.clearSelectedText);
  }

  onScrollEnd(args) async  {
  
    // if (workspaceModel.workspace.title == null)
    // resource.image = await controller.takeScreenshot();

  }

  int scrollX = 0;
  bool scrollingDown = false;
  bool scrollingUp = false;
  int scrollUpStart = 0;
  onScrollChanged(controller, int xPos, int yPos) {
    // scrollX = x;

    // if (!scrollingDown && scrollX < xPos) {
    //   scrollingDown = true;
    // }

    // if (scrollingDown && scrollX > xPos) {
    //   scrollingUp = true;
    // }

    // if (scrollingUp) {
    //   if (scrolling)
    // }

  }

  onLinkLongPress(args) { 
    final title = args[0];
    final url = args[1];
    HapticFeedback.mediumImpact();
    workspaceModel.createNewTab(url: url);
  }

  onLinkSelected(args) {

    Resource resource = Resource(
      title: args[0],
      url: args[1],
    );
    workspaceModel.saveLink(resource);
  }

  onTextSelection(args) {
    final text = args[0] as String;
    if (text.isEmpty) return;

   if (workspaceModel.selectedHighlight != null && text.split(' ').length <= 2) {
      workspaceModel.selectedText = text;
      workspaceModel.tagTabWithSelectedText();
    } else {
      workspaceModel.showTextSelectionModal(text);
    }

  }



  onPageDoubleClicked(args) {
    workspaceModel.setShowToolbar(!workspaceModel.showToolbar);
  }

  removeLastClickedElement() {
    controller.evaluateJavascript(source: 'removeLastClickedElement();');
  }

  checkIfUrlOrTitleHaveChanged() async {
    final url = await controller.getUrl();
    final title = await controller.getTitle();
    //final favIcon = await controller.get

    bool tabChanged = false;

    if (url.toString() != resource.url) {
      // print('url changed');
      // print(url);
      tabChanged = true;
    }

    if (title != resource.title) {
      // print('title changed');
      // print(title);
      tabChanged = true;
    }

    if (tabChanged) {
      workspaceModel.onTabUpdated(this, controller, url, tabLoaded: true);
    }
    
  }

  createHighlight() {
    print('creating highlight');
    controller.evaluateJavascript(source: 'getAnnotationTarget();');
  }

  onAnnotationTarget(args) async {
    print('got annotation target');
    final target = args[0];
    final String uri = target['source'];
    final hypothesisId = await Hypothesis().createAnnotation({
      'document': {
        'title': [resource.title]
      },
      'uri': uri.replaceFirst('.m.', '.'),
      'target': [target],
    });

    workspaceModel.createHighlight(id: hypothesisId);
    

    await controller.evaluateJavascript(
      source: JS.addAnnotation({
        'id': hypothesisId,
        'target': target,
        'color': colorMap[workspaceModel.workspace.color ?? 'grey'],
      }),
    );

    clearSelectedText();
  }

  onImageSelected(args) async {
    final imageUrl = args[0];
    final imageIndex = resource.images.indexWhere((i) => i == imageUrl);
    if (imageIndex == -1) {
      resource.images.add(imageUrl);
    } 

    workspaceModel.showNotification(
      NotificationParams(title: 'Image saved')
    );
  }

  getImageUrl() async {
    final imageUrl = await controller.evaluateJavascript(source: 'getImageUrl();');
    if (imageUrl == null) return;
    final imageIndex = resource.images.indexWhere((i) => i == imageUrl);
    if (imageIndex == -1) {
      resource.images.add(imageUrl);
    }
  }

  onHighlightClicked(args) async {
    workspaceModel.setSelectedHighlight(args[0]);
    if (!workspaceModel.showToolbar) {
      workspaceModel.setShowToolbar(true);
    }
  }

  onScrollDirectionChanged(args) async {
    final direction = args[0];
    if (direction == 'down') {
      if (workspaceModel.selectedHighlight == null) {
        workspaceModel.setShowToolbar(false);
      }
      
    } else if (direction == 'up') {
      workspaceModel.setShowToolbar(true);
    }
  }

  onDocumentContent(args) async {
    resource.article = Article.fromWebView(args[0]);
    final readAloud = context.read(readAloudProvider);
    
    if (readAloud.isPlaying && readAloud.tabModel == this) {
      readAloud.stop();
      readAloud.play(model: this);
    }
  }

  String messageText = '';

  

  stopLoading() async {
    await controller.stopLoading();
    //onWebsiteLoadStop(context, controller, null);
  }

   getRelatedContent({String? searchText, bool searchUrl = false}) {

    SearchServices search = context.read(searchProvider);
    if (resource.url != null || searchText != null) {
      search.getRelatedContent(
        prompt: searchText,
        resource: resource, 
        workspaceModel: workspaceModel
      );
    } else {
      workspaceModel.createNewTab(url: search.getExaSearchUrlforResource(resource: resource));
    }
  }

  List<Resource> relatedResources = [];
  addResourcesToQueue(List<Resource> _resources) {

    /*
      remove duplicates
      rank duplicated resources higher

    */  
    List<Resource> resourcesToAdd = [];
    for (final r in _resources) {
      final resource = resources[r.url!];
      if (resource != null) {
        
      } else {
        if (resources.values.firstWhereOrNull((_r) => _r.title == r.title) == null) {
          resourcesToAdd.add(r);
          resources[r.url!] = r;
        }
        
      }
      
    }
    
    setState(() {
      queue = [
        ...queue.where((r) => r.isQueued == true),
        ...resourcesToAdd,  
        ...queue.where((r) => r.isQueued != true)
      ];
    });

    // if (!showTabJourney) {
    //   goForward();
    // }
  }

  navigateToSection(int sectionIndex) {
    controller.evaluateJavascript(source: JS.scrollToSection(sectionIndex));
  }

  onTouchStart(args) {
    workspaceModel.onTabContentClicked();
    checkIfUrlOrTitleHaveChanged();
    if (workspaceModel.isInEditMode) {
      removeLastClickedElement();
    }
    final windows = context.read(windowsProvider);
    if (windows.isScrollable) {
      windows.setIsScrollable(false);
    }
  }

  List<Resource> tabQueue = [];
  List<Resource> suggestionQueue = [];
  List<Resource> workspaceQueue = [];

  removeItem(Resource resource) {

    setState(() {
      if (resource.isSuggestion) {
        suggestionQueue.removeWhere((s) => s.id == resource.id);
        suggestionQueue = suggestionQueue;
      }
    });
  }

  addItemToQueue(Resource resource) {
    setState(() {
      suggestionQueue.removeWhere((s) => s.id == resource.id);
      tabQueue.removeWhere((s) => s.id == resource.id);

      tabQueue.add(resource);

    });
  }

  List<Prompt> suggestedPrompts = [];


}