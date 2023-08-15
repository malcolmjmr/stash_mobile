import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class TabView extends StatefulWidget {
  TabView({Key? key, 
    required this.resource,
    required this.onTabUpdated, 
  }) : super(key: key);

  final Resource resource;
  final TabViewModel model = TabViewModel();
  final Function(TabViewModel model, InAppWebViewController controller, Uri? uri) onTabUpdated;

  

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.model.resource = widget.resource;
  }

  Widget build(BuildContext context) {
 
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(widget.model.resource.url!)),
      pullToRefreshController: PullToRefreshController(
        options: PullToRefreshOptions(),
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onWebViewCreated: (controller) => widget.model.controller = controller,
      onLoadStart: (controller, uri) => widget.onTabUpdated(widget.model, controller, uri),
      onProgressChanged: (controller, progress) => null,
      onLoadStop: (controller, uri) => widget.onTabUpdated(widget.model, controller, uri),
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
