import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';

class TabView extends StatefulWidget {
  const TabView({Key? key, required this.index, required this.webManager, required this.workspaceViewModel}) : super(key: key);

  final int index;
  final WebManager webManager;
  final WorkspaceViewModel workspaceViewModel;

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(widget.workspaceViewModel.tabs[widget.index].url!)),
      pullToRefreshController: PullToRefreshController(
        options: PullToRefreshOptions(),
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onWebViewCreated: (controller) => widget.webManager.setController(controller),
      onLoadStart: (controller, url) =>
          widget.webManager.onWebsiteLoadStart(context, url),
      onProgressChanged: (controller, progress) =>
          widget.webManager.onWebsiteProgressChanged(context, progress),
      onLoadStop: (controller, url) => widget.webManager.onWebsiteLoadStop(context),
      onConsoleMessage: (controller, msg) {
        print('JS console:\n$msg');
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
