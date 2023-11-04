import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:uuid/uuid.dart';

class Domain {

  late String? id;

  late bool isIncognito;
  late bool isFavorite;

  String? title;
  String? favIconUrl;
  late String url;

  String? searchTemplate;
  int searchCount = 0;

  late int created;
  int? lastVisited;
  int count = 0;

  Domain({
    required this.url, 
    this.isIncognito = false,
    this.isFavorite = false,
    this.searchTemplate,
    this.favIconUrl,
    this.title,
  }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Domain.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    url = json['url'];
    favIconUrl = json['favIconUrl'];
    title = json['title'];
    created = json['created'];
    lastVisited = json['lastVisited'];
    isIncognito = json['isIncognito'] ?? false;
    isFavorite = json['isFavorite'] ?? false;
    searchCount = json['searchCount'] ?? 0;
    searchTemplate = json['searchTemplate'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'url': url,
      'favIconUrl': favIconUrl,
      'title': title,
      'created': created,
      'lastVisited': lastVisited,
      'isIncognito': isIncognito,
      'isFavorite': isFavorite,
      'searchCount': searchCount,
      'searchTemplate': searchTemplate,
    };
    json.removeWhere((key, value) => value == null || value == [] || value == false || value == 0);
    return json;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }

  static const String searchPlaceholder = '<|search|>';

  checkIfUrlIsSearch(String url) {
    if (searchTemplate != null) {
      final searchPrefix = searchTemplate!.split(searchPlaceholder)[0];
      final matchesSearchTemplate = url.startsWith(searchPrefix);
      if (matchesSearchTemplate) {

          //isIncognito = tab.incognito;
          return true;
      }
    } 
    return false;
  }

  getSearchQuery(String url) {
    if (searchTemplate != null) {
      final searchPrefix = searchTemplate!.split(searchPlaceholder)[0];
      final matchesSearchTemplate = url.startsWith(searchPrefix);
      if (matchesSearchTemplate) {
          String searchText = url.split(searchPrefix)[1];
          searchText = Uri.decodeComponent(searchText.split('&')[0])
            .replaceAll('+', ' ');
          return searchText;
      }
    } 
    return null;
  }


  static String? checkIfUrlContainsInput(InputData input, Uri uri) {
    print('checking last input against url');
    print(input.text);
    print(uri);
    final template = Uri.decodeFull(uri.toString())
          .replaceAll('%3A', ':').replaceAll('+', ' ')
          .replaceFirst(input.text, searchPlaceholder);

    print(template);

    final foundSearch = (
        // (DateTime.now().millisecondsSinceEpoch - input.time) < 2000
        // && Uri.parse(input.url).origin == uri.origin
        template.contains(Domain.searchPlaceholder)
    );

    return foundSearch ? template : null;
  }


  createSearchUrlFromInput(String input) {
    return Uri.encodeFull(searchTemplate!.replaceFirst(searchPlaceholder, input));
  }

  
}