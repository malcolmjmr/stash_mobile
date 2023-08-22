

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class TabViewModel {
 
  late InAppWebViewController controller;

  late Resource resource;
  WorkspaceViewModel workspaceModel;

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

  setController(InAppWebViewController newController) {
    print('web view created');
    print(resource.title);
    controller = newController;
  }

  bool isNotAWebsite(Resource? content) =>
      content == null || content.url == null;
 
  onWebsiteLoadStart(BuildContext context, InAppWebViewController controller, Uri? uri) async {
    workspaceModel.onTabUpdated(this, controller, uri);
    //updateTabData(context, controller);
  }

  handleNewLink(BuildContext context, Uri? uri, {String? text}) async {
    
  }

  onWebsiteProgressChanged(BuildContext context, InAppWebViewController controller, int progress) {
    
  }

  onWebsiteLoadStop(BuildContext context, InAppWebViewController controller, Uri? uri) async {
    workspaceModel.onTabUpdated(this, controller, uri);
  }

  onCloseWindow(BuildContext context, InAppWebViewController controller) {

  }

  onCreateWindow(BuildContext context, InAppWebViewController controller, CreateWindowAction createWindowAction) {
    workspaceModel.addTabFromNewWindow(resource, createWindowAction.windowId);
  }

  // addEventHandlers(BuildContext context, controller) {
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onLinkSelected',
  //     callback: (args) => WebEventHandlers.onLinkSelected(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onTextSelection',
  //     callback: (args) => WebEventHandlers.onTextSelection(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onLinkClicked',
  //     callback: (args) => WebEventHandlers.onLinkClicked(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onDocumentInfo',
  //     callback: (args) => WebEventHandlers.onDocumentInfo(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onDocumentResource',
  //     callback: (args) => WebEventHandlers.onDocumentContent(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onAnnotationTarget',
  //     callback: (args) => WebEventHandlers.onAnnotationTarget(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onHighlightClicked',
  //     callback: (args) => WebEventHandlers.onHighlightClicked(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onHighlightDoubleClicked',
  //     callback: (args) =>
  //         WebEventHandlers.onHighlightDoubleClicked(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onDocumentBodyClicked',
  //     callback: (args) => WebEventHandlers.onDocumentBodyClicked(context, args),
  //   );
  //   controller?.addJavaScriptHandler(
  //     handlerName: 'onScrollEnd',
  //     callback: (args) => WebEventHandlers.onScrollEnd(context, args),
  //   );
  // }

  // addJsListeners() {
  //   controller?.evaluateJavascript(
  //       source: JS.touchEndListener +
  //           JS.scrollListener +
  //           JS.focusListener +
  //           JS.clickListener +
  //           JS.scrollListener);
  // }

  // addAnnotationFunctions() {
  //   controller?.evaluateJavascript(
  //       source: JS.annotationFunctions + JS.hypothesisHelpers);
  // }

  // addJsDocument(BuildContext context, Resource content) {
   
  // }

  // String selectedText = '';

  // getSelectionTarget(controller) async {
  //   await controller?.evaluateJavascript(source: JS.getAnnotationTarget);
  // }


  // clearSelectedText(controller) async {
  //   selectedText = '';
  //   await controller?.evaluateJavascript(source: JS.clearSelectedText);
  // }



}