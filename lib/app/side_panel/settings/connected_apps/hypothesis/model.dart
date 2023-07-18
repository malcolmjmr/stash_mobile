import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/providers/logger_provider.dart';
import 'package:stashmobile/app/side_panel/settings/connected_apps/model.dart';
import 'package:stashmobile/models/content/type_fields/annotation.dart';
import 'package:stashmobile/models/content/links.dart';
import 'package:stashmobile/models/content/tags.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';
import 'package:stashmobile/services/hypothesis.dart';

class Model {
  late Logger logger;
  late FirestoreDatabase db;
  late User user;
  late HypothesisSettings settings;
  final Hypothesis h = Hypothesis();

  Model(BuildContext context) {
    logger = context.read(loggerProvider);
    db = context.read(databaseProvider);
    user = context.read(sessionProvider).user!;
    if (user.connectedApps == null) {
      user.connectedApps = ConnectedAppSettings();
    }
    settings = user.connectedApps!.hypothesis;
  }

  saveHypothesisUserName(String userName) async {
    user.connectedApps!.hypothesis.userName = userName;
    await db.updateUser(user);
  }

  saveApiToken(String apiToken) async {
    user.connectedApps!.hypothesis.apiToken = apiToken;
    user.connectedApps!.hypothesis.userName = Hypothesis.userName;
    await db.updateUser(user);
  }

  syncAnnotations() async {
    if (settings.userName == null) {
      return;
    }
    // final lastSyncTime;
    final annotations =
        await h.getUserAnnotations(settings.userName!, limit: 700);
    logger.i('Got ${annotations.length} annotations.');
    await saveHypothesisAnnotationsToFirebase(annotations);
    await saveSyncTime();
  }

  saveHypothesisAnnotationsToFirebase(
      List<dynamic> hypothesisAnnotations) async {
    // Todo: Check for duplicates among preexisting elements

    List<Content> content = [];
    Map<String, int> documentIndexByUrl =
        Map(); // key = url, value = index within content list
    Map<String, int> groupIndexByName =
        Map(); // key = group name, value index within content list
    await h.getGroups();

    for (Map<String, dynamic> json in hypothesisAnnotations) {
      // Handle document data
      String documentUrl = json['uri'];
      int documentIndex;
      if (!documentIndexByUrl.keys.contains(documentUrl)) {
        final document = createWebDocumentFromHypothesisData(json);
        documentIndex = content.length;
        content.add(document);
        documentIndexByUrl[document.url!] = documentIndex;
      } else {
        documentIndex = documentIndexByUrl[documentUrl]!;
      }

      // Handle group data
      String groupName = json['group'];
      int? groupIndex;
      if (groupName != Hypothesis.publicGroupName) {
        if (!groupIndexByName.keys.contains(groupName)) {
          final group = createHeadingFromHypothesisData(json);
          groupIndex = content.length;
          content.add(group);
          groupIndexByName[groupName] = groupIndex;
        } else {
          groupIndex = groupIndexByName[groupName]!;
        }
      }

      Content annotation = createAnnotationFromHypothesisData(json);

      // Create links between elements
      annotation.annotation!.document = content[documentIndex].id;
      //content[documentIndex].webArticle!.addAnnotationId(annotation.id);
      if (groupIndex != null) {
        if (annotation.links == null) {
          annotation.links = ContentLinks();
        }
        annotation.links!.addBackLinkId(content[groupIndex].id);
        if (content[groupIndex].links == null) {
          content[groupIndex].links = ContentLinks();
        }
        content[groupIndex].links!.addForwardLinkId(annotation.id);
      }
      content.add(annotation);
    }
    // logger.i(content
    //     .where((c) => c.webArticle != null)
    //     .map((c) => c.webArticle!.toJson())
    //     .toList());
    await db.saveBatchOfContent(user.id, user.currentCollection!, content);
    logger.i('Saved ${content.length} elements.');
  }

  Content createHeadingFromHypothesisData(Map<String, dynamic> data) => Content(
        name: h.groups![data['group']]['name'],
      );

  Content createWebDocumentFromHypothesisData(Map<String, dynamic> data) =>
      Content(
        name: data['document']['title']?.first,
        type: ContentType.webArticle,
        //webArticle: WebArticleFields(url: data['uri']),
      );

  Content createAnnotationFromHypothesisData(
    Map<String, dynamic> data,
  ) =>
      Content(
        type: ContentType.annotation,
        creationTime: DateTime.parse(data['created']).microsecondsSinceEpoch,
        tags: data['tags'] != null || data['tags'] != []
            ? ContentTags(values: data['tags'].cast<String>())
            : null,
        annotation: AnnotationFields(
          target: data['target'],
          note: data['text'],
          connectedAppId: data['id'],
          connectedAppSource: ConnectedApps.hypothesis,
        ),
      );

  saveSyncTime() async {
    user.connectedApps!.hypothesis.lastSynced =
        DateTime.now().microsecondsSinceEpoch;
    await db.updateUser(user);
  }
}
