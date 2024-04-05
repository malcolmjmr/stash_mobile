

import 'package:flutter/foundation.dart';
import 'package:stashmobile/models/article.dart';
import 'package:stashmobile/models/chat.dart';
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
  String? text;
  String? summary;
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
  Chat? chat;
  Article? article;

  bool annotationsLoaded = false;
  bool isSuggestion = false;


  Resource({ this.url, this.title, this.favIconUrl, this.note, this.chat, this.parentId}) {
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
    summary = json['summary'];
    text = json['text'];
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
    chat = json['chat'] != null ? Chat.fromJson(json['chat']) : null;
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
      'summary': summary,
      'text': text,
      'chat': chat?.toJson()
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

  int favorites = 0;
  int likes = 0;
  int dislikes = 0;
  int laughs = 0;

  Map<String, dynamic>? target;

  bool get hasQuestion => text.contains('?');

  String get question {

    final endSplit = text.split('?');
    if (endSplit.length > 1) {
      return endSplit[0] + '?';
      // final startSplit = endSplit[0].split('. ');
      // if (startSplit.length > 1) {
      //   return startSplit[startSplit.length - 1] + '?';
      // } else {
      //   return startSplit[0] + '?';
      // }
    } else {
      return '';
    }


  } 
  
  Highlight({
    this.id,
    required this.text, 
  });

  Highlight.fromJson(Map<String,dynamic> json) {
    text = json['text'];
    id = json['id'];
    favorites = json['favorites'] ?? 0;
    likes = json['likes'] ?? 0;
    dislikes = json['dislikes'] ?? 0;
    laughs = json['laughs'] ?? 0;

  }

  Map<String,dynamic> toJson() {
     Map<String, dynamic> json = {
      'id': id,
      'text': text,
      'favorites': favorites,
      'likes': likes,
      'dislikes': dislikes,
      'laughs': laughs,
    };
    json.removeWhere((key, value) => value == null || value == 0 || value == '');
    return json;
  }


}