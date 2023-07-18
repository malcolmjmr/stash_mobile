import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:stashmobile/app/menu/model.dart';

import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/scent/colors.dart';

import 'package:stashmobile/app/web/event_handlers.dart';
import 'package:stashmobile/app/web/js.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/models/content/type_fields/website.dart';

import 'headless.dart';
import 'links.dart';

class WebManager extends ChangeNotifier {
  // Todo:
  // - separate view model code from event handler code
  // - create helpers for managing links
  // -

  WebManager({required this.contentManager});

  // WebViewModel
  // EventHandlers

  ClickedLink? lastLink;
  bool goToSection = false;
  bool isReloading = false;

  List<ClickedLink> clickedLinks = [];

  ContentManager contentManager;
  late InAppWebViewController controller;

  setController(InAppWebViewController newController) {
    controller = newController;
  }

  Future<String?> getFaviconUrl() async {
    final favIcons = await controller.getFavicons();
    return favIcons.isNotEmpty ? favIcons.first.url.toString() : null;
  }

  bool isNotAWebsite(Content? content) =>
      content == null || content.url == null;

  onWebsiteLoadStart(BuildContext context, Uri? uri) async {
    handleNewLink(context, uri);
  }

  handleNewLink(BuildContext context, Uri? uri, {String? text}) async {
    final app = context.read(appProvider);
    String url = LinkManager.createUrlFromUri(uri);
    bool urlIsIrrelevant = lastLink?.url == url ||
        url.isEmpty ||
        url == 'about:blank' ||
        url == app.viewModel.root.url;

    if (urlIsIrrelevant) {
      return;
    }

    final parent = app.viewModel.root;
    Content? content = contentManager.getContentByUrl(url);
    if (content == null)
      content = Content(
        name: LinkManager.createContentName(
            parent: parent, uri: uri!, text: text),
        type: ContentType.webSite,
        website: WebsiteFields(url: url),
      );

    bool notYetLinked = !(content.links?.back?.contains(parent) ?? false);
    if (notYetLinked)
      await contentManager.addLinkedContent(
        parent: parent,
        child: content,
      );

    lastLink = ClickedLink(url: url, id: content.id);
    app.viewModel.open(context, content, isNewWebPage: true);
  }

  onWebsiteProgressChanged(BuildContext context, int progress) {
    context.read(menuViewProvider).setWebPageProgress(progress / 100);
  }

  onWebsiteLoadStop(BuildContext context) async {
    final app = context.read(appProvider);
    app.menuView.setWebPageProgress(1);

    final webViewUrl = (await controller.getUrl()).toString();
    final content = app.viewModel.root;
    if (isNotAWebsite(content)) return;

    if (content.website?.scrollPosition != null)
      controller.scrollTo(x: 0, y: content.website!.scrollPosition!);

    print('is reloading web page: $isReloading');
    if (!isReloading) {
      addEventHandlers(context);
      addJsListeners();
      addAnnotationFunctions();
      addJsDocument(context, content);
    } else {
      isReloading = false;
    }

    //handleSubscription(context);

    bool needToAddIcon = webViewUrl == content.url && content.iconUrl == null;
    if (needToAddIcon) {
      content.iconUrl = await getFaviconUrl();
      contentManager.saveContent(content);
    }

    if (goToSection) {
      goToSection = false;
      navigateToSection(
          app.viewModel.root.webArticle?.article?.currentSection?.index ?? 1);
    }
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
      handlerName: 'onDocumentContent',
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

  addJsDocument(BuildContext context, Content content) {
    final app = context.read(appProvider);
    final children = app.content.getContentByIds(content.links?.forward ?? []);
    final contentUri = Uri.parse(content.url!);
    final links = children
        .where(
      (c) => [
        ContentType.webSearch,
        ContentType.webSite,
      ].contains(c.type),
    )
        .map((c) {
      String href = c.url!;
      final uri = Uri.parse(href);
      if (uri.authority == contentUri.authority) href = uri.path;
      return {
        'id': c.id,
        'text': c.title,
        'href': href,
        'color': PriorityColors.getColorHexFromPriority(c.ratings?.value ?? 0),
      };
    }).toList();

    final annotations = children
        .where(
      (c) => c.type == ContentType.annotation,
    )
        .map((c) {
      return {
        'id': c.id,
        'target': c.annotation!.target,
        'color': PriorityColors.getColorHexFromPriority(c.ratings?.value ?? 0),
      };
    }).toList();

    controller.evaluateJavascript(
      source: JS.createRootDocument(
        sectionCount: content.webArticle?.article?.sections.length ?? 1,
        links: links,
        annotations: annotations,
      ),
    );
  }

  String selectedText = '';

  getSelectionTarget() async {
    await controller.evaluateJavascript(source: JS.getAnnotationTarget);
  }

  Content? selectedAnnotation;

  updateAnnotation(Content content) async {
    final annotationData = {
      'id': content.id,
      'target': content.annotation!.target,
      'color':
          PriorityColors.getColorHexFromPriority(content.ratings?.value ?? 0),
    };

    await controller.evaluateJavascript(
        source: JS.updateAnnotation(annotationData));
  }

  addSavedLink(Content content) async {
    final linkData = {
      'id': content.id,
      'href': content.website?.url,
      'color':
          PriorityColors.getColorHexFromPriority(content.ratings?.value ?? 0)
    };
    await controller.evaluateJavascript(source: JS.addSavedLink(linkData));
  }

  updateLink(Content content) async {
    final linkData = {
      'id': content.id,
      'color':
          PriorityColors.getColorHexFromPriority(content.ratings?.value ?? 0)
    };
    await controller.evaluateJavascript(source: JS.updateSavedLink(linkData));
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
