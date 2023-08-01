import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:stashmobile/app/providers/resource.dart';





import 'package:stashmobile/app/web/event_handlers.dart';
import 'package:stashmobile/app/web/js.dart';



import '../../models/resource.dart';
import 'headless.dart';


class WebManager extends ChangeNotifier {
  // Todo:
  // - separate view model code from event handler code
  // - create helpers for managing links
  // -

  ResourceManager resourceManager;
  WebManager({required this.resourceManager});

  // WebViewModel
  // EventHandlers

  ClickedLink? lastLink;
  bool goToSection = false;
  bool isReloading = false;

  List<ClickedLink> clickedLinks = [];


  late InAppWebViewController controller;

  setController(InAppWebViewController newController) {
    controller = newController;
  }

  Future<String?> getFaviconUrl() async {
    final favIcons = await controller.getFavicons();
    return favIcons.isNotEmpty ? favIcons.first.url.toString() : null;
  }

  bool isNotAWebsite(Resource? content) =>
      content == null || content.url == null;

  onWebsiteLoadStart(BuildContext context, Uri? uri) async {
    handleNewLink(context, uri);
  }

  handleNewLink(BuildContext context, Uri? uri, {String? text}) async {
 
  }

  onWebsiteProgressChanged(BuildContext context, int progress) {
    
  }

  onWebsiteLoadStop(BuildContext context) async {
   
  }

  addEventHandlers(BuildContext context) {
    controller.addJavaScriptHandler(
      handlerName: 'onLinkSelected',
      callback: (args) => WebEventHandlers.onLinkSelected(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onTextSelection',
      callback: (args) => WebEventHandlers.onTextSelection(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onLinkClicked',
      callback: (args) => WebEventHandlers.onLinkClicked(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentInfo',
      callback: (args) => WebEventHandlers.onDocumentInfo(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentResource',
      callback: (args) => WebEventHandlers.onDocumentContent(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onAnnotationTarget',
      callback: (args) => WebEventHandlers.onAnnotationTarget(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onHighlightClicked',
      callback: (args) => WebEventHandlers.onHighlightClicked(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onHighlightDoubleClicked',
      callback: (args) =>
          WebEventHandlers.onHighlightDoubleClicked(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onDocumentBodyClicked',
      callback: (args) => WebEventHandlers.onDocumentBodyClicked(context, args),
    );
    controller.addJavaScriptHandler(
      handlerName: 'onScrollEnd',
      callback: (args) => WebEventHandlers.onScrollEnd(context, args),
    );
  }

  addJsListeners() {
    controller.evaluateJavascript(
        source: JS.touchEndListener +
            JS.scrollListener +
            JS.focusListener +
            JS.clickListener +
            JS.scrollListener);
  }

  addAnnotationFunctions() {
    controller.evaluateJavascript(
        source: JS.annotationFunctions + JS.hypothesisHelpers);
  }

  addJsDocument(BuildContext context, Resource content) {
   
  }

  String selectedText = '';

  getSelectionTarget() async {
    await controller.evaluateJavascript(source: JS.getAnnotationTarget);
  }

  Resource? selectedAnnotation;

  updateAnnotation(Resource content) async {
   
  }

  addSavedLink(Resource content) async {
    
  }

  updateLink(Resource content) async {
    
  }

  clearSelectedText() async {
    selectedText = '';
    await controller.evaluateJavascript(source: JS.clearSelectedText);
  }

  navigateToSection(int sectionIndex) {
    controller.evaluateJavascript(source: JS.scrollToSection(sectionIndex));
  }

  HeadlessWebView headless = HeadlessWebView();

  List<String> getGoogleSearchSuggestions() {
    return [];
  }

  List<SearchResult> getGoogleSearchResults() {
    return [];
  }
}

class ClickedLink {
  String url;
  String? id;
  ClickedLink({required this.url, this.id});
}

class SearchResult {
  String text;
  String link;
  SearchResult(this.text, this.link);
}
