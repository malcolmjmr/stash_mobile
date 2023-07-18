class NoteFields {
  late String body;

  NoteFields({this.body = ''});

  NoteFields.fromJson(Map<String, dynamic> json) {
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    return {'body': body};
  }
}
