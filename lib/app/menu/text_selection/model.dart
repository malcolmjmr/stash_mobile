import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';

import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/web_search.dart';

class TextSelectionMenuModel {
  BuildContext context;
  late AppController app;
  TextSelectionMenuModel(this.context) {
    app = context.read(appProvider);
  }

  onCancel() async {
    await app.web.clearSelectedText();
    app.menuView.openNavBar();
  }

  onExpand() {}

  onSearch() async {
    final searchText = app.web.selectedText;
    final newContent = await app.content.addLinkedContent(
      parent: app.viewModel.root,
      child: Content(
        type: ContentType.webSearch,
        name: searchText,
        webSearch: WebSearchFields(
          query: searchText,
          url: Uri.parse('https://www.google.com/search?q=$searchText')
              .toString(),
        ),
      ),
    );
    Navigator.of(context).pop();
    app.viewModel.open(context, newContent, view: ContentViewType.website);
  }

  onAddHighlight() async => app.web.getSelectionTarget();

  bool get showAddTag => app.web.selectedText.length < 40;

  onAddTag() async {
    // Todo: show tag in webview
    final text = app.web.selectedText;
    app.tagsView.addNewTag(text);
    await app.web.clearSelectedText();
    app.menuView.setSubMenuView(SubMenuView.tags);
  }

  bool shouldShowAddFieldValue() {
    return true;
  }

  onAddFieldValue() {}

  bool shouldShowAddVocabulary() {
    return true;
  }

  onAddVocabulary() {}
}
