import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/fields/default_fields.dart';
import 'package:stashmobile/app/fields/model.dart';
import 'package:stashmobile/app/providers/collections.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/models/field/field.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';

final fieldProvider = Provider<FieldManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user != null) {
    return FieldManager(
      collectionManager: ref.watch(collectionProvider),
      user: user,
      db: ref.watch(databaseProvider),
    );
  }
  throw UnimplementedError();
});

final fieldViewProvider = ChangeNotifierProvider((ref) => FieldsViewModel(
    fieldManager: ref.watch(fieldProvider),
    treeView: ref.watch(treeViewProvider),
    contentManager: ref.watch(contentProvider)));

enum ContentManagerMode { disk, cloud }

class FieldManager {
  CollectionManager collectionManager;
  User user;
  FirestoreDatabase db;

  FieldManager({
    required this.collectionManager,
    required this.user,
    required this.db,
  }) {
    loadFields();
  }

  Map<String, Field> fields = {};

  loadFields() async {
    //setFieldsAreLoading(true);
    final fieldsFromDB = await db.getUserFields(user);
    if (fieldsFromDB.isEmpty) {
      addDefaultFields();
    } else {
      fieldsFromDB.forEach((field) {
        fields[field.id] = field;
      });
    }
    //setFieldsAreLoading(false);
  }

  addDefaultFields() async {
    defaultFields.forEach((field) {
      fields[field.id] = field;
    });
    await db.setUserFields(user.id, fields.values.toList());
  }

  Set<String> fieldsInTree = {};

  saveField(Field field) async {
    print('Saving field: $field');
    fields[field.id] = field;
    await db.setUserField(user.id, field);
  }
}
