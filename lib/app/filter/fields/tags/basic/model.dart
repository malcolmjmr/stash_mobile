import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/app/tags/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late FilterManager filters;
  late ContentManager contentManager;
  ViewModel(this.context) {
    filters = context.read(filterProvider);
    contentManager = context.read(contentProvider);
    tags = contentManager.allContent.values
        .where((content) => content.type == ContentType.tag)
        .toList();
    loadFieldSpec();
    refreshTags();
  }

  FieldSpec fieldSpec = FieldSpec(
    fieldPath: 'tags.values',
    isInclusive: true,
    operations: [Operation(operator: FilterOperator.contains, values: [])],
  );

  loadFieldSpec() {
    int index = filters.getFieldSpecIndex(fieldSpec);
    if (index >= 0) {
      fieldSpec = filters.contentFilter.filter!.fieldSpecs![index];
      if (fieldSpec.operations == null || fieldSpec.operations!.isEmpty)
        fieldSpec.operations = [
          Operation(operator: FilterOperator.contains, values: [])
        ];
    }
  }

  TextEditingController textController = TextEditingController();

  onSearchUpdated(String text) => refreshTags();
  onSearchSubmit(String text) => refreshTags();

  List<Content> tags = [];

  bool tagsAreLoading = false;
  setTagsAreLoading(bool value) {
    tagsAreLoading = value;
    notifyListeners();
  }

  List<TagViewModel> relevantTags = [];
  refreshTags() {
    setTagsAreLoading(true);
    relevantTags = tags
        .where((tag) =>
            tag.name != null &&
            tag.name!.toLowerCase().contains(textController.text.toLowerCase()))
        .map((tag) => TagViewModel(
            tag: tag,
            isSelected:
                fieldSpec.operations?.first.values.contains(tag.id) ?? false))
        .toList();
    relevantTags
        .sort((a, b) => (a.isSelected ? 0 : 1).compareTo(b.isSelected ? 0 : 1));
    setTagsAreLoading(false);
  }

  toggleSelection(TagViewModel tagViewModel) {
    if (tagViewModel.isSelected) {
      fieldSpec.operations!.first.values.remove(tagViewModel.tag.id);
    } else {
      fieldSpec.operations!.first.values.add(tagViewModel.tag.id);
    }
    filters.setFieldSpec(fieldSpec);
    refreshTags();
  }

  goBack() {
    if (fieldSpec.operations!.first.values.isEmpty) {
      filters.removeFieldSpec(fieldSpec);
    }

    Navigator.of(context).pop();
  }
}
