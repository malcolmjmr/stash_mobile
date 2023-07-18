import 'package:uuid/uuid.dart';

class Collection {
  late String id;
  late String name;
  String? description;
  List<String>? categories;
  late int created;
  String? createdBy;
  String? iconUrl;

  bool isCurrentCollection;
  bool isNewCollection = true;
  bool hasUpdates = false;

  List<String>? owners;
  List<String>? contributors;
  List<String>? subscribers;

  late bool isPublic;
  late String root;
  List<String> pinned = [];

  Collection({
    required this.name,
    this.description,
    this.categories,
    this.createdBy,
    this.contributors,
    this.subscribers,
    this.isPublic = false,
    this.iconUrl,
    this.isCurrentCollection = false,
    this.root = '',
  }) {
    id = Uuid().v1().split('-').first;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Collection.fromDatabase(this.id, Map<String, dynamic> json,
      {this.isCurrentCollection = false}) {
    name = json['name'];
    description = json['description'];
    categories = json['categories'] != null
        ? List<String>.from(json['categories'])
        : null;
    created = json['created'];
    createdBy = json['createdBy'];
    isPublic = json['isPublic'];
    iconUrl = json['iconUrl'];
    root = json['root'];
    pinned = json['pinned'] != null ? List<String>.from(json['pinned']) : [];
    owners = json['owners'] != null ? List<String>.from(json['owners']) : null;
    contributors = json['contributors'] != null
        ? List<String>.from(json['contributors'])
        : null;
    subscribers = json['subscribers'] != null
        ? List<String>.from(json['subscribers'])
        : null;
    isNewCollection = false;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<Repo: $name>';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'description': description,
      'categories': categories,
      'created': created,
      'createdBy': createdBy,
      'isPublic': isPublic,
      'iconUrl': iconUrl,
      'root': root,
      'owners': owners,
      'contributors': contributors,
      'subscribers': subscribers,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
