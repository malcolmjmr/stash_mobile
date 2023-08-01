import 'package:stashmobile/models/resource.dart';

class Context {

  late String id;
  String? title;
  String? url;
  bool isOpen = false;

  int? created;
  int? updated;
  int? lastActive;
  int? opened;
  int? openCount;
  int? closed;
  
  int? timeOpen;
  int? timeInUse;
  int? tabsOpened;

  int? groupId;
  String? folderId;

  int? resourcesOpened;

  bool? hasDefaultTitle;
  
  List<Resource> tabs = [];
  int? activeTabId;
  int? activeTabIndex;
  String? color;

  Context.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    title = json['title'];
    url = json['url'];
    isOpen = json['isOpen'];
    created = json['created'];
    updated = json['updated'];
    lastActive = json['lastActive'];
    opened = json['opened'];
    openCount = json['openCount'];
    closed = json['closed'];
    timeOpen = json['timeOpen'];
    timeInUse = json['timeInUse'];
    tabsOpened = json['tabsOpened'];
    groupId = json['groupId'];
    folderId = json['folderId'];
    resourcesOpened = json['resourcesOpened'];
    hasDefaultTitle = json['hasDefaultTile'];
    tabs = json['tabs'] != null ? json['tabs'].map((tab) => Resource.fromDatabase(json['id'], json)) : [];
    activeTabId = json['activeTabId'];
    activeTabIndex = json['activeTabIndex'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'url': url,
      'title': title,
      'isOpen': isOpen,
      'created': created,
      'updated': updated,
      'lastActive': lastActive,
      'opened': opened,
      'openCount': openCount,
      'closed': closed,
      'timeOpen': timeOpen,
      'timeInUse': timeInUse,
      'tabsOpened': tabsOpened,
      'groupId': groupId,
      'folderId': folderId,
      'resourcesOpened': resourcesOpened,
      'hasDefaultTitle': hasDefaultTitle,
      'tabs': tabs.map((t) => t.toJson()),
      'activeTabId': activeTabId,
      'activeTabIndex': activeTabIndex,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}