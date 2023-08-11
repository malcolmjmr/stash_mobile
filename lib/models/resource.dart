

import 'package:uuid/uuid.dart';

enum ResourceType {
  note,
  webPage,
  annotation,
  webSearch,
  task,
  empty,
}

class Resource {
  String? url;
  String? favIconUrl;
  String? title;
  String? id;
  List<String> contexts = [];
  List<String> tags = [];
  int? index;
  int? created;
  int? updated;
  int? lastVisited;
  String? bookmarkId;
  String? parentId;
  bool? isQueued;
  bool? isFavorite;
  bool? isSaved;


  Resource({ this.url, this.title, this.favIconUrl}) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Resource.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    url = json['url'];
    favIconUrl = json['favIconUrl'];
    title = json['title'];
    created = json['created'];
    lastVisited = json['lastVisited'];
    contexts = json['contexts'] != null ? List<String>.from(json['contexts']) : [];
    tags = json['tags'] != null ? List.from(json['tags']) : [];
    bookmarkId = json['bookmarkId'];
    parentId = json['parentId'];
    index = json['index'];
    isQueued = json['isQueued'];
    isFavorite = json['isFavorite'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'url': url,
      'favIconUrl': favIconUrl,
      'title': title,
      'created': created,
      'lastVisited': lastVisited,
      'contexts': contexts,
      'tags': tags,
      'bookmarkId': bookmarkId,
      'parentId': parentId,
      'index': index,
      'isQueued': isQueued,
      'isFavorite': isFavorite,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

}