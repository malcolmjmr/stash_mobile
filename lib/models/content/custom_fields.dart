class FieldValue {
  late String field;
  late var value;

  FieldValue({required this.field, required this.value});
  FieldValue.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': field,
      'value': value,
    };
  }
}
