
class ContentVisits {
  List<UserVisit>? all;
  int? count;
  int? lastVisited;

  ContentVisits({this.count = 1}) {
    lastVisited = DateTime.now().millisecondsSinceEpoch;
  }

  addNewVisit() {
    count = count == null ? 1 : count! + 1;
    lastVisited = DateTime.now().millisecondsSinceEpoch;
  }

  ContentVisits.fromJson(Map<String, dynamic> json) {
    all = json['all'] != null
        ? List<UserVisit>.from(
            json['all'].map((data) => UserVisit.fromJson(data)))
        : null;
    count = json['count'];
    lastVisited = json['last'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'all': all?.map((userVisit) => userVisit.toJson()).toList(),
      'count': count,
      'last': lastVisited,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class UserVisit {
  String? user;
  late int time;
  UserVisit({this.user}) {
    time = DateTime.now().millisecondsSinceEpoch;
  }

  UserVisit.fromJson(List<dynamic> data) {
    user = data[0];
    time = data[1];
  }

  List<dynamic> toJson() {
    return [user, time];
  }
}
