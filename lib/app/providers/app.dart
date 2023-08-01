
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';


import 'package:stashmobile/app/providers/context.dart';
import 'package:stashmobile/app/providers/resource.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/web/model.dart';
import 'logger_provider.dart';

import 'users.dart';

final appProvider = Provider((ref) => AppController(
      user: ref.watch(userProvider),
      contexts: ref.watch(contextProvider),
      resources: ref.watch(resourceProvider),
      web: ref.watch(webManagerProvider),
      logger: ref.watch(loggerProvider),
    ));

class AppController {
  // Backend
  Logger logger;
  ContextManager contexts;
  ResourceManager resources;
  WebManager web;
  UserManager user;


  AppController({
    required this.logger,
    required this.resources,
    required this.contexts,
    required this.web,
    required this.user,

  }) {
    
  }

  // KeyboardVisibilityController keyboardVisibility =
  //     KeyboardVisibilityController();
  // onKeyboardVisibilityChange(bool visible) {
  //   if (viewModel.webViewIsOpen) {
  //     if (visible)
  //       menuView.close();
  //     else
  //       menuView.openNavBar();
  //   }
  // }
}
