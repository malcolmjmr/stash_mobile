import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/fields.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/field/field.dart';
import 'package:recase/recase.dart';
import 'package:stashmobile/routing/app_router.dart';

class FieldsViewModel extends ChangeNotifier {
  FieldManager fieldManager;
  ContentManager contentManager;
  TreeViewModel treeView;
  FieldsViewModel({
    required this.fieldManager,
    required this.contentManager,
    required this.treeView,
  });

  bool showFullScreen = false;
  setFullScreen(bool value) {
    showFullScreen = value;
  }

  onSearchOpen() => setFullScreen(true);

  goBack(BuildContext context) =>
      context.read(appProvider).menuView.setSubMenuView(null);

  TextEditingController searchTextController = TextEditingController();
  onSearchUpdated(String text) {
    relevantContentFields = contentFields.where(matchesSearch).toList();
    relevantSuggestedFields = suggestedFields.where(matchesSearch).toList();
    notifyListeners();
  }

  bool matchesSearch(FieldViewModel fieldModel) => fieldModel.field.name
      .toLowerCase()
      .contains(searchTextController.text.toLowerCase());

  List<FieldViewModel> relevantContentFields = [];
  List<FieldViewModel> relevantSuggestedFields = [];

  onSearchSubmit(BuildContext context, String text) {
    if (needToCreateNewField) addFieldFromTextField(text, context: context);
  }

  bool shouldAutoFocusSearch(BuildContext context) =>
      Navigator.of(context).canPop() &&
      !contentFields.any((fieldModel) =>
          fieldModel.valueIsSelected || fieldModel.nameIsSelected);

  bool isLoading = false;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  loadFields() {
    setIsLoading(true);
    getContentFields();
    getSuggestedFields();
    setIsLoading(false);
  }

  List<FieldViewModel> contentFields = [];
  getContentFields() {
    final root = treeView.rootNode.content;

    bool fieldIsSelected(Field field) => treeView.selected.isEmpty
        ? (root.customFields?.keys.contains(field.id) ?? false)
        : treeView.selected.every((node) =>
            node.content.customFields?.values.contains(field.id) ?? false);
    final Content content =
        treeView.selected.isEmpty ? root : treeView.selected.first.content;
    contentFields = fieldManager.fields.values
        .where(fieldIsSelected)
        .map((field) => FieldViewModel(
            field: field, value: content.customFields![field.id]))
        .toList();
    contentFields.sort(sortFieldsByLastUsed);
    relevantContentFields = contentFields.toList();
  }

  int sortFieldsByLastUsed(FieldViewModel a, FieldViewModel b) =>
      (a.field.lastUsed ?? 0).compareTo(b.field.lastUsed ?? 0);

  List<FieldViewModel> suggestedFields = [];

  getSuggestedFields() {
    getFieldsWithinTree();
    getRemainingFields();
  }

  getFieldsWithinTree() {
    List<FieldViewModel> fields = fieldManager.fieldsInTree
        .where(
      (fieldId) => !contentFields.any((model) => fieldId != model.field.id),
    )
        .map((fieldId) {
      print(fieldId);
      return FieldViewModel(
          field: fieldManager.fields[fieldId]!, isInTree: true);
    }).toList();
    fields.sort(sortFieldsByLastUsed);
    suggestedFields.addAll(fields);
    relevantSuggestedFields = suggestedFields.toList();
  }

  getRemainingFields() {
    List<FieldViewModel> fields = fieldManager.fields.values
        .where(
          (field) =>
              field.isCustomField &&
              !contentFields.any((model) => field.id == model.field.id) &&
              !suggestedFields.any((model) => field.id == model.field.id),
        )
        .map((field) => FieldViewModel(field: field))
        .toList();
    fields.sort(sortFieldsByLastUsed);
    suggestedFields.addAll(fields);
  }

  LinkedHashMap<FieldType, IconData> typeToIconMap = LinkedHashMap.from({
    FieldType.number: Icons.tag,
    FieldType.string: Icons.font_download,
    FieldType.date: Icons.event,
    FieldType.time: Icons.schedule,
  });

  onFieldTypeChange(FieldViewModel fieldModel, int typeIndex) async {
    fieldModel.field.type = typeToIconMap.keys.toList()[typeIndex];
    await fieldManager.saveField(fieldModel.field);
    notifyListeners();
  }

  onLongPressFieldName(BuildContext context, FieldViewModel fieldModel) {
    contentFields.forEach((model) {
      if (model.nameIsSelected) model.nameIsSelected = false;
      if (model.valueIsSelected) model.valueIsSelected = false;
    });
    fieldModel.nameIsSelected = true;
    openFullScreen(context);
    notifyListeners();
  }

  saveFieldName(FieldViewModel fieldModel, String name) async {
    fieldModel.field.name = name;
    await fieldManager.saveField(fieldModel.field);
    fieldModel.nameIsSelected = false;
    notifyListeners();
  }

  onLongPressFieldValue(BuildContext context, FieldViewModel fieldModel) async {
    contentFields.forEach((model) {
      if (model.nameIsSelected) model.nameIsSelected = false;
      if (model.valueIsSelected) model.valueIsSelected = false;
    });
    fieldModel.valueIsSelected = true;
    openFullScreen(context);
    notifyListeners();
  }

  saveFieldValue(FieldViewModel fieldModel, var value) async {
    fieldModel.value = value;
    Content content = treeView.rootNode.content;
    if (content.customFields == null) content.customFields = {};
    content.customFields![fieldModel.field.id] = fieldModel.value;
    await contentManager.saveContent(content);
    fieldModel.valueIsSelected = false;
    notifyListeners();
  }

  bool get needToCreateNewField =>
      relevantContentFields.isEmpty &&
      relevantSuggestedFields.isEmpty &&
      searchTextController.text.isNotEmpty;

  addFieldFromSuggestions(BuildContext context, FieldViewModel fieldModel) {
    fieldModel.valueIsSelected = true;
    suggestedFields.remove(fieldModel);
    contentFields.add(fieldModel);
    openFullScreen(context);
    notifyListeners();
  }

  openFullScreen(BuildContext context) {
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) navigator.pushNamed(AppRoutes.contentFields);
  }

  addFieldFromTextField(String name, {BuildContext? context}) async {
    print('adding new field');
    Field newField = Field(
      name: name,
      isCustomField: true,
      path: 'customFields.${name.camelCase}',
      type: FieldType.string,
    );
    await fieldManager.saveField(newField);
    contentFields.add(FieldViewModel(field: newField, valueIsSelected: true));
    searchTextController.clear();
    notifyListeners();
  }

  addFieldFromTextSelection(String selectedText) {}
}

class FieldViewModel {
  Field field;
  dynamic value;
  bool isSelected;
  bool nameIsSelected = false;
  bool valueIsSelected = false;
  bool isInTree;
  FieldViewModel({
    required this.field,
    this.value,
    this.isSelected = false,
    this.valueIsSelected = false,
    this.nameIsSelected = false,
    this.isInTree = false,
  });
}
