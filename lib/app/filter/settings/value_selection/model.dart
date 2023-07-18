import 'package:flutter/material.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  ViewModel(this.context);

  TextEditingController searchController = TextEditingController();

  List<ValueViewModel> get relevantValues {
    // Todo: get counts for each value
    final searchText = searchController.text.toLowerCase();
    List<ValueViewModel> results = [];
    // switch (field!.type) {
    //   case FieldType.contentType:
    //     results = ContentType.values
    //         .where((type) => type.toString().toLowerCase().contains(searchText))
    //         .map((type) => ValueViewModel(
    //               name: type.toString().split('.').last.titleCase,
    //               value: type,
    //               isSelected: operationSpec!.values.contains(type.index),
    //               count: contentManager.allContent.values
    //                   .where((content) => content.type == type)
    //                   .length,
    //             ))
    //         .toList();
    //     break;
    //   case FieldType.link:
    //     results = contentManager.allContent.values
    //         .where((content) =>
    //             content.links != null &&
    //             (field!.path.contains('back')
    //                 ? content.links!.forward != null
    //                 : content.links!.back != null) &&
    //             content.toJson().toString().toLowerCase().contains(searchText))
    //         .map(
    //       (content) {
    //         return ValueViewModel(
    //           name: content.name ?? '',
    //           value: content,
    //           isSelected: operationSpec!.values.contains(content.id),
    //           count: field!.path.contains('back')
    //               ? content.links!.forward!.length
    //               : content.links!.back!.length,
    //         );
    //       },
    //     ).toList();
    //     break;
    //   case FieldType.date:
    //     break;
    //   case FieldType.number:
    //     break;
    //   case FieldType.string:
    //     break;
    //   case FieldType.tag:
    //     results = contentManager.allContent.values
    //         .where((content) => content.tag != null)
    //         .map((tag) => ValueViewModel(
    //             name: tag.name ?? '',
    //             value: tag,
    //             isSelected: operationSpec!.values.contains(tag.id),
    //             count: tag.tag!.instances.length))
    //         .toList();
    //     break;
    // }
    results
        .sort((a, b) => (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0));
    return results;
  }

  addValue(ValueViewModel valueModel) {
    // switch (field!.type) {
    //   case FieldType.contentType:
    //     final ContentType type = valueModel.value;
    //     operationSpec!.values.add(type.index);
    //     break;
    //   case FieldType.link:
    //     final Content content = valueModel.value;
    //     operationSpec!.values.add(content.id);
    //     break;
    //   case FieldType.date:
    //     break;
    //   case FieldType.number:
    //     break;
    //   case FieldType.string:
    //     break;
    //   case FieldType.tag:
    //     final Content tag = valueModel.value;
    //     operationSpec!.values.add(tag.id);
    //     break;
    // }
    notifyListeners();
  }
}

class ValueViewModel {
  String name;
  dynamic value;
  bool isSelected;
  IconData? icon;
  int count;
  ValueViewModel({
    required this.name,
    this.icon,
    this.value,
    this.isSelected = false,
    this.count = 0,
  });
}
