import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';
import 'package:recase/recase.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late FilterManager filters;
  ViewModel(this.context) {
    filters = context.read(filterProvider);
    loadFieldSpec();
    refreshTypeList();
  }

  FieldSpec fieldSpec = FieldSpec(
    fieldPath: 'type',
    isInclusive: true,
    operations: [
      Operation(operator: FilterOperator.equals, values: [], isInclusive: true)
    ],
  );

  loadFieldSpec() {
    int index = filters.getFieldSpecIndex(fieldSpec);
    if (index >= 0) {
      fieldSpec = filters.contentFilter.filter!.fieldSpecs![index];
      final indexOfOperator = fieldSpec.operations
              ?.indexWhere((op) => op.operator == FilterOperator.equals) ??
          -1;
      if (indexOfOperator < 0) {
        if (fieldSpec.operations == null) fieldSpec.operations = [];
        fieldSpec.operations!.add(Operation(
            operator: FilterOperator.equals, values: [], isInclusive: true));
      }
    }
  }

  List<TypeViewModel> typeList = [];
  bool typeListIsLoading = false;
  setTypeListIsLoading(bool value) {
    typeListIsLoading = value;
    notifyListeners();
  }

  refreshTypeList() {
    setTypeListIsLoading(true);
    typeList = ContentType.values
        .where((type) =>
            ![ContentType.webArticle, ContentType.empty].contains(type))
        .map((type) => TypeViewModel(
            type: type,
            isSelected: fieldSpec.operations!
                .firstWhere((op) => op.operator == FilterOperator.equals)
                .values
                .contains(type.index)))
        .toList();
    typeList
        .sort((a, b) => (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0));
    setTypeListIsLoading(false);
  }

  toggleTypeSelection(TypeViewModel typeViewModel) {
    if (typeViewModel.isSelected) {
      fieldSpec.operations!
          .firstWhere((op) => op.operator == FilterOperator.equals)
          .values
          .remove(typeViewModel.type.index);
    } else {
      fieldSpec.operations!
          .firstWhere((op) => op.operator == FilterOperator.equals)
          .values
          .add(typeViewModel.type.index);
    }
    //print(fieldSpec.toJson());
    filters.setFieldSpec(fieldSpec);
    refreshTypeList();
  }
}

class TypeViewModel {
  ContentType type;
  bool isSelected;
  late String title;
  TypeViewModel({
    required this.type,
    required this.isSelected,
  }) {
    title = type.toString().split('.')[1].titleCase;
  }
}
