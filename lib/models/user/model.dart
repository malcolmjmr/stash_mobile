import 'package:stashmobile/models/user/notifications/share.dart';
import 'package:uuid/uuid.dart';

class User {
  late String id;
  late int created;
  int? registration;
  int? lastUpdateTime;

  String? name;
  String? imageUrl;
  String theme = 'dark';
  double? fontSize;
  String? currentCollection;
  List<String> followers = [];
  List<UserSubscription> following = [];
  List<UserSubscription> friends = [];
  List<UserContact> contacts = [];
  List<String> pinned = [];
  List<String> playList = [];
  int? playListPosition;
  List<CollectionSubscription> sharedCollections = [];
  List<CollectionSubscription> subscriptions = [];
  List<ShareNotification> shareNotifications = [];

  Map<String, int> actionUsage = Map();

  ConnectedAppSettings? connectedApps = ConnectedAppSettings();

  User({
    this.name,
    this.imageUrl,
  }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  User.fromDatabase(String userId, Map json) {
    id = userId;
    name = json['name'];
    theme = json['theme'] ?? 'dark';
    imageUrl = json['imageUrl'];
    followers = json['followers'] != null
        ? json['followers'].cast<String>()
        : <String>[];
    following = json['following'] != null
        ? List<UserSubscription>.from(
            json['following'].map((u) => UserSubscription.fromJson(u)))
        : [];
    friends = json['friends'] != null
        ? List<UserSubscription>.from(
            json['friends'].map((u) => UserSubscription(u)))
        : [];
    created = json['created'] ?? DateTime.now().millisecondsSinceEpoch;
    registration = json['registration'];
    currentCollection = json['currentCollection'];
    lastUpdateTime = json['lastUpdateTime'];
    connectedApps = json['connectedApps'] != null
        ? ConnectedAppSettings.fromJson(json['connectedApps'])
        : null;
    pinned = json['pinned'] != null ? json['pinned'].cast<String>() : [];
    playList = json['playList'] != null ? json['playList'].cast<String>() : [];
    sharedCollections = json['sharedCollections'] != null
        ? List<CollectionSubscription>.from(json['sharedCollections']
            .map((s) => CollectionSubscription.fromJson(s)))
        : [];
    shareNotifications = json['shareNotifications'] != null
        ? List<ShareNotification>.from(json['shareNotifications']
            .map((s) => ShareNotification.fromJson(s)))
        : [];
    subscriptions = json['subscriptions'] != null
        ? List<CollectionSubscription>.from(json['subscriptions']
            .map((s) => CollectionSubscription.fromJson(s)))
        : [];
    fontSize = json['fontSize'];
    playListPosition = json['playListPosition'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'imageUrl': imageUrl,
      'followers': followers,
      'following': following.map((u) => u.toJson()).toList(),
      'friends': friends,
      'created': created,
      'registration': registration,
      'currentCollection': currentCollection,
      'lastUpdateTime': lastUpdateTime,
      'connectedApps': connectedApps?.toJson(),
      'pinned': pinned,
      'playList': playList,
      'playListPosition': playListPosition,
      'sharedCollections': sharedCollections.map((s) => s.toJson()).toList(),
      'shareNotifications': shareNotifications.map((s) => s.toJson()).toList(),
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      'theme': theme,
      'fontSize': fontSize,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<$id:$name>';
  }
}

class ConnectedAppSettings {
  ConnectedAppSettings();

  HypothesisSettings hypothesis = HypothesisSettings();

  ConnectedAppSettings.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      hypothesis = HypothesisSettings.fromJson(json['hypothesis']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'hypothesis': hypothesis.toJson(),
    };
  }
}

class HypothesisSettings {
  String? apiToken;
  String? userName;
  int? lastSynced;

  HypothesisSettings();

  HypothesisSettings.fromJson(Map<String, dynamic> json) {
    apiToken = json['apiToken'];
    userName = json['userName'];
    lastSynced = json['lastSynced'];
  }

  Map<String, dynamic> toJson() {
    return {
      'apiToken': apiToken,
      'userName': userName,
      'lastSynced': lastSynced,
    };
  }
}

class UserCollections {}

class CollectionSubscription {
  late String collectionId;
  int? lastVisited;
  int? lastUpdated;
  int? updateCount;
  List<String>? updateIds;
  CollectionSubscription(this.collectionId);

  CollectionSubscription.fromJson(Map<String, dynamic> json) {
    collectionId = json['collectionId'];
    lastVisited = json['lastVisited'];
    lastUpdated = json['lastUpdated'];
    updateCount = json['updateCount'];
    updateIds =
        json['updateIds'] != null ? json['updatesIds'].cast<String>() : null;
  }

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'lastVisited': lastVisited,
        'lastUpdated': lastUpdated,
        'updateCount': updateCount,
        'updateIds': updateIds
      }..removeWhere((key, value) => value == null);
}

class UserSubscription {
  late String userId;
  late int created;
  int? lastVisited;
  int? lastUpdated;
  int? updateCount;
  List<String>? updateIds;
  UserSubscription(this.userId) {
    created = DateTime.now().microsecondsSinceEpoch;
  }

  UserSubscription.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    userId = json['userId'];
    lastVisited = json['lastVisited'];
    lastUpdated = json['lastUpdated'];
    updateCount = json['updateCount'];
    updateIds =
        json['updateIds'] != null ? json['updatesIds'].cast<String>() : null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'created': created,
      'userId': userId,
      'lastVisited': lastVisited,
      'lastUpdated': lastUpdated,
      'updateCount': updateCount,
      'updateIds': updateIds
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class UserContact {
  String userId;
  late int lastContacted;
  UserContact({required this.userId}) {
    lastContacted = DateTime.now().millisecondsSinceEpoch;
  }
}
