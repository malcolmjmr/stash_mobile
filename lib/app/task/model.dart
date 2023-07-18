import 'package:flutter/material.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/content_manager.dart';

class TaskViewModel extends ChangeNotifier {
  BuildContext context;
  late ContentManager contentManager;
  late MenuViewModel menu;
  late AppViewModel appView;
  TaskViewModel(this.context) {
    contentManager = context.read(contentProvider);
    menu = context.read(menuViewProvider);
    appView = context.read(appViewProvider);
  }
}
