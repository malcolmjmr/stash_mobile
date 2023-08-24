

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/event_handlers.dart';
import 'package:stashmobile/app/web/js.dart';
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

    print('new tab');
    print(initialResource?.url);
  }

  bool loaded = false;

  Future<String?> getFaviconUrl(InAppWebViewController controller) async {
    final favIcons = await controller.getFavicons();
    return favIcons.isNotEmpty ? favIcons.first.url.toString() : null;
  }

  setController(InAppWebViewController newController) {
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
    //workspaceModel.onTabUpdated(this, controller, uri);
    
    workspaceModel.onTabUpdated(this, controller, uri);
    await addJsListeners();
    await addEventHandlers(context);
  }

  onCloseWindow(BuildContext context, InAppWebViewController controller) {

  }

  Future<NavigationActionPolicy> checkNavigation(BuildContext context, NavigationAction navigationAction) async {
    final url = navigationAction.request.url.toString();
    print('checkingNavigation');
    print(url);
    print(resource.url);
    if (url == resource.url || resource.isSearch != true) {
      return NavigationActionPolicy.ALLOW;
    } else {
      workspaceModel.createNewTabFromUrl(url);
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
    print('adding js');

    controller.evaluateJavascript(
        source: JS.scrollListener
          + JS.touchEndListener
          + JS.checkForList
          
    );
  }

  addEventHandlers(BuildContext context) {
    controller.addJavaScriptHandler(
      handlerName: 'onLinkSelected',
      callback: onLinkSelected,
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
  }

  onFoundList(args) {
    resource.isSearch;
  }

  clearSelectedText(controller) async {
    await controller?.evaluateJavascript(source: JS.clearSelectedText);
  }

  onScrollEnd(args) async  {
    print('scroll end');

    resource.image = await controller.takeScreenshot();

  }

  onLinkClicked(args) {
    print('link clicked');
  }

  onLinkLongPress(args) {
    print('link long pressed');
  }

  onLinkSelected(args) {
    print('link selected');
    print(args);

    Resource resource = Resource(
      title: args[0],
      url: args[1],
    );

    resource.isQueued = true;

    workspaceModel.saveResource(resource);

    HapticFeedback.mediumImpact();
  }

  onTextSelection(args) {
    print('text selected');
  }

}