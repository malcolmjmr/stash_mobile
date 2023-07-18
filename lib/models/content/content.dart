import 'package:stashmobile/models/content/type_fields/field.dart';
import 'package:stashmobile/models/content/type_fields/note.dart';
import 'package:uuid/uuid.dart';
import 'package:stashmobile/extensions/dates.dart';

import 'links.dart';
import 'reminders.dart';
import 'tags.dart';
import 'ratings.dart';
import 'type_fields/task.dart';
import 'updates.dart';
import 'visits.dart';

import 'type_fields/annotation.dart';
import 'type_fields/filter.dart';
import 'type_fields/web_search.dart';
import 'type_fields/tag.dart';
import 'type_fields/web_article.dart';
import 'type_fields/website.dart';

enum ContentType {
  root,
  topic,
  note,
  filter,
  webSite,
  webArticle,
  annotation,
  webSearch,
  tag,
  task,
  empty,
  dailyPage,
}

class Content {
  late String id;

  late ContentType type;

  // Auto updated fields
  late int created;
  String? createdBy;
  int? archived;

  ContentUpdates? updates;
  ContentVisits? visits;
  ContentReminders? reminders;

  bool? isOpen;
  bool isIncognito = false;
  bool? isNew;

  // General fields
  String? name;
  bool editName = false;
  String get title {
    String result = 'Untitled';
    if (type == ContentType.annotation) {
      result = annotation!.highlight;
    } else if (type == ContentType.webSearch) {
      result = webSearch != null ? webSearch!.query : result;
    } else if (type == ContentType.dailyPage) {
      final date = DateTime.fromMillisecondsSinceEpoch(created);
      result = '${date.dayString}, ${date.monthString} ${date.day}';
    } else if (name != null) {
      result = name!;
    }
    return result;
  }

  String? get url {
    return {
      ContentType.webSearch: () => webSearch?.url,
      ContentType.webArticle: () => webArticle?.url,
      ContentType.webSite: () => website?.url,
    }[type]
        ?.call();
  }

  String? icon;
  String? iconUrl;

  List<String>? filters;
  ContentTags? tags;
  ContentRatings? ratings;
  ContentLinks? links;
  Map<String, dynamic>? customFields;

  // Type specific fields
  TagFields? tag;
  FilterFields? filter;
  CustomFieldFields? customField;
  AnnotationFields? annotation;
  WebSearchFields? webSearch;
  WebsiteFields? website;
  WebArticleFields? webArticle;
  NoteFields? note;
  TaskFields? task;

  String? source;

  Content({
    this.name,
    this.type = ContentType.topic,
    int? creationTime,
    this.createdBy,
    this.reminders,
    this.links,
    this.tags,
    this.tag,
    this.webSearch,
    this.website,
    this.webArticle,
    this.annotation,
    this.filter,
    this.task,
    this.customField,
    this.editName = false,
    this.iconUrl,
    this.isNew = true,
    this.isIncognito = false,
  }) {
    id = Uuid().v4().split('-').last;
    created = creationTime ?? DateTime.now().millisecondsSinceEpoch;
  }

  Content.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    type = ContentType.values[json['type']];
    created = json['created'];
    createdBy = json['createdBy'];
    archived = json['archived'];
    updates = json['updates'] != null
        ? ContentUpdates.fromJson(json['updates'])
        : null;
    visits =
        json['visits'] != null ? ContentVisits.fromJson(json['visits']) : null;
    reminders = json['reminders'] != null
        ? ContentReminders.fromJson(json['reminders'])
        : null;
    isOpen = json['isOpen'];
    name = json['name'];
    icon = json['icon'];
    iconUrl = json['iconUrl'];
    filters =
        json['filters'] != null ? List<String>.from(json['filters']) : null;
    tags = json['tags'] != null ? ContentTags.fromJson(json['tags']) : null;
    ratings = json['ratings'] != null
        ? ContentRatings.fromJson(json['ratings'])
        : null;
    links = json['links'] != null ? ContentLinks.fromJson(json['links']) : null;
    tag = json['tag'] != null ? TagFields.fromJson(json['tag']) : null;
    annotation = json['annotation'] != null
        ? AnnotationFields.fromJson(json['annotation'])
        : null;
    webArticle = json['webArticle'] != null
        ? WebArticleFields.fromJson(json['webArticle'])
        : null;
    website = json['website'] != null
        ? WebsiteFields.fromJson(json['website'])
        : null;
    filter =
        json['filter'] != null ? FilterFields.fromJson(json['filter']) : null;
    webSearch = json['webSearch'] != null
        ? WebSearchFields.fromJson(json['webSearch'])
        : null;
    customField = json['customField'] != null
        ? CustomFieldFields.fromJson(json['customField'])
        : null;
    customFields = json['customFields'] != null ? json['customFields'] : null;
    note = json['note'] != null ? NoteFields.fromJson(json['note']) : null;
    task = json['task'] != null ? TaskFields.fromJson(json['task']) : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'type': type.index,
      'created': created,
      'createdBy': createdBy,
      'archived': archived,
      'updates': updates?.toJson(),
      'visits': visits?.toJson(),
      'reminders': reminders?.toJson(),
      'isOpen': isOpen,
      'name': name,
      'icon': icon,
      'iconUrl': iconUrl,
      'filters': filters,
      'tags': tags?.toJson(),
      'ratings': ratings?.toJson(),
      'links': links?.toJson(),
      'tag': tag?.toJson(),
      'annotation': annotation?.toJson(),
      'website': website?.toJson(),
      'webArticle': webArticle?.toJson(),
      'filter': filter?.toJson(),
      'webSearch': webSearch?.toJson(),
      'note': note?.toJson(),
      'task': task?.toJson(),
      'customField': customField?.toJson(),
      'customFields': customFields,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  getFieldValueByPath(String fieldPath) {
    List<String> subFields = fieldPath.split('.');
    dynamic value = this.toJson();
    for (String field in subFields) {
      if (value is Map) {
        final tempValue = value[field];
        if (tempValue != null)
          value = tempValue;
        else
          return null;
      } else {
        return null;
      }
    }
    return value;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<$id:$type:$name>';
  }
}
