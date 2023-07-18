import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late Content content;
  ViewModel(this.context) {
    app = context.read(appProvider);
    content = app.treeView.selected.first.content;
    textController = TextEditingController(text: content.name);
  }

  late TextEditingController textController;

  editTitle() {
    showDialog<String>(
      context: context,
      builder: (context) => Material(
        child: TextField(
            controller: textController,
            onSubmitted: (text) => Navigator.of(context).pop(),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
            )),
      ),
    ).then((value) => saveTitle());
  }

  saveTitle() {
    content.name = textController.text;
    app.content.saveContent(content);
  }

  bool loadingTitle = false;
  setLoadingTitle(bool value) {
    loadingTitle = value;
    notifyListeners();
  }

  fetchTitle() async {
    setLoadingTitle(true);
    app.web.headless.getUrlTitle(content.website!.url, (title) async {
      print('got title');
      content.name = title;
      await app.content.saveContent(content);
      //app.web.headless.webView?.dispose();
      setLoadingTitle(false);
    });
  }
}
