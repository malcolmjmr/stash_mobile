import 'package:freezed_annotation/freezed_annotation.dart';

class Chat {
  
  late int created; 
  List<Message> messages = [];
  String? parentId;

  Chat({String? selectedText, this.parentId, this.messages = const []}){
    created = DateTime.now().millisecondsSinceEpoch;

    if (selectedText != null && selectedText.isNotEmpty)  {
      messages = [
        Message.text(text: selectedText, isTextSelection: true)
      ];
    }
  }

  Chat.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    parentId = json['parentId'];
    messages = json['messages'] != null ? List<Message>.from(json['messages'].map((m) => Message.fromJson(m))) : [];
  }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'created': created,
      'parentId': parentId,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "" || value == false);
    return json;
  }
}


class Message {
  late int created;

  List<String> responses = [];

  List<MessageContent> content = [];

  String role = Role.user;
  String? get text {
    return content.firstWhereOrNull((c) => c.type == ContentType.text)?.text;
  }
  String? get imageUrl {
    return content.firstWhereOrNull((c) => c.type == ContentType.imageUrl)?.imageUrl?.url;
  }

  String? get textSelection {
    return content.firstWhereOrNull((c) => c.isTextSelection)?.text;
  }

  String? get resourceId {
    return content.firstWhereOrNull((c) => c.resourceId != null)?.resourceId;
  }

  addImageUrl(String url) {
    content.add(MessageContent(imageUrl: ImageUrl(url)));
  }


  

  /*
    prompt id
    reference id
  */

  Message({this.role = Role.user, this.content = const []}) {
    created = DateTime.now().millisecondsSinceEpoch;
  }

  Message.fromMultipleModels(_responses) {
    created = DateTime.now().millisecondsSinceEpoch;
    role = Role.assistant;
    responses = responses;
    content = [MessageContent(text: responses[0])];
  }

  Message.fromJson(Map<String, dynamic> json) {
    created = json['created'] ?? DateTime.now().millisecondsSinceEpoch;
    content = json['content'] != null 
      ? List<MessageContent>.from(json['content'].map((m) => MessageContent.fromJson(m))) 
      : [];
    role = json['role'];
  }

  Message.text({String? text, this.role = Role.user, bool isTextSelection = false}){
    created = DateTime.now().millisecondsSinceEpoch;
    content = [MessageContent(text: text, isTextSelection: isTextSelection)];
  }


  Map<String, dynamic> toJson({bool forRequest = false, bool basicSchema = true}) {
    Map<String, dynamic> json = {

      'content': forRequest && basicSchema
        ? content.map((c) => c.text ?? '').join('\n')
        : content.map((c) => c.toJson(forRequest: forRequest)).toList(),
      'role': role,
    };

    if (!forRequest) {
      json = {
        ...json,
        'created': created,
      };
    }
    
    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "" || value == false);
    return json;
  }

}

class MessageContent {

  String get type {
    if (text != null) {
      return ContentType.text;
    } else if (imageUrl != null) {
      return ContentType.imageUrl;
    } else {
      return ContentType.text;
    }
  } 
  String? text;
  ImageUrl? imageUrl;
  bool isTextSelection = false;
  String? resourceId;

  MessageContent({ this.text, this.imageUrl, this.isTextSelection = false, this.resourceId});
  
  MessageContent.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'] != null ? ImageUrl(json['imageUrl']) : null;
    text = json['text'];
    isTextSelection = json['isTextSelection'] == true;
    resourceId = json['resourceId'];
  }


  Map<String, dynamic> toJson({bool forRequest = false}) {
    Map<String, dynamic> json = {
      'type': type,
      'text': text,
      'imageUrl': imageUrl?.toJson(),
    };
    if (!forRequest) {
      json.addAll({
        'isTextSelection': isTextSelection,
        'resourceId': resourceId,
      });
    }

    json.removeWhere((key, value) => value == null || value == [] || value == 0 || value == "" || value == false);
    return json;
  }
}

class ImageUrl {

  late String url;

  ImageUrl(this.url);

  ImageUrl.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': url
    };
  }
}

class Prompt {
  late String text;
  late String name;
  String? symbol;

  Prompt({required this.text, required this.name, this.symbol});

  Prompt.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    name = json['name'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'name': name,
      'symbol': symbol,
    };
  }
}

class ContentType {
  static const String text = 'text';
  static const String imageUrl = 'image_url';
}



class Role {
  static const String assistant = 'assistant';
  static const String user = 'user';
  static const String system = 'system';
}

