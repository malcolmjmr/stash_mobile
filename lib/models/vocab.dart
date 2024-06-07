class Vocab {

  late String id;
  late String text;
  Vocab({
    required this.text,
  });

  bool reviewed = false;
  bool used = false;
  int importance = 0;

  Vocab.fromJson(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    reviewed = json['reviewed'] == true;
    used = json['used'] == true;
    importance = json['importance'] != null ? json['importance'] : 0;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'text': text,
      'reviewed': reviewed,
      'used': used,
      'importance': importance
    };

    json.removeWhere((key, value) => value == null || value == [] || value == 0);
    return json;
  }

}