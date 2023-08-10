import 'package:stashmobile/models/resource.dart';
import 'package:uuid/uuid.dart';

class Workspace {

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

  bool? isIncognito;
  bool? isFavorite;

  Workspace({this.title, this.color}) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
    updated = created;
    lastActive = created;
  }

  Workspace.fromDatabase(String objectId, Map<String, dynamic> json) {
    id = objectId;
    title = json['title'];
    url = json['url'];
    color = json['color'];
    isOpen = json['isOpen'] ?? false;
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
    tabs = json['tabs'] != null ? List<Resource>.from(json['tabs'].map((tab) => Resource.fromDatabase(tab['id'].toString(), tab))) : [];
    activeTabId = json['activeTabId'].runtimeType == int ? json['activeTabId'] : null;
    activeTabIndex = json['activeTabIndex'];
    isIncognito = json['isIncognito'] ?? false;
    isFavorite = json['isFavorite'] ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'url': url,
      'title': title,
      'color': color,
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
      'isIncognito': isIncognito,
      'isFavorite': isFavorite,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}