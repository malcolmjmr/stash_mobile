import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class TabView extends StatefulWidget {
  TabView({Key? key, 
    required this.model,
    this.windowId,
    this.lazyLoad = true,
  }) : super(key: key);

  final bool lazyLoad;
  final TabViewModel model;
  final int? windowId;
  //final Function(TabViewModel model, InAppWebViewController controller, Uri? uri) onTabUpdated;

  // final Function() onWindowCreated
  // final Function() onWindowClosed

  

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {

  Widget build(BuildContext context) {
    
    return InAppWebView(
      windowId: widget.windowId,
      initialUrlRequest: widget.lazyLoad || widget.windowId != null ? null : URLRequest(url: Uri.parse(widget.model.resource.url!)),
      pullToRefreshController: PullToRefreshController(
        options: PullToRefreshOptions(),
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      
      onWebViewCreated: widget.model.setController,
      onLoadStart: (controller, uri) => widget.model.onWebsiteLoadStart(context, controller, uri),
      onProgressChanged: (controller, progress) => widget.model.onWebsiteProgressChanged(context, controller, progress),
      onLoadStop: (controller, uri) => widget.model.onWebsiteLoadStop(context, controller, uri),
      onConsoleMessage: (controller, msg) {
        print('JS console:\n$msg');
      },
      onCloseWindow: (controller) => widget.model.onCloseWindow(context, controller),
      onCreateWindow:(controller, createWindowAction) => widget.model.onCreateWindow(context, controller, createWindowAction),
      shouldOverrideUrlLoading: (controller, navigationAction) => widget.model.checkNavigation(context, navigationAction),
      initialOptions: InAppWebViewGroupOptions(
      
        crossPlatform: InAppWebViewOptions(
          disableHorizontalScroll: true,
          useShouldOverrideUrlLoading: true,
          // incognito: false,
          // javaScriptEnabled: true,
          userAgent: 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
          // javaScriptCanOpenWindowsAutomatically: true,
        
        ),
        ios: IOSInAppWebViewOptions(
          allowsBackForwardNavigationGestures: true,
          disableLongPressContextMenuOnLinks: true,
          allowsLinkPreview: false,
          disallowOverScroll: true,
          // sharedCookiesEnabled: true,
          // applePayAPIEnabled: true,
          
        
        ),
      ),
    );
  }
}
