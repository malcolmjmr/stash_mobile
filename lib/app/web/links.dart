import 'package:stashmobile/models/content/content.dart';

class LinkManager {
  static bool isGoogleSearch(Uri uri) {
    bool result = uri.host == 'www.google.com' && uri.path == '/search';
    if (result) print(uri);
    return result;
  }

  static String createUrlFromUri(Uri? uri) {
    if (uri == null) return '';
    String result = uri.toString();

    if (isGoogleSearch(uri)) {
      Map<String, String> newParams = Map.from(uri.queryParameters);
      newParams.removeWhere((key, value) => !['q', 'tbm'].contains(key));
      result = Uri.https(uri.host, uri.path, newParams).toString();
    }
    return result;
  }

  static String? createContentName(
      {required Content parent, required Uri uri, String? text}) {
    String? result = text;
    if (parent.webSearch != null) {
      final parentUri = Uri.parse(parent.webSearch!.url);
      bool conductingGoogleSearch =
          isGoogleSearch(parentUri) && isGoogleSearch(uri);
      if (conductingGoogleSearch) {
        print('Conducting google search');
        print(uri.queryParameters);
        final parentTab = parentUri.queryParameters['tbm'];
        final currentTab = uri.queryParameters['tbm'];
        bool isNewTab = parentTab != currentTab;
        if (isNewTab) {
          final tabName = {
            'vid': 'Videos',
            'nws': 'News',
            'bks': 'Books',
            'isch': 'Images',
            'shop': 'Shopping',
          }[currentTab];
          if (tabName != null) result = tabName;
        }
      }
    }
    return result;
  }
}
