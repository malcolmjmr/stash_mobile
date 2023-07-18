import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' show URLRequest;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/logger_provider.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:collection/collection.dart';
import 'package:stashmobile/models/content/visits.dart';
import 'dart:convert';

final appViewProvider = ChangeNotifierProvider<AppViewModel>((ref) {
  final contentManager = ref.watch(contentProvider);
  return AppViewModel(
      contentManager: contentManager, webView: ref.watch(webManagerProvider));
});

enum ContentViewType {
  search,
  links,
  website,
  article,
  document,
  book,
  audio,
  tags,
  ratings,
  annotations,
  highlight,
  note,
  task,
  filter,
}

class AppViewModel extends ChangeNotifier {
  printRoot() {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(root.toJson());
    print(prettyprint);
  }

  ContentManager contentManager;
  WebManager webView;
  AppViewModel({
    required this.contentManager,
    required this.webView,
  }) {
    load();
  }

  Content get root => contentManager.getContentById(state.contentId);

  ViewState get state => history[locationIndex];

  load() {
    if (contentManager.isLoading) return;
    setInitialPages();
    //webViewIsOpen = false;
    setIsLoading(false);
  }

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  setInitialPages() {
    history.addAll([
      ViewState(contentId: contentManager.root.id),
      ViewState(contentId: contentManager.dailyPage.id),
    ]);
    locationIndex = 1;
  }

  List<ViewState> history = [];
  int locationIndex = 0;

  bool get canGoBack => locationIndex != 0;
  goBack(BuildContext context, {notify = true, int? location}) async {
    if (!canGoBack) return;
    final previousIndex = locationIndex;
    if (location != null)
      locationIndex = location;
    else
      locationIndex--;

    webViewChangesOnOpen(context, previousIndex);
    treeViewChangesOnOpen(context);
    menuViewChangesOnOpen(context);
    printHistory(context);
    if (notify) notifyListeners();
  }

  bool get canGoForward => locationIndex < history.length - 1;
  goForward(BuildContext context, {notify = true}) async {
    final previousIndex = locationIndex;
    if (!canGoForward) return;
    locationIndex++;
    webViewChangesOnOpen(context, previousIndex);
    treeViewChangesOnOpen(context);
    menuViewChangesOnOpen(context);
    printHistory(context);
    if (notify) notifyListeners();
  }

  open(
    BuildContext context,
    Content content, {
    ContentViewType view = ContentViewType.links,
    bool isNewWebPage = false,
  }) async {
    final previousIndex = locationIndex;
    if (state.contentId != content.id) {
      final viewState = ViewState(
          contentId: content.id,
          view: isNewWebPage ? ContentViewType.website : view);
      history = history.sublist(0, locationIndex + 1);
      history.add(viewState);
      locationIndex = history.length - 1;
    }

    updateVisitHistory(context);
    webViewChangesOnOpen(context, previousIndex);
    treeViewChangesOnOpen(context);
    menuViewChangesOnOpen(context);
    printHistory(context);
    notifyListeners();
  }

  openMainView(BuildContext context, content) {
    ContentViewType view = ContentViewType.note;
    if (content.type == ContentType.tag) {
      // show instances
    } else if (content.type == ContentType.annotation) {
      // show highlight
      view = ContentViewType.highlight;
    } else if (content.type == ContentType.filter) {
      view = ContentViewType.filter;
    } else if (content.type == ContentType.topic) {
      // show links
      view = ContentViewType.links;
      context.read(treeViewProvider).resetScrollPosition();
    } else if ([
      ContentType.webArticle,
      ContentType.webSearch,
      ContentType.webSite
    ].contains(content.type)) {
      // show webview
      view = ContentViewType.website;
    }
    open(context, content, view: view);
  }

  updateVisitHistory(BuildContext context) {
    if (root.visits == null)
      root.visits = ContentVisits();
    else
      root.visits!.addNewVisit();
    context.read(contentProvider).saveContent(root, updated: false);
  }

  printHistory(BuildContext context) {
    context.read(loggerProvider).i(history
        .map((s) =>
            '${history.indexOf(s) == locationIndex ? '=>' : ''}${s.toString()}')
        .toList());
  }

  ContentViewType get view => history[locationIndex].view;

  setView(BuildContext context, ContentViewType value) {
    history[locationIndex].view = value;
    printHistory(context);
    if (value == ContentViewType.website)
      openWebView();
    else
      closeWebView();
    //webViewChangesOnOpen(context, locationIndex);
    notifyListeners();
  }

  webViewChangesOnOpen(BuildContext context, int previousLocationIndex) async {
    final previousState = history[previousLocationIndex];

    final noWebViewPresent = previousState.view != ContentViewType.website &&
        state.view != ContentViewType.website;
    if (noWebViewPresent) return;

    final closingWebView = previousState.view == ContentViewType.website &&
        state.view != ContentViewType.website;
    if (closingWebView) {
      closeWebView();
    } else {
      openWebView();
    }
  }

  bool webViewIsOpen = false;
  openWebView() async {
    if (!webViewIsOpen) webViewIsOpen = true;
    final webHistory = await webView.controller.getCopyBackForwardList();
    final historyItem = webHistory?.list
        ?.firstWhereOrNull((item) => item.url == Uri.parse(root.url!));
    if (historyItem != null) {
      webView.isReloading = true;
      await webView.controller.goTo(historyItem: historyItem);
      //await webView.controller.reload();
    } else {
      await webView.controller.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(root.url ?? '')),
      );
    }
    notifyListeners();
  }

  closeWebView() {
    webViewIsOpen = false;
    notifyListeners();
  }

  treeViewChangesOnOpen(BuildContext context, {bool reload = false}) {
    final treeView = context.read(treeViewProvider);
    treeView.reset(context);
  }

  menuViewChangesOnOpen(BuildContext context) {
    final menuView = context.read(menuViewProvider);
    menuView.openNavBar();
  }

  bool showHeader = true;
  setShowHeader(bool value) {
    showHeader = value;
    notifyListeners();
  }

  updateHistoryFromWebView(Content content) {
    history
        .add(ViewState(contentId: content.id, view: ContentViewType.website));
    locationIndex = history.length - 1;
  }
}

class ViewState {
  ContentViewType view;
  String contentId;
  List<String> filters = [];
  ViewState({required this.contentId, this.view = ContentViewType.links});
  @override
  String toString() {
    // TODO: implement toString
    return '<ViewState: $contentId $view>';
  }
}
