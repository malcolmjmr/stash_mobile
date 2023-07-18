import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class Field {
  late String id;

  late int created;
  int? lastUsed;

  late String name;
  late String path;
  late FieldType type;

  bool isCustomField = true;

  IconData? get icon => iconIndex != null
      ? IconData(iconIndex!, fontFamily: 'MaterialIcons')
      : null;
  setIcon(IconData value) {
    iconIndex = value.codePoint;
  }

  int? iconIndex;
  int? instanceCount;

  Field({
    required this.name,
    required this.path,
    required this.type,
    this.isCustomField = true,
    this.iconIndex,
  }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Field.fromDatabase(String fieldId, Map<String, dynamic> json) {
    id = fieldId;
    type = FieldType.values[json['type']];
    created = json['created'];
    name = json['name'];
    path = json['path'];
    iconIndex = json['iconIndex'];
    lastUsed = json['lastUsed'];
    instanceCount = json['instanceCount'];
    isCustomField =
        json['isCustomField'] != null ? json['isCustomField'] : false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'type': type.index,
      'created': created,
      'name': name,
      'path': path,
      'iconIndex': iconIndex,
      'lastUsed': lastUsed,
      'instanceCount': instanceCount,
      'isCustomField': isCustomField,
    };
    json.removeWhere((key, value) => value == false);
    return json;
  }

  @override
  String toString() {
    // TODO: implement toString
    return '<Field:$id:$name>';
  }
}

enum FieldType {
  contentType,
  tag,
  string,
  number,
  link,
  date,
  time,
  rating,
}
