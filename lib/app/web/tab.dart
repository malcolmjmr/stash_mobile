import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/app/providers/workspace.dart';

import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';

class TabView extends StatelessWidget {
  const TabView({Key? key, required this.index, required this.url}) : super(key: key);

  final int index;
  final String url;

  Widget build(BuildContext context) {
    final model = TabViewModel(index: index);
    final initialUrl = context.read(workspaceViewProvider).workspace.tabs[index].url!;
    print('building tab');
    print(index);
    print(initialUrl);
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
      pullToRefreshController: PullToRefreshController(
        options: PullToRefreshOptions(),
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onWebViewCreated: (controller) => context.read(workspaceViewProvider).setController(controller, index),
      onLoadStart: (controller, url) =>
          model.onWebsiteLoadStart(context, controller, url),
      onProgressChanged: (controller, progress) =>
         model.onWebsiteProgressChanged(context, controller, progress),
      onLoadStop: (controller, url) => model.onWebsiteLoadStop(context, controller),
      onConsoleMessage: (controller, msg) {
        //print('JS console:\n$msg');
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          disableHorizontalScroll: true,
          incognito: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsBackForwardNavigationGestures: false,
          disableLongPressContextMenuOnLinks: false,
          allowsLinkPreview: false,
          disallowOverScroll: false,
        ),
      ),
    );
  }
}
