class ContentReminders {
  int? last;
  late int next;
  bool? spacedRepeat;

  ContentReminders(DateTime time) {
    next = time.millisecondsSinceEpoch;
  }

  setNext(DateTime time) {
    last = next;
    next = time.millisecondsSinceEpoch;
  }

  ContentReminders.fromJson(Map<String, dynamic> json) {
    next = json['next'];
    last = json['last'];
    spacedRepeat = json['spacedRepeat'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'next': next,
      'last': last,
      'spacedRepeat': spacedRepeat,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
