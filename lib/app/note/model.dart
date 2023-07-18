import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';

class NoteViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late Content content;
  NoteViewModel(this.context) {
    app = context.read(appProvider);
    initializeContent();
    initializeTextController();
  }

  initializeContent() {
    if (app.treeView.selected.length == 1)
      content = app.treeView.selected.first.content;
    else
      content = app.treeView.rootNode.content;

    //if (content.note == null) content.note = NoteFields();
  }

  initializeTextController() {
    String text = '';
    if (content.type == ContentType.note) {
      text = content.note!.body;
    } else if (content.type == ContentType.annotation) {
      text = content.annotation!.note ?? '';
    }
    textController = TextEditingController(text: text);
  }

  FocusNode textFocusNode = FocusNode();
  late TextEditingController textController;
  updateBody(String text) {
    content.note!.body = text;
  }

  // bool keyboardIsOpen = false;
  // addFocusListener() {
  //   textFocusNode.addListener(() {
  //     if (textFocusNode.hasFocus != keyboardIsOpen) {
  //       keyboardIsOpen = textFocusNode.hasFocus;
  //       if (keyboardIsOpen) {
  //         app.viewModel.setShowHeader(false);
  //         app.menuView.close();
  //       } else {
  //         app.viewModel.setShowHeader(true);
  //         app.menuView.openNavBar();
  //       }
  //     }
  //   });
  // }

  keyboardDown() async {
    textFocusNode.unfocus();
    await app.content.saveContent(content);
  }
}
