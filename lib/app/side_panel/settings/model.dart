import 'package:flutter/material.dart';
import 'package:stashmobile/routing/app_router.dart';

class SettingsViewModel {
  late List<MenuItem> menuItems;
  SettingsViewModel() {
    createMenuItems();
  }

  createMenuItems() {
    menuItems = [
      MenuItem('Connected Apps', Icons.sync_alt, AppRoutes.connectedApps),
    ];
  }
}

class MenuItem {
  String title;
  IconData icon;
  String route;

  MenuItem(this.title, this.icon, this.route);
}
