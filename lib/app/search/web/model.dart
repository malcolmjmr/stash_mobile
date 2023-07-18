import 'package:flutter/material.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/web_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  String searchText;
  ViewModel(this.context, this.searchText) {
    app = context.read(appProvider);
    loadSearches();
    getRelevantSearches();
  }

  List<Content> allSearches = [];
  loadSearches() {
    allSearches = app.content.allContent.values
        .where((c) => c.type == ContentType.webSearch)
        .toList();
  }

  List<Content> relevantSearches = [];
  getRelevantSearches() {
    relevantSearches = allSearches.where((s) {
      return s.webSearch!.query
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
    relevantSearches.sort((a, b) =>
        (b.visits?.lastVisited ?? 0).compareTo(a.visits?.lastVisited ?? 0));
    notifyListeners();
  }

  openExistingSearch(Content search) {
    app.viewModel.openMainView(context, search);
    Navigator.of(context).pop();
  }

  List<String> searchSuggestions = [];
  getGoogleSearchSuggestions() {
    searchSuggestions = app.web.getGoogleSearchSuggestions();
  }

  List<SearchResult> searchResults = [];
  getGoogleSearchResults() {
    searchResults = app.web.getGoogleSearchResults();
  }

  searchWithSearchEngine(String searchEngineUrl) async {
    final searchUrl = Uri.parse(
        'https://$searchEngineUrl${app.filters.contentFilter.filter!.searchText!}');

    final webSearch = Content(
      type: ContentType.webSearch,
      webSearch: WebSearchFields(
        query: app.filters.contentFilter.filter!.searchText!,
        url: searchUrl.toString(),
      ),
    );
    await app.content
        .addLinkedContent(parent: app.viewModel.root, child: webSearch);
    app.viewModel.open(context, webSearch, view: ContentViewType.website);
    app.menuView.openNavBar();
    Navigator.of(context).pop();
  }

  SearchEngine get searchEngine => searchEngines[searchEngineIndex];
  int searchEngineIndex = 0;
  List<SearchEngine> searchEngines = [
    SearchEngine(
      'Google',
      'google.com/search?q=',
      'https://assets.cloud.im/prod/ux1/images/logos/google/google-2x.png',
    ),
    SearchEngine(
      'Bing',
      'bing.com/search?q=',
      'https://logos-world.net/wp-content/uploads/2021/02/Bing-Logo.png',
    ),
    SearchEngine(
      'Ecosia',
      'ecosia.org/search?q=',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Ecosia-like_logo.svg/224px-Ecosia-like_logo.svg.png',
    ),
    SearchEngine(
      'Duck Duck Go',
      'duckduckgo.com',
      'https://upload.wikimedia.org/wikipedia/en/9/90/The_DuckDuckGo_Duck.png',
    ),
    SearchEngine(
      'Yahoo',
      'search.yahoo.com/search?p=',
      'https://pentagram-production.imgix.net/99ec1157-8dfd-4645-8909-bd88b7869b7c/mb_yahoo_03.jpg?rect=%2C%2C%2C&w=640&fm=jpg&q=70&auto=format',
    ),
  ];
}

class SearchEngine {
  String name;
  String url;
  String iconUrl;
  int? visits;
  int? lastVisit;

  SearchEngine(this.name, this.url, this.iconUrl);
}
