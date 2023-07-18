import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HeadlessWebView {
  HeadlessWebView() {
    //createHeadlessWebView();
  }
  late HeadlessInAppWebView? webView;
  //late InAppWebViewController controller;
  Scenario scenario = Scenario.urlTitle;
  createHeadlessWebView() {
    print('creating headless webview');
    webView = new HeadlessInAppWebView(
      onLoadStop: (controller, url) async {},
    );
  }

  initiateGoogleSearch() {}

  String? webPageTitle;
  Future<String?> getUrlTitle(String url, Function(String?) callback) async {
    print('getUrlTitle');
    scenario = Scenario.urlTitle;
    if (webView == null) {
      createHeadlessWebView() {
        print('creating headless webview');
        webView = new HeadlessInAppWebView(
          onLoadStop: (controller, url) async {},
        );
      }
    } else {
      webView?.run();
    }

    webView?.onLoadStop = (controller, urlLoading) async {
      if (urlLoading == null) return;
      final title = await webView?.webViewController
          .evaluateJavascript(source: 'document.title');
      await callback(title);
      webView?.dispose();
    };

    await webView?.webViewController
        .loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    return null;
  }
}

enum Scenario {
  googleSearch,
  article,
  urlTitle,
}
