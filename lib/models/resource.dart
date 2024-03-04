

import 'package:flutter/foundation.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:uuid/uuid.dart';

import 'workspace.dart';

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
  String? imageUrl;
  String? title;
  String? id;
  List<String> contexts = [];
  List<String> tags = [];
  List<Highlight> highlights = [];
  List<String> images = [];
  int? index;
  int? created;
  int? updated;
  int? lastVisited;
  int? deleted;
  String? bookmarkId;
  String? parentId;
  bool? isQueued;
  bool? isFavorite;
  bool get isSaved => contexts.isNotEmpty && (isQueued != true || tags.isNotEmpty || highlights.isNotEmpty || rating > 0);
  Uint8List? image;
  bool? isSearch;
  bool? isSelected;
  Workspace? primaryWorkspace;
  List<Tag> matchingTags = [];
  int? scrollPosition;
  int rating = 0;
  List<Note> notes = [];
  List<String> queue = [];
  Note? note;

  bool annotationsLoaded = false;


  Resource({ this.url, this.title, this.favIconUrl, this.note}) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Resource.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    url = json['url'];
    favIconUrl = json['favIconUrl'];
    imageUrl = json['imageUrl'];
    images = json['images'] != null ? List<String>.from(json['images']) : [];
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
    deleted = json['deleted'];
    updated = json['updated'];
    highlights = json['highlights'] != null ? List<Highlight>.from(json['highlights'].map((h) => Highlight.fromJson(h))) : [];//List<Highlight>.from()
    scrollPosition = json['scrollPos'];
    rating = json['rating'] != null ? json['rating'] : 0;
    note = json['note'];
    notes = json['notes'] != null ? List<Note>.from(json['notes'].map((n) => Note.fromJson(n))) : [];

  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'url': url,
      'favIconUrl': favIconUrl,
      'imageUrl': imageUrl,
      'images': images,
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
      'deleted': deleted,
      'updated': updated,
      'highlights': highlights.map((h) => h.toJson()),
      'scrollPos': scrollPosition,
      'rating': rating,
      'note': note,
      'notes': notes.map((n) => n.toJson()),
    };
    json.removeWhere((key, value) => value == null || value == [] || value == 0);
    return json;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}


class Highlight {
  late String text;
  String? id;

  Map<String, dynamic>? target;
  
  Highlight({
    this.id,
    required this.text, 
  });

  Highlight.fromJson(Map<String,dynamic> json) {
    text = json['text'];
    id = json['id'];
  }

  Map<String,dynamic> toJson() {
     Map<String, dynamic> json = {
      'id': id,
      'text': text,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }


}