import 'package:stashmobile/app/side_panel/settings/connected_apps/model.dart';

class AnnotationFields {
  String? connectedAppId;
  ConnectedApps? connectedAppSource;
  String get highlight => target['selector']?.firstWhere(
      (selector) => selector['type'] == 'TextQuoteSelector')['exact'];
  late String document;
  String? documentTitle;
  String? note;
  List<String>? keywords;
  late Map<String, dynamic> target;

  AnnotationFields({
    this.connectedAppId,
    this.connectedAppSource,
    this.keywords,
    this.note,
    this.document = '',
    this.documentTitle,
    required this.target,
  });

  AnnotationFields.fromJson(Map<String, dynamic> json) {
    document = json['document'];
    documentTitle = json['documentTitle'];
    connectedAppId = json['connectedAppId'];
    connectedAppSource = json['connectedAppSource'] != null
        ? ConnectedApps.values[json['connectedAppSource']]
        : null;
    keywords = json['keywords'];
    note = json['note'];
    target = json['target'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'document': document,
      'connectedAppId': connectedAppId,
      'connectedAppSource': connectedAppSource?.index,
      'keywords': keywords,
      'note': note,
      'target': target,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
