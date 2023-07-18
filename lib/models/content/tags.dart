class ContentTags {
  late List<String> values;
  ContentTags({required this.values});
  ContentTags.fromJson(Map<String, dynamic> json) {
    values = json['values'] != null ? json['values'].cast<String>() : null;
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'values': values,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
