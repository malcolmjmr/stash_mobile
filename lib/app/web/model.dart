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

final tabIndexProvider = StateProvider<int>((ref) => 0);

class WebViewModel extends ChangeNotifier {
  AppController app;
  Reader read;
  late int tabIndex;
  late WorkspaceViewModel workspaceViewModel;
  WebViewModel({required this.app, required this.read}) {
    workspaceViewModel = read(workspaceViewProvider);


  }

  Map<int,InAppWebViewController> controllers = {};

  List<Resource> get tabs => workspaceViewModel.tabs;


  openWebView(BuildContext context) {
    print('opening web view');
    controllers = {};
    read(tabIndexProvider).state = workspaceViewModel.workspace.activeTabIndex ?? 0;
    Navigator.pushNamed(context, AppRoutes.webView);
  }

  setController(controller, index) {
    controllers[index] = controller;
  }

  onPageChanged(int index) async { 
    workspaceViewModel.workspace.activeTabIndex = index;
    read(tabIndexProvider).state = index;
    print(workspaceViewModel.workspace.tabs.map((t) => t.url));
  }


  updateTabResource(int index, {required String url, String? title, String? favIconUrl}) {
    Resource resource = workspaceViewModel.tabs[index];
    final now = DateTime.now().microsecondsSinceEpoch;
    if (resource.url != url) {
      resource = Resource(url: url);
    } 
    
    resource.title = title;
    resource.favIconUrl = favIconUrl;
    
    if (resource.isSaved == true) {
      if (resource.lastVisited == null || (resource.lastVisited! -  now) > (1000 * 60 * 60)) {
        resource.lastVisited = now;
        app.resourceManager.saveResource(resource);
      }
    }

    

    workspaceViewModel.updateTab(index, resource);
   

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

