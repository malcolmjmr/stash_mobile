import 'package:uuid/uuid.dart';

class Note {
  /*
    goals/tasks
    text
    chat
    resources

    create highlight => add note => chat 
    || create highlight => chat 
    || create highlight => view related => link related

  */

  String? id;
  String? subject = '';
  String? text = '';
  List<Objective> objectives = [];
  List<Comment> comments = [];
  List<String> keywords = [];
  List<String> metaTags = [];
  late int created;

  Note({ this.subject }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    subject = json['subject'] ?? '';
    text = json['text'] ?? '';
    objectives = json['objectives'] != null ? List<Objective>.from(json['objectives'].map((o) => Objective.fromJson(o))) : [];
    comments = json['comments'] != null ? List<Comment>.from(json['comments'].map((c) => Comment.fromJson(c))) : [];
    keywords = json['keywords'] ?? [];
    metaTags = json['metaTags'] ?? [];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'created': created,
      'subject': subject,
      'text': text,
      'objectives': objectives.map((o) => o.toJson()),
      'comments': comments.map((c) => c.toJson()),
      'keywords': keywords,
      'metaTags': metaTags,
    };
    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "");
    return json;
  }

}

class Comment {
  String? id;
  String? user;
  String? text = '';
  bool aiGenerated = false;
  String? replyTo;
  late int created;

  Comment({ this.text }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    user = json['user'];
    text = json['text'];
    aiGenerated = json['aiGenerated'] ?? false;
    replyTo = json['replyTo'];
  }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'created': created,
      'text': text,
      'user': user,
      'aiGenerated': aiGenerated,
      'replyTo': replyTo,
    };
    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "" || value == false);
    return json;
  }

}

class Objective {
  String? id;
  String? statement;
  bool completed = false;
  late int created;
  int? due;

  Objective({ this.statement }) {
    id = Uuid().v4().split('-').last;
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Objective.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created = json['created'];
    statement = json['statement'];
    completed = json['completed'] ?? false;
    due = json['due'] ?? false;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'created': created,
      'statement': statement,
      'completed': completed,
      'due': due,
    };
    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "" || value == false);
    return json;
  }
}

