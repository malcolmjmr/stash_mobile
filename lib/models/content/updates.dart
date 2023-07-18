class ContentUpdates {
  List<UserUpdate>? all;
  int? count;
  int? last;

  ContentUpdates();

  ContentUpdates.fromJson(Map<String, dynamic> json) {
    all = json['all'] != null
        ? List<UserUpdate>.from(json['all'].map((u) => UserUpdate.fromJson(u)))
        : null;
    count = json['count'];
    last = json['last'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'all': all?.map((u) => u.toJson()).toList(),
      'count': count,
      'last': last,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class UserUpdate {
  late String user;
  late int date;
  UserUpdate({required this.user, int? updateTime}) {
    date =
        updateTime != null ? updateTime : DateTime.now().millisecondsSinceEpoch;
  }

  UserUpdate.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'date': date,
      };
}
