import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:stashmobile/app/filter/view.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';


class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  Function(Content) setFilterCallback;
  List<String> defaultFilters;
  ViewModel(this.context,
      {required this.setFilterCallback, this.defaultFilters = const []}) {
    app = context.read(appProvider);
    loadFilters();
  }

  loadFilters() {
    filters.addAll(
      defaultFilters.map(
        (id) => app.filters.allFilters[id]!,
      ),
    );
    //setFilterCallback(currentFilter);
  }

  ScrollController scrollController = ScrollController(initialScrollOffset: 30);

  List<Content> filters = [];
  int filterIndex = 0;
  Content get currentFilter => filters[filterIndex];
  setFilter(Content value) {
    final tempIndex = filters.indexWhere((filter) => filter.id == value.id);
    filters.removeAt(tempIndex);
    filters.insert(0, value);
    scrollController.animateTo(
      30,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    setFilterCallback(value);
    notifyListeners();
  }

  openFilterSettings(Content? filter) {
    MBS.showMaterialModalBottomSheet(
      context: context,
      builder: (context) => FilterView(
        filter: filter,
      ),
    ).then((value) => setFilterCallback(app.filters.contentFilter));
  }
}
