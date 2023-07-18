class TaskFields {
  String? description;
  int? due;
  int? completed;

  TaskFields({this.description, this.due});

  TaskFields.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    due = json['due'];
    completed = json['completed'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'description': description,
      'due': due,
      'completed': completed,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
