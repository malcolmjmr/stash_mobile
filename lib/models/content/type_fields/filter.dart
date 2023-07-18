import 'package:stashmobile/models/content/content.dart';

class FilterFields {
  String? searchText;
  List<ContentType>? types;
  List<FieldSpec>? fieldSpecs;
  bool? isInclusive;
  int? lastUsed;

  FilterFields(
      {this.searchText, this.types, this.fieldSpecs, this.isInclusive});

  FilterFields.fromJson(Map<String, dynamic> json) {
    searchText = json['searchText'];
    types =
        json['types'] != null ? List<ContentType>.from(json['types']) : null;
    fieldSpecs = json['fieldSpecs'] != null
        ? List<FieldSpec>.from(json['fieldSpecs']
            .map((field) => FieldSpec.fromJson(field))
            .toList())
        : null;
    isInclusive = json['isInclusive'];
    lastUsed = json['lastUsed'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'searchText': searchText,
      'types': types,
      'fieldSpecs': fieldSpecs != null
          ? fieldSpecs!.map((spec) => spec.toJson()).toList()
          : null,
      'isInclusive': isInclusive,
      'lastUsed': lastUsed,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  bool criteriaAreSatisfied(Content content) {
    bool result = true;
    //print(content);
    result &= fieldSpecs?.every((fieldSpec) {
          //print(fieldSpec);
          return fieldSpec.operations?.every(
                (operation) {
                  //print(operation.operator);
                  return operation.evaluate(
                    content.getFieldValueByPath(fieldSpec.fieldPath),
                  );
                },
              ) ??
              true;
        }) ??
        true;

    return result;

    return result;
//    // Handle type filters
//    if (typeFilters.contains(ElementType.filter) && !element.isFilter) {
//      return false;
//    } else if (typeFilters.contains(ElementType.webSearch) &&
//        !(element.isWebSearch ?? false)) {
//      return false;
//    } else if (typeFilters.contains(ElementType.website) &&
//        element.url == null) {
//      return false;
//    } else if (typeFilters.contains(ElementType.highlight) &&
//        !(element.isHighlight ?? false)) {
//      return false;
//    } else if (typeFilters.contains(ElementType.term) &&
//        !(element.isTerm ?? false)) {
//      return false;
//    }
//
//    final isSatisfied = (FieldFilter filter) => filter.evaluateElement(element);
//    final relevantFilters = fieldFilters.where(
//        (filter) => filter.operations != null && filter.operations.isNotEmpty);
//    return isInclusiveFilter ?? false
//        ? relevantFilters.any(isSatisfied)
//        : relevantFilters.every(isSatisfied);
    return false;
  }

  List<FieldSpec>? sortFields;

  int sortContent(Content a, Content b) {
    if (fieldSpecs == null) {
      return 0;
    }

    if (sortFields == null) {
      sortFields = fieldSpecs!
          .where((fieldSpec) => fieldSpec.sortAscending != null)
          .toList();
    }

    int comp = 0;

    for (FieldSpec spec in fieldSpecs!) {
      if (spec.sortAscending == null) continue;

      final aFieldValue = a.getFieldValueByPath(spec.fieldPath);
      final bFieldValue = b.getFieldValueByPath(spec.fieldPath);
      // print('Field path: ${spec.fieldPath}');
      //
      // print('A: $aFieldValue');
      // print(a.toJson());
      // print('B: $bFieldValue');
      // print(b.toJson());
      final isListField = aFieldValue is List || bFieldValue is List;
      if (spec.sortAscending!) {
        if (isListField) {
          comp = (aFieldValue?.length ?? 0).compareTo(bFieldValue?.length ?? 0);
        } else {
          comp = (aFieldValue ?? 0).compareTo(bFieldValue ?? 0);
        }
      } else {
        if (isListField) {
          comp = (bFieldValue?.length ?? 0).compareTo(aFieldValue?.length ?? 0);
        } else {
          comp = (bFieldValue ?? 0).compareTo(aFieldValue ?? 0);
        }
      }
      if (comp != 0) return comp;
    }
    return comp;
  }
}

class FieldSpec {
  FieldSpec({
    required this.fieldPath,
    this.operations,
    this.isInclusive,
    this.sortAscending,
  });

  late String fieldPath;
  List<Operation>? operations;
  bool? isInclusive;
  bool? sortAscending;
  bool? isVisible;

  bool evaluateElement(Content content) {
    // final defaultFields = element.toJson();
    // var fieldValue;
    // if (defaultFields[field] != null) {
    //   fieldValue = defaultFields[field];
    // } else if (element.fields != null ?? element.fields[field] != null) {
    //   fieldValue = element.fields[field];
    // } else {
    //   return false;
    // }
    // Function isSatisfactory = (op) => op.evaluateFieldValue(fieldValue);
    // return isInclusive
    //     ? operations.any(isSatisfactory)
    //     : operations.every(isSatisfactory);
    return false;
  }

  FieldSpec.fromJson(Map<String, dynamic> json) {
    fieldPath = json['fieldPath'];
    operations = json['operations'] != null
        ? json['operations']
            .map((operation) => Operation.fromJson(operation))
            .toList()
            .cast<Operation>()
        : null;
    isInclusive = json['isInclusive'];
    sortAscending = json['sortAscending'];
    isVisible = json['isVisible'];
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldPath': fieldPath,
      'operations': operations != null
          ? operations!.map((operation) => operation.toJson()).toList()
          : null,
      'isInclusive': isInclusive,
      'sortAscending': sortAscending,
      'isVisible': isVisible,
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}

enum FilterOperator {
  exists,
  doesNotExist,
  equals,
  doesNotEqual,
  greaterThan,
  greaterThanOrEqualTo,
  lessThan,
  lessThanOrEqualTo,
  contains,
  doesNotContain,
  between,
  countEquals,
  countIsGreaterThan,
  countIsLessThan,
}

class Operation {
  late FilterOperator operator;
  late List values;
  bool? isInclusive;

  Operation({required this.operator, required this.values, this.isInclusive});

  evaluate(fieldValue) {
    final Map<FilterOperator, bool Function(dynamic)> opFunctions = {
      FilterOperator.exists: (value) => fieldValue != null,
      FilterOperator.doesNotExist: (value) => fieldValue == null,
      FilterOperator.equals: (value) => fieldValue == value,
      FilterOperator.doesNotEqual: (value) => fieldValue != value,
      FilterOperator.contains: (value) => fieldValue?.contains(value) ?? false,
      FilterOperator.greaterThanOrEqualTo: (value) => fieldValue >= value,
      FilterOperator.greaterThan: (value) => fieldValue > value,
      FilterOperator.lessThan: (value) => fieldValue < value,
      FilterOperator.lessThanOrEqualTo: (value) => fieldValue <= value,
    };
    final bool Function(dynamic) isSatisfied = opFunctions[operator]!;

    bool notCheckingValues =
        [FilterOperator.exists, FilterOperator.doesNotExist].contains(operator);
    if (notCheckingValues)
      return isSatisfied(null);
    else
      return isInclusive ?? false
          ? values.any(isSatisfied)
          : values.every(isSatisfied);
  }

  Operation.fromJson(Map<String, dynamic> json) {
    operator = FilterOperator.values[json['operator']];
    values = json['values'];
    isInclusive = json['isInclusive'];
  }

  Map<String, dynamic> toJson() {
    return {
      'operator': operator.index,
      'values': values,
      'isInclusive': isInclusive,
    };
  }
}
