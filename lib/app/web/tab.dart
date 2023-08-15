import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';

class TabView extends StatefulWidget {
  const TabView({Key? key, required this.url}) : super(key: key);

  final String url;
  

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {

  late InAppWebViewController controller;

  Widget build(BuildContext context) {
    final model = TabViewModel();
    final initialUrl = widget.url;

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
      onWebViewCreated: (controller) => widget.controller = controller,
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
          allowsBackForwardNavigationGestures: true,
          disableLongPressContextMenuOnLinks: false,
          allowsLinkPreview: false,
          disallowOverScroll: false,
        ),
      ),
    );
  }
}
