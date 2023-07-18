import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:stashmobile/app/filter/view.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';

import 'default_filters.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
    scrollController = ScrollController(initialScrollOffset: scrollOffset);
    loadFilters();
  }

  loadFilters() {
    List<String> filterIds = app.treeView.rootNode.content.filters ?? [];
    filterIds.addAll(defaultFilters.where((id) => !filterIds.contains(id)));
    filters.addAll(
      filterIds.map(
        (id) => app.filters.allFilters[id]!,
      ),
    );
    setFilter(filters.first);
  }

  double scrollOffset = 40;
  late ScrollController scrollController;

  List<Content> filters = [];
  int filterIndex = 0;
  Content get currentFilter => filters[filterIndex];
  bool filterIsSaved = true;
  setFilter(Content value, {isSaved = true}) {
    if (!filterIsSaved) filters.removeAt(0);
    filterIsSaved = isSaved;
    if (filterIsSaved) {
      final tempIndex = filters.indexWhere((filter) => filter.id == value.id);
      if (tempIndex >= 0) filters.removeAt(tempIndex);
    }
    filters.insert(0, value);
    if (scrollController.positions.isNotEmpty)
      scrollController.animateTo(
        scrollOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    app.treeView.setFilter(
      value,
      filterIsSaved: filterIsSaved,
    );
    notifyListeners();
  }

  openFilterSettings(Content? filter) {
    MBS.showMaterialModalBottomSheet(
      context: context,
      builder: (context) => FilterView(
        filter: filter,
      ),
    ).then(
      (value) {
        setFilter(
          app.filters.contentFilter,
          isSaved: app.filters.filterIsSaved,
        );
        app.filters.resetFilter();
      },
    );
  }

  int get filterCount =>
      app.treeView.filterObject?.filter?.fieldSpecs
          ?.where(
              (spec) => spec.operations != null && spec.operations!.isNotEmpty)
          .length ??
      0;
  int get viewCount =>
      app.treeView.filterObject?.filter?.fieldSpecs
          ?.where((spec) => spec.isVisible == true)
          .length ??
      0;
  int get sortCount =>
      app.treeView.filterObject?.filter?.fieldSpecs
          ?.where((spec) => spec.sortAscending != null)
          .length ??
      0;
}
