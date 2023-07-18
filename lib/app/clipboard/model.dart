import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/app/tree/node/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clipboardProvider = ChangeNotifierProvider(
    (ref) => Clipboard(contentManager: ref.watch(contentProvider)));

class Clipboard extends ChangeNotifier {
  ContentManager contentManager;
  Clipboard({required this.contentManager});
  bool isOpen = false;
  setIsOpen(bool value) {
    isOpen = value;
    notifyListeners();
  }

  List<Content> items = [];

  removeItem(Content content) {
    items.removeWhere((item) => content.id == item.id);
    notifyListeners();
  }

  clear() {
    items.clear();
    notifyListeners();
  }

  pasteToSelected(BuildContext context, {Content? content}) async {
    if (content == null && items.isEmpty) return;

    final treeView = context.read(treeViewProvider);
    if (treeView.selected.isEmpty) {
      await contentManager.addLinkedContent(
          parent: treeView.rootNode.content, child: content ?? items.first);
    } else {
      for (TreeNodeViewModel selected in treeView.selected) {
        await contentManager.addLinkedContent(
            parent: selected.content, child: content ?? items.first);
      }
    }
    treeView.reloadTree();
  }

  copySelected(BuildContext context) {
    final treeView = context.read(treeViewProvider);
    if (treeView.selected.isEmpty) {
      copyContent(treeView.rootNode.content);
    } else {
      for (TreeNodeViewModel selected in treeView.selected)
        copyContent(selected.content);
    }
  }

  copyContent(Content content) {
    if (!items.any((item) => item.id != content.id)) {
      items.insert(0, content);
    }
  }

  cutSelected(BuildContext context) async {
    final treeView = context.read(treeViewProvider);
    //final menuView
    if (treeView.selected.isEmpty) return;

    for (TreeNodeViewModel selected in treeView.selected) {
      await contentManager.removeLinkedContent(
          parent: selected.parent!.content, child: selected.content);
      copyContent(selected.content);
    }

    treeView.reloadTree();
  }
}
