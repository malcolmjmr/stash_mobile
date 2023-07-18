import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/fields.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/app/tree/node/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';
import 'package:stashmobile/models/field/field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

enum FilterViewPage {
  filter,
  sort,
  view,
}

class FilterViewModel extends ChangeNotifier {
  Function(Content)? onFilterSelected;
  FilterViewModel(this.context, Content? _filter) {
    filters = context.read(filterProvider);
    fieldManager = context.read(fieldProvider);
    app = context.read(appProvider);
    if (_filter != null) filters.contentFilter = _filter;
    updateRelevantFields();
  }

  BuildContext context;
  late FilterManager filters;
  late FieldManager fieldManager;
  late AppController app;

  refreshPageOnPop(dynamic value) {
    filters.cleanFilter();
    updateRelevantFields();
    notifyListeners();
  }

  clearFilter() {
    filters.resetFilter();
    notifyListeners();
  }

  bool get canClearConfig {
    switch (page) {
      case FilterViewPage.filter:
        return filters.contentFilter.filter?.fieldSpecs?.any((spec) =>
                spec.operations != null && spec.operations!.isNotEmpty) ??
            false;
      case FilterViewPage.sort:
        return filters.contentFilter.filter?.fieldSpecs
                ?.any((spec) => spec.sortAscending != null) ??
            false;
      case FilterViewPage.view:
        return filters.contentFilter.filter?.fieldSpecs
                ?.any((spec) => spec.isVisible != null) ??
            false;
    }
  }

  clearConfig() {
    switch (page) {
      case FilterViewPage.filter:
        filters.contentFilter.filter?.fieldSpecs?.forEach((spec) {
          if (spec.operations != null) spec.operations!.clear();
        });
        break;
      case FilterViewPage.sort:
        filters.contentFilter.filter?.fieldSpecs?.forEach((spec) {
          if (spec.sortAscending != null) spec.sortAscending = null;
        });
        break;
      case FilterViewPage.view:
        filters.contentFilter.filter?.fieldSpecs?.forEach((spec) {
          if (spec.isVisible != null) spec.isVisible = null;
        });
        break;
    }
    notifyListeners();
  }

  setFilter(Content filter) {
    //print(filter.toJson());
    filters.setFilter(filter);
    notifyListeners();
  }

  TextEditingController filterTitleController = TextEditingController();
  bool editingFilterTitle = false;

  updateFilterTitle() {
    if (filters.contentFilter.name != null)
      filterTitleController.text = filters.contentFilter.name!;
    editingFilterTitle = true;
    notifyListeners();
  }

  saveFilterTitle(String text) async {
    editingFilterTitle = false;
    if (text.isNotEmpty) {
      filters.contentFilter.name = text;
      await filters.saveFilter();
    }
    notifyListeners();
  }

  TextEditingController fieldSearchController = TextEditingController();

  List<FilterFieldViewModel> relevantFields = [];

  bool loadingFields = false;
  setLoadingFields(bool value) {
    loadingFields = value;
    notifyListeners();
  }

  updateRelevantFields() async {
    setLoadingFields(true);
    if (fieldManager.fields.isEmpty) await fieldManager.loadFields();

    final selectedFields = filters.contentFilter.filter!.fieldSpecs!
        .map((spec) => FilterFieldViewModel(
            field: fieldManager.fields.values
                .firstWhere((field) => field.path == spec.fieldPath),
            spec: spec))
        .where((model) {
      final doesNotMatchSearch = !model.field.name
          .toLowerCase()
          .contains(fieldSearchController.text.toLowerCase());
      if (doesNotMatchSearch) return false;

      bool isRelevantToPage = false;

      switch (page) {
        case FilterViewPage.sort:
          isRelevantToPage = model.hasSortBy;
          break;
        case FilterViewPage.filter:
          isRelevantToPage = model.hasFilters;
          break;
        case FilterViewPage.view:
          isRelevantToPage = model.spec?.isVisible != null;
      }

      return isRelevantToPage;
    }).toList();
    selectedFields
        .forEach((fieldViewModel) => getFieldValueCounts(fieldViewModel.field));
    final suggestedFields = fieldManager.fields.values
        .where((Field field) {
          final isAlreadySelected = selectedFields
                  .indexWhere((model) => model.field.id == field.id) >=
              0;
          if (isAlreadySelected) return false;

          final doesNotMatchSearch = !field.name
              .toLowerCase()
              .contains(fieldSearchController.text.toLowerCase());
          if (doesNotMatchSearch) return false;

          return true;
        })
        .map((field) => FilterFieldViewModel(field: field))
        .toList();

    relevantFields = [...selectedFields, ...suggestedFields];
    relevantFields.sort((a, b) {
      // is selected
      int selectedComparision =
          (a.isSelected ? 0 : 1).compareTo(b.isSelected ? 0 : 1);
      if (selectedComparision != 0) return selectedComparision;
      // last used
      int lastUsedComparison =
          ((a.field.lastUsed ?? 0).compareTo(b.field.lastUsed ?? 0));
      if (lastUsedComparison != 0) return lastUsedComparison;
      // created
      return a.field.created.compareTo(b.field.created);
    });
    setLoadingFields(false);
  }

  FieldSpec? getFieldSpecFromField(Field field) {
    return filters.contentFilter.filter?.fieldSpecs
        ?.firstWhereOrNull((f) => field.path == f.fieldPath);
  }

  goBack({Function()? callBack}) {
    callBack?.call();
    Navigator.of(context).pop();
  }

  ScrollController scrollController = ScrollController();

  FilterViewPage page = FilterViewPage.filter;
  setPage(FilterViewPage value) {
    page = value;
    updateRelevantFields();
    scrollController.jumpTo(0);
  }

  int getPageConfigCount(FilterViewPage value) {
    switch (value) {
      case FilterViewPage.view:
        return filters.viewCount;
      case FilterViewPage.sort:
        return filters.sortCount;
      case FilterViewPage.filter:
        return filters.filterCount;
    }
  }

  toggleFilterField(FilterFieldViewModel fieldModel) {
    if (fieldModel.hasFilters) {
      fieldModel.spec!.operations = null;
      filters.setFieldSpec(fieldModel.spec!);
    } else {
      //getFieldValueCounts(fieldModel.field);
      FieldSpec spec = filters.getFieldSpecFromPath(fieldModel.field.path);
      spec.operations = [
        Operation(operator: FilterOperator.exists, values: [])
      ];
      filters.setFieldSpec(spec);
    }
    filters.cleanFilter();
    updateRelevantFields();
  }

  Map<String, Map<dynamic, int>> fieldValueMap = {};
  getFieldValueCounts(Field field) {
    final shouldExit = field.type == FieldType.time ||
        field.type == FieldType.date ||
        fieldValueMap.containsKey(field.path);
    if (shouldExit) return;
    //print('getting field values');
    //print(fieldValueMap);
    //print(field.path);
    getValueCounts(TreeNodeViewModel node) {
      var value;
      if (field.type == FieldType.link) {
        final links = node.content.getFieldValueByPath(field.path);
        if (links != null) value = links.length;
      } else {
        value = node.content.getFieldValueByPath(field.path);
      }
      if (value != null) {
        if (!fieldValueMap.keys.contains(field.path))
          fieldValueMap[field.path] = {};
        int count = fieldValueMap[field.path]![value] ?? 0;
        fieldValueMap[field.path]![value] = count + 1;
      }

      node.children.forEach((child) {
        getValueCounts(child);
      });
    }

    getValueCounts(app.treeView.rootNode);
  }

  toggleSortField(FilterFieldViewModel fieldModel) {
    if (fieldModel.hasSortBy) {
      fieldModel.spec!.sortAscending = null;
      filters.setFieldSpec(fieldModel.spec!);
    } else {
      FieldSpec spec = filters.getFieldSpecFromPath(fieldModel.field.path);
      spec.sortAscending = true;
      filters.setFieldSpec(spec);
    }
    updateRelevantFields();
  }

  toggleSortDirection(FilterFieldViewModel fieldModel) {
    fieldModel.spec!.sortAscending = !fieldModel.spec!.sortAscending!;
    filters.setFieldSpec(fieldModel.spec!);
    notifyListeners();
  }

  toggleFieldVisibility(FilterFieldViewModel fieldModel) {
    if (fieldModel.isSelected) {
      fieldModel.spec!.isVisible = null;
      filters.setFieldSpec(fieldModel.spec!);
    } else {
      FieldSpec spec = filters.getFieldSpecFromPath(fieldModel.field.path);
      spec.isVisible = true;
      filters.setFieldSpec(spec);
    }
    notifyListeners();
  }
}

class FilterFieldViewModel {
  Field field;
  FieldSpec? spec;
  FilterFieldViewModel({
    required this.field,
    this.spec,
  });

  bool get isSelected => spec != null;
  bool get hasSortBy => spec?.sortAscending != null;
  bool get sortAscending => spec?.sortAscending ?? true;
  bool get hasFilters => spec?.operations?.isNotEmpty ?? false;
  int get filterCount => spec?.operations?.length ?? 0;
}
