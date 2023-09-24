

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stashmobile/app/web/js.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/services/hypothesis.dart';

class TabViewModel {
 
  late InAppWebViewController controller;

  late Resource resource;
  WorkspaceViewModel workspaceModel;

  String id = UniqueKey().toString();

  TabViewModel({required this.workspaceModel, Resource? initialResource}) {
    if (initialResource != null) {
      resource = initialResource;
    } else {
      resource = Resource(title: 'New Tab', url: 'https://www.google.com/');
    }
  }

  bool loaded = false;

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
 
  onWebsiteLoadStart(BuildContext context, InAppWebViewController _controller, Uri? uri) async {
    if (!controllerSet) {
      controller = _controller;
      controllerSet = true;
    }
    workspaceModel.onTabUpdated(this, controller, uri);
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
      workspaceModel.createNewTab(url: url);
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
          
    );
  }

  addAnnotationFunctions() {
    controller.evaluateJavascript(
        source: JS.annotationFunctions + JS.hypothesisHelpers);
  }

  addEventHandlers(BuildContext context) {
    controller.addJavaScriptHandler(
      handlerName: 'onLinkSelected',
      callback: onLinkSelected,
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentBodyClicked',
      callback: onPageClicked,
    );

    controller.addJavaScriptHandler(
      handlerName: 'onTextSelection',
      callback: onTextSelection,
    );

    controller.addJavaScriptHandler(
      handlerName: 'onLinkClicked',
      callback: onLinkClicked,
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
    resource.isSearch;
  }

  clearSelectedText(controller) async {
    await controller?.evaluateJavascript(source: JS.clearSelectedText);
  }

  onScrollEnd(args) async  {
  
    if (workspaceModel.workspace.title == null)
    resource.image = await controller.takeScreenshot();

  }

  onLinkClicked(args) {
    print('link clicked');
    final title = args[0];
    final url = args[0];
  }

  onLinkLongPress(args) {
    print('link long pressed');
  }

  onLinkSelected(args) {
    print('link selected');

    Resource resource = Resource(
      title: args[0],
      url: args[1],
    );
    workspaceModel.saveLink(resource);
  }

  onTextSelection(args) {

    final text = args[0] as String;
    if (text.isNotEmpty)
    workspaceModel.showTextSelectionModal(text);
  }

  onPageClicked(args) {
    workspaceModel.onTabContentClicked();
    checkIfUrlOrTitleHaveChanged();
    
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
        'color': workspaceModel.workspace.color,
      }),
    );
  }
}