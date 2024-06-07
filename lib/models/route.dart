import 'package:stashmobile/models/resource.dart';
import 'package:uuid/uuid.dart';

class Route {

  late String id; 
  late int created;
  String title = '';
  List<Resource> resources = [];

  int skipCount = 0;
  int index = 0; 


  Route() {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Route.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    title = json['title'] ?? '';
    resources = json['resources'] != null ? List<Resource>.from(json['resources'].map((r) => Resource.fromDatabase(r.id, r))) : [];
    index = json['index'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'created': created,
      'title': title,
      'resources': resources,
      'index': index,
    };

    json.removeWhere((key, value) => value == '' || value == 0 || value == null);
    return json;
  }
}