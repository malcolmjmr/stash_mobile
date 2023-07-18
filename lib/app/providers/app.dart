import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:stashmobile/app/clipboard/model.dart';
import 'package:stashmobile/app/fields/model.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/fields.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/providers/tags.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/read_aloud/model.dart';
import 'package:stashmobile/app/tags/model.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/app/web/model.dart';

import 'collections.dart';
import 'content_manager.dart';
import 'logger_provider.dart';
import 'settings.dart';
import 'users.dart';

final appProvider = Provider((ref) => AppController(
      users: ref.watch(userProvider),
      content: ref.watch(contentProvider),
      settings: ref.watch(settingsProvider),
      web: ref.watch(webManagerProvider),
      tags: ref.watch(tagProvider),
      filters: ref.watch(filterProvider),
      clipboard: ref.watch(clipboardProvider),
      viewModel: ref.watch(appViewProvider),
      treeView: ref.watch(treeViewProvider),
      menuView: ref.watch(menuViewProvider),
      tagsView: ref.watch(tagsViewProvider),
      fieldsView: ref.watch(fieldViewProvider),
      logger: ref.watch(loggerProvider),
      readAloud: ref.watch(readAloudProvider),
    ));

class AppController {
  // Backend
  Logger logger;
  ContentManager content;
  WebManager web;
  UserManager users;
  late CollectionManager collections;
  TagManager tags;
  SettingsManager settings;
  FilterManager filters;
  Clipboard clipboard;
  ReadAloudController readAloud;

  // Views
  AppViewModel viewModel;
  TreeViewModel treeView;
  MenuViewModel menuView;
  TagsViewModel tagsView;
  FieldsViewModel fieldsView;

  AppController({
    required this.logger,
    required this.content,
    required this.web,
    required this.users,
    required this.tags,
    required this.settings,
    required this.filters,
    required this.clipboard,
    required this.viewModel,
    required this.treeView,
    required this.menuView,
    required this.tagsView,
    required this.fieldsView,
    required this.readAloud,
  }) {
    collections = content.collectionManager;
    keyboardVisibility.onChange.listen(onKeyboardVisibilityChange);
  }

  KeyboardVisibilityController keyboardVisibility =
      KeyboardVisibilityController();
  onKeyboardVisibilityChange(bool visible) {
    if (viewModel.webViewIsOpen) {
      if (visible)
        menuView.close();
      else
        menuView.openNavBar();
    }
  }
}
