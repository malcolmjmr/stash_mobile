import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';

import 'content_manager.dart';

final filterProvider = ChangeNotifierProvider(
  (ref) => FilterManager(contentManager: ref.watch(contentProvider)),
);

class FilterManager extends ChangeNotifier {
  ContentManager contentManager;
  FilterManager({required this.contentManager}) {
    loadFilters();
  }

  bool filterRoot = false;

  late Content contentFilter;

  bool get filterIsSaved =>
      contentManager.allContent.containsKey(contentFilter.id);

  setFilter(Content value, {Function()? callback}) async {
    contentFilter = value;
    if (contentFilter.filter == null) {
      //print(contentFilter.toJson());
      //contentFilter.filter = FilterFields(fieldSpecs: [], types: []);
    }
    final recentIndex =
        recentFilters.indexWhere((c) => c.id == contentFilter.id);
    final usedRecently = recentIndex >= 0;
    if (usedRecently) {
      recentFilters.removeAt(recentIndex);
    }
    recentFilters.insert(0, contentFilter);

    //contentFilter.filter!.lastUsed = DateTime.now().microsecondsSinceEpoch;
    //await contentManager.saveContent(contentFilter);
    notifyListeners();
    callback?.call();
  }

  Map<String, Content> allFilters = {};
  List<Content> recentFilters = [];
  loadFilters() {
    allFilters = Map.fromIterable(
        contentManager.allContent.values.where((c) => c.filter != null),
        key: (f) => f.id,
        value: (f) => f);

    List<Content> tempRecentFilters = allFilters.values.toList();
    tempRecentFilters
        .sort((a, b) => (b.updates?.last ?? 0).compareTo(a.updates?.last ?? 0));
    recentFilters = tempRecentFilters.toList();

    resetFilter();
  }

  resetFilter() {
    contentFilter = Content(
      type: ContentType.filter,
      filter: FilterFields(fieldSpecs: [], types: []),
    );
  }

  cleanFilter() {
    for (FieldSpec spec in contentFilter.filter!.fieldSpecs!)
      spec.operations?.removeWhere((op) =>
          ![FilterOperator.exists, FilterOperator.doesNotExist]
              .contains(op.operator) &&
          op.values.isEmpty);

    contentFilter.filter!.fieldSpecs!.removeWhere((spec) =>
        (spec.operations?.isEmpty ?? true) &&
        spec.sortAscending == null &&
        spec.isVisible == null);
  }

  // ================================= Field =======================================

  FieldSpec getFieldSpecFromPath(String fieldPath) =>
      contentFilter.filter!.fieldSpecs!.firstWhere(
          (specification) => specification.fieldPath == fieldPath,
          orElse: () => FieldSpec(fieldPath: fieldPath));

  int getFieldSpecIndex(FieldSpec fieldSpec) =>
      contentFilter.filter!.fieldSpecs!.indexWhere(
          (specification) => specification.fieldPath == fieldSpec.fieldPath);

  setFieldSpec(FieldSpec value) {
    int fieldSpecIndex = getFieldSpecIndex(value);
    if (fieldSpecIndex == -1)
      contentFilter.filter!.fieldSpecs!.add(value);
    else
      contentFilter.filter!.fieldSpecs![fieldSpecIndex] = value;

    if (filterIsSaved) saveFilter();
  }

  removeFieldSpec(FieldSpec value) {
    int fieldSpecIndex = getFieldSpecIndex(value);
    if (fieldSpecIndex >= 0)
      contentFilter.filter!.fieldSpecs!.removeAt(fieldSpecIndex);
    if (filterIsSaved) saveFilter();
  }

  saveFilter() async {
    await contentManager.saveContent(contentFilter);
  }

  int get filterCount =>
      contentFilter.filter?.fieldSpecs
          ?.where(
              (spec) => spec.operations != null && spec.operations!.isNotEmpty)
          .length ??
      0;
  int get viewCount =>
      contentFilter.filter?.fieldSpecs
          ?.where((spec) => spec.isVisible == true)
          .length ??
      0;
  int get sortCount =>
      contentFilter.filter?.fieldSpecs
          ?.where((spec) => spec.sortAscending != null)
          .length ??
      0;
}
