import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

import '../../constants/color_map.dart';

final webViewProvider = ChangeNotifierProvider<WebViewModel>((ref) {
  return WebViewModel(app: ref.watch(appProvider), read: ref.read);
});


class WebViewModel extends ChangeNotifier {
  AppController app;
  Reader read;
  late WorkspaceViewModel workspaceViewModel;
  WebViewModel({required this.app, required this.read}) {
    workspaceViewModel = read(workspaceViewProvider);
  }

  onPageChanged(int index) async { 
    Workspace workspace = workspaceViewModel.workspace;
    workspace.activeTabIndex = index;
    await app.webManager.controller?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse(workspace.tabs[index].url!))
    );
  }

  bool canGoBack = false;
  goBack() {
    app.webManager.controller?.goBack();
  }

  bool canGoForward = false;
  goForward() {
    app.webManager.controller?.goForward();
  }

  createNewTab () {
    final newTab = Resource(url: 'https://www.google.com');
    app.setCurrentResource(newTab);
  }

  goHome(BuildContext context) {
    Navigator.popUntil(context,(route) => route.isFirst);
  }

  viewWorkspace(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.workspace);
  }

  bool showNavBar = true;

  Color get workspaceColor => HexColor.fromHex(colorMap[workspaceViewModel.workspace.color ?? 'grey']!);

  String get resourceTitle => app.webManager.resource.title ?? app.webManager.resource.url ?? '';

  String get workspaceTitle => workspaceViewModel.workspace.title ?? '';


}

