
class ContentRatings {
  late int value;
  List<int>? values;

  ContentRatings({this.value = 0, this.values});

  updateRating(int rating) {
    value = rating;
  }

  ContentRatings.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    values = json['values'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'value': value,
      'values': values,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
