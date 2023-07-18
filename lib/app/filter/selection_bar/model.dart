import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context, {this.filterContext = FilterContext.tree}) {
    app = context.read(appProvider);
    loadFilters();
  }

  FilterContext filterContext;
  List<Content> filters = [];
  loadFilters() {
    List<String> filterIds = [];
    switch (filterContext) {
      case FilterContext.tree:
        final defaultFilters = [
          'Newest',
          'Favorites',
          'Recent',
          'Best',
          'Highlights',
          'Unvisited',
          'Tasks',
          'Reminders'
        ];
        filterIds = app.treeView.rootNode.content.filters ?? [];
        filterIds.addAll(defaultFilters.where((id) => !filterIds.contains(id)));
        currentFilterId = filterIds.first;
        break;
      case FilterContext.search:
        final defaultFilters = ['Recent', 'Favorites', 'Topics', 'Daily Pages'];
        List<String> filterIds =
            app.filters.recentFilters.map((c) => c.id).toList();
        filterIds.addAll(defaultFilters.where((id) => !filterIds.contains(id)));
        break;
      case FilterContext.readingLists:
        break;
    }
    filters.addAll(
      filterIds.map(
        (id) => app.filters.allFilters[id]!,
      ),
    );
  }

  ScrollController scrollController = ScrollController();

  String currentFilterId = '';
  setFilter(Content value, Function(Content)? onFilterSelected) {
    scrollController.animateTo(0,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    onFilterSelected?.call(value);
  }
}

enum FilterContext { tree, search, readingLists }
