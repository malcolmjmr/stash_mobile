class ShareNotification {
  late int date;
  late String from;
  late ShareType type;
  late ShareAccess access;
  late String id;
  String? collection;
  ShareNotification({
    required this.id,
    this.collection,
    required this.from,
    required this.type,
    required this.access,
  }) {
    date = DateTime.now().millisecondsSinceEpoch;
  }

  ShareNotification.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    from = json['from'];
    id = json['id'];
    collection = json['collection'];
    type = ShareType.values[json['type']];
    access = ShareAccess.values[json['access']];
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'from': from,
        'id': id,
        'collection': collection,
        'type': type.index,
        'access': access.index,
      };
}

enum ShareType { element, root, collection }

enum ShareAccess { full, edit, view }
