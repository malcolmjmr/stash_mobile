import 'package:stashmobile/models/user/notifications/share.dart';
import 'package:uuid/uuid.dart';

class User {
  late String id;
  late int created;
  String? name;
  String? imageUrl;
  String theme = 'dark';
  String? currentContext;

  User({
    this.name,
    this.imageUrl,
    required this.id
  }) {
    created = DateTime.now().millisecondsSinceEpoch;
  }

  User.fromDatabase(String userId, Map json) {
    id = userId;
    name = json['name'];
    theme = json['theme'] ?? 'dark';
    imageUrl = json['imageUrl'];
    created = json['created'];
    currentContext = json['currentContext'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'theme': theme,
      'imageUrl': imageUrl,
      'created': created,
      'currentContext': currentContext
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
