
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/users.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/models/content/content.dart';


final menuViewProvider = ChangeNotifierProvider<MenuViewModel>((ref) {
  return MenuViewModel(userManager: ref.watch(userProvider));
});

enum MenuState {
  closed,
  navigationBar,
  addContent,
  menu,
  searchOptions,
  recastOptions,
  textSelection,
  highlight,
  notifications,
}

class MenuViewModel extends ChangeNotifier {
  UserManager userManager;
  MenuViewModel({required this.userManager});

  addNodeToTree(BuildContext context) async {
    // Todo: handle action from webview
    final app = context.read(appProvider);
    if (app.viewModel.view == ContentViewType.website) {
      app.viewModel.setView(context, ContentViewType.links);
    }
    app.menuView.setState(MenuState.closed);
    app.treeView.setExpandAll(false);
    app.treeView.addNodeToTree();
  }

  bool isExpanded = false;

  setState(MenuState value) {
    state = value;
    notifyListeners();
  }

  openAddElementMenu() {
    state = MenuState.addContent;
    notifyListeners();
  }

  openCollapsedMenu(BuildContext context) {
    state = MenuState.menu;
    notifyListeners();
  }

  SubMenuView? subMenuView;
  setSubMenuView(SubMenuView? view) {
    if (view != null && state != MenuState.menu) state = MenuState.menu;
    subMenuView = view;
    notifyListeners();
  }

  closeMenu(BuildContext context) {
    context.read(treeViewProvider).clearSelected();
    openNavBar();
  }

  int getSubLinkCount(BuildContext context) =>
      context.read(appProvider).treeView.rootNode.children.length;

  bool getShowViewIcon(BuildContext context) {
    final appView = context.read(appViewProvider);
    final isInTreeView = appView.view == ContentViewType.links;
    final locationHasOtherViews =
        ![ContentType.topic, ContentType.root].contains(appView.root.type);
    return isInTreeView && locationHasOtherViews;
  }

  viewTree(BuildContext context) =>
      context.read(appViewProvider).setView(context, ContentViewType.links);

  viewDocument(BuildContext context) {
    final app = context.read(appProvider);
    final content = app.viewModel.root;
    ContentViewType? view;
    switch (content.type) {
      case ContentType.webSearch:
      case ContentType.webSite:
        view = ContentViewType.website;
        break;
      case ContentType.annotation:
        view = ContentViewType.highlight;
        break;
      default:
        view = ContentViewType.links;
    }
    app.viewModel.setView(context, view);
  }

  MenuState state = MenuState.navigationBar;
  openNavBar() {
    if (state == MenuState.navigationBar) return;
    if (subMenuView != null) subMenuView = null;
    state = MenuState.navigationBar;
    notifyListeners();
  }

  close() {
    state = MenuState.closed;
    notifyListeners();
  }

  openSearchOptions() {
    state = MenuState.searchOptions;
    notifyListeners();
  }

  openRecastOptions() {
    state = MenuState.recastOptions;
  }

  bool recastOptionsOpen = true;
  setRecastOptionsOpen(bool value) {
    recastOptionsOpen = value;
    notifyListeners();
  }

  refresh() {
    notifyListeners();
  }

  double webPageProgress = 0;
  setWebPageProgress(double value) {
    webPageProgress = value;
    notifyListeners();
  }

  bool showPlayBar = false;
  setShowPlayBar(bool value) {
    showPlayBar = value;
    notifyListeners();
  }

  /*
  space home page

  navigation
  - back
  - forward
  - up
  - down

  views
  - links
  - tags
  - ratings
  - document
  - web
  - highlights
  - comments
  - calendar (set reminder)
  - audio

  actions
  - mark complete
  - delete
   */
}

class NavigationOption {
  String name;
  IconData icon;
  List<SubItemModel> subItemModels;

  NavigationOption({
    required this.name,
    required this.icon,
    required this.subItemModels,
  });

  List<SubItemModel> getRelevantSubItems(BuildContext context) => subItemModels
      .where((item) => item.condition == null || item.condition!.call(context))
      .toList();
}

enum SubMenuView {
  rating,
  tags,
  fields,
  play,
  reminder,
  share,
  article,
  saveForLater,
}

class SubItemModel {
  String name;
  IconData icon;
  Function(BuildContext)? onTap;
  Function(BuildContext)? onLongPress;
  bool Function(BuildContext)? condition;
  String Function(BuildContext)? value;
  SubItemModel({
    required this.name,
    required this.icon,
    this.onTap,
    this.onLongPress,
    this.condition,
  });
}
