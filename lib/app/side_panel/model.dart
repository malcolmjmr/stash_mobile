import 'package:flutter/material.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/side_panel/collections/view.dart';
import 'package:stashmobile/app/side_panel/settings/view.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'playlist/view.dart';
import 'explore/view.dart';

class MenuViewModel extends ChangeNotifier {
  BuildContext context;
  late User user;
  MenuViewModel(this.context) {
    user = context.read(sessionProvider).user!;
  }

  double headerHeight = 100;
  double get headerWidgetSize => headerHeight * .9;

  PageController pageController = PageController();

  List<MenuOption> pages = [
    MenuOption(
      icon: Icons.collections_bookmark_rounded,
      name: 'Collections',
      view: () => CollectionsView(),
    ),
    MenuOption(
      icon: Icons.headset,
      name: 'Playlist',
      view: () => PlaylistView(),
    ),
    MenuOption(
      icon: Icons.public,
      name: 'Explore',
      view: () => ExploreView(),
    ),
    MenuOption(
      icon: Icons.settings,
      name: 'Settings',
      view: () => SettingsView(),
    )
  ];

  MenuOption get page => pages[pageIndex];
  int pageIndex = 0;

  setPage(MenuOption selectedPage) {
    pageIndex = pages.indexOf(selectedPage);
    notifyListeners();
    pageController.jumpToPage(pageIndex);
  }

  bool showSearch = false;
  openSearch() {
    showSearch = true;
    notifyListeners();
  }
}

class MenuOption {
  String name;
  IconData icon;
  Widget Function() view;
  List<SubMenuOption>? subOptions;
  MenuOption({
    required this.icon,
    required this.name,
    required this.view,
    this.subOptions,
  });
}

class SubMenuOption {
  String name;
  IconData icon;
  String viewRoute;

  SubMenuOption(
      {required this.icon, required this.name, required this.viewRoute});
}
