import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:flutter/material.dart';

class ContentTitleModel extends ChangeNotifier {
  Content content;
  BuildContext context;
  late ContentManager contentManager;
  late MenuViewModel menuView;
  late AppViewModel appView;
  ContentTitleModel(this.content, this.context) {
    contentManager = context.read(contentProvider);
    menuView = context.read(menuViewProvider);
    appView = context.read(appViewProvider);
    addFocusListener();
    textController = TextEditingController();
    textController.text = content.name ?? '';
  }

  FocusNode focusNode = FocusNode();
  late TextEditingController textController;
  bool keyboardIsOpen = false;
  addFocusListener() {
    focusNode.addListener(() {
      if (focusNode.hasFocus != keyboardIsOpen) {
        keyboardIsOpen = focusNode.hasFocus;
        if (keyboardIsOpen) {
          print('closing keyboard');
          menuView.close();
        } else {
          menuView.openNavBar();
        }
      }
    });
  }

  onNameUpdated(String name) => null;

  onNameSubmitted(String name) async {
    // bool isNew = content.isNew == true;
    //
    // if (isNew && name.isEmpty) {
    //   await contentManager.deleteContent(content);
    //   contentViewModel.notifyListeners();
    //   notifyListeners();
    //   return;
    // }
    //
    // if (content.type == ContentType.webSearch) {
    //   final searchUrl = Uri.parse('https://www.google.com/search?q=$name');
    //   content.webSearch = WebSearchFields(
    //     query: name,
    //     url: searchUrl.toString(),
    //   );
    // }
    //
    // content.name = name;
    // content.isNew = false;
    // content.editName = false;
    // await contentManager.saveContent(content);
    //
    // if (isNew) {
    //   bool isContentThatShouldBeOpened =
    //       content.type == ContentType.webSearch ||
    //           content.type == ContentType.topic;
    //   if (isContentThatShouldBeOpened) AppRouter.openContent(context, content);
    //
    //   if (content.type == ContentType.note) {
    //     contentManager.addLinkedContent(
    //       context: context,
    //       type: ContentType.note,
    //     );
    //   } else if (content.type == ContentType.task) {
    //     contentManager.addLinkedContent(
    //       context: context,
    //       type: ContentType.task,
    //     );
    //   } else if (content.type == ContentType.filter) {
    //     Navigator.of(context).pushNamed(AppRoutes.filterSettings);
    //   }
    // } else {
    //   focusNode.unfocus();
    // }
    // notifyListeners();
  }

  setEditName(bool value) {
    content.editName = true;
    notifyListeners();
  }
}
