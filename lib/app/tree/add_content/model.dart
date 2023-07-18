import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
    selectedItem = items
        .firstWhere((item) => item.type == app.treeView.focus!.content.type);
  }

  cancel() async {
    await app.treeView.deleteFocus();
    app.treeView.setShowAddContentOptions(false);
    //app.menuView.openNavBar();
  }

  updateFocusType(ContentType type, {isIncognito = false}) async {
    app.treeView.updateFocusType(type, isIncognito: isIncognito);
  }

  setSelected(ItemViewModel value) {
    selectedItem = value;
    updateFocusType(selectedItem.type, isIncognito: selectedItem.isIncognito);
    notifyListeners();
  }

  late ItemViewModel selectedItem;

  List<ItemViewModel> items = [
    ItemViewModel('Reference', Icons.link, ContentType.empty),
    ItemViewModel('Search', Icons.travel_explore, ContentType.webSearch),
    //ItemViewModel('Filter', Icons.filter_list, ContentType.filter),
    ItemViewModel('Topic', Icons.topic, ContentType.topic),
    ItemViewModel('Note', Icons.short_text, ContentType.note),
    ItemViewModel('Task', Icons.check, ContentType.task),
    //ItemViewModel('Highlight', Icons.short_text, ContentType.annotation),
    ItemViewModel(
        'Incognito Search', FontAwesomeIcons.userSecret, ContentType.webSearch,
        isIncognito: true, iconSize: 14),
  ];
}

class ItemViewModel {
  String name;
  IconData icon;
  ContentType type;
  bool isIncognito;
  bool isSelected;
  double? iconSize;
  ItemViewModel(
    this.name,
    this.icon,
    this.type, {
    this.isIncognito = false,
    this.isSelected = false,
    this.iconSize,
  });
}
