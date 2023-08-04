import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide WebView;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/web.dart';

class WebView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(webManagerProvider);
    final app = watch(appProvider);
    return Container(
      child: Column(
        children: [
          WebViewHeader(),
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(model.resource.url!)),
            pullToRefreshController: PullToRefreshController(
              options: PullToRefreshOptions(),
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              ),
            ].toSet(),
            onWebViewCreated: (controller) => model.setController(controller),
            onLoadStart: (controller, url) =>
                model.onWebsiteLoadStart(context, url),
            onProgressChanged: (controller, progress) =>
                model.onWebsiteProgressChanged(context, progress),
            onLoadStop: (controller, url) => model.onWebsiteLoadStop(context),
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
          ),
          WebViewNavBar(),
        ],
      ),
    );
  } 
}


class WebViewNavBar extends ConsumerWidget {
  const WebViewNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return const Placeholder();
  }
}


class WebViewHeader extends ConsumerWidget {
  const WebViewHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {


    return const Placeholder();
  }
}
