
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';


import 'package:stashmobile/app/providers/workspaces.dart';
import 'package:stashmobile/app/providers/resources.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/app/workspace/WorkspaceViewModel.dart';
import '../../models/workspace.dart';
import '../../models/resource.dart';
import '../../models/user/model.dart';
import 'logger_provider.dart';

import 'users.dart';

final appProvider = Provider((ref) => AppController(
      userManager: ref.watch(userProvider),
      workspaceManager: ref.watch(workspaceProvider),
      resourceManager: ref.watch(resourceProvider),
      webManager: ref.watch(webManagerProvider),
      logger: ref.watch(loggerProvider),
      reader: ref.read

    ));

class AppController {
  // Backend
  Logger logger;
  WorkspaceManager workspaceManager;
  ResourceManager resourceManager;
  WebManager webManager;
  UserManager userManager;

  Workspace? currentWorkspace;
  Resource? currentResource;

  Reader reader;

  AppController({
    required this.logger,
    required this.resourceManager,
    required this.workspaceManager,
    required this.webManager,
    required this.userManager,
    required this.reader,
  }) {
    
  }

  setCurrentWorkspace(Workspace? workspace) {
    userManager.currentUser.currentWorkspace = workspace?.id;
    if (workspace != null) reader(workspaceViewProvider).setWorkspace(workspace);
    // userManager.saveCurrentUser();
    currentWorkspace = workspace;
  }

  setCurrentResource(Resource? resource) {
    userManager.currentUser.currentWorkspace = resource?.id;
    if (resource?.url != null) reader(webManagerProvider).setResource(resource!);
    userManager.saveCurrentUser();
    currentResource = resource;
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
