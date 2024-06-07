
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stashmobile/app/web/js.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/services/config.dart';
import 'package:http/http.dart' as http;

class SearchServices {

  SearchServices() {
    load();
  }

  load() {
    webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('https://www.google.com/')),
      initialSettings: InAppWebViewSettings(cacheEnabled: false),
      onWebViewCreated: (controller) { 
        webViewController = controller;
      },
      onLoadStart: (controller, url) {
        webViewIsLoaded = false;
        webViewIsLoading = true;
      },
      onLoadStop: (controller, url) async {
        await addEventHandlers();
        if (url.toString().contains('exa.ai')) {
          Timer(Duration(seconds: 5), () {
            controller.evaluateJavascript(source: JS.getExaSearchResults);
          });
        }
      }
    );
  }

  late InAppWebView webView;
  late InAppWebViewController webViewController;
  bool webViewIsLoading = false;
  bool webViewIsLoaded = false;

  Function(List<Resource>)? exaResultsCallback;

  searchExa(String text, {Function(List<Resource>)? callback}) {
    exaResultsCallback = callback;
    webViewController
        .loadUrl(
          urlRequest: URLRequest(
            url: WebUri(getExaSearchUrlforResource(prompt: text))
          )
        );
    
    
  }

  searchBrave(String query) async {

    var response = await http.post(
      Uri.parse('https://api.search.brave.com/res/v1/web/search?q=brave+search'),
      headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'X-Subscription-Token': ServicesConfig.braveApiKey,
      },
      body: jsonEncode({
        'q': query,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['search']['results'];
    } else {
      print(response.statusCode);
      print(response);
    }
  }

  getRelatedContent({Resource? resource, String? prompt, required WorkspaceViewModel workspaceModel}) {
    print('getting related content');
    activeWorkspace = workspaceModel;

    /*
      start with the url
      cycle through highlights sorted by love/like count
      cycle through tags?
    */
    

    try {
      webViewController
        .loadUrl(
          urlRequest: URLRequest(
            url: WebUri(getExaSearchUrlforResource(resource: resource, prompt: prompt))
          )
        );
    } catch (e) {
      print(e);
    }
  }

  WorkspaceViewModel? activeWorkspace; 
 
  onExaSearchResults(args) {
     List<Resource> resources = args[0].map<Resource>((json) {
      Resource resource = Resource.fromDatabase(Resource().id!, json);
      return resource;
    }).toList();

    if (activeWorkspace != null) {
      activeWorkspace!.currentTab.model.addResourcesToQueue(resources);
    } else if (exaResultsCallback != null) {
      exaResultsCallback!.call(resources);
    }

   
    
  }

  addEventHandlers() async {
    webViewController.addJavaScriptHandler(
      handlerName: 'exaSearchResults',
      callback: onExaSearchResults,
    );
  }

  getExaSearchUrlforResource({Resource? resource, String? prompt, bool searchUrl = false}) {

    if (prompt == null) {
      if (searchUrl || (resource?.highlights.isEmpty ?? true)) {
        prompt = resource?.url;
      } else {

        int loves = 0;
        int likes = 0;

        for (final highlight in resource!.highlights) {
          likes += highlight.likes;
          loves += highlight.favorites;
        }

        final excerptString = resource.highlights
          .where((h) {
            if (loves > 0) {
              return h.favorites > 0;
            } else if (likes > 0) {
              return h.likes > 0;
            } else {
              return true;
            }
          })
          .map((h) => '"${h.text}"').join('\n');


        prompt = '''
        Articles related to the following excerpts: 
        ${excerptString.substring(0, min(300, excerptString.length))}
        ''';
      }
    }
    
    String url = 'https://exa.ai/search?q=' + Uri.encodeComponent(prompt!);
    return url;

  }

}