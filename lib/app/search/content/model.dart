import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  String searchText;
  ViewModel(this.context, this.searchText) {
    app = context.read(appProvider);
    loadResults();
  }

  List<Content> results = [];
  loadResults({FilterFields? filter}) async {
    if (filter == null) {
      filter = FilterFields(fieldSpecs: []);
    }

    setIsLoading(true);

    if (app.content.allContent.isEmpty) {
      await app.content.load();
    }

    results = app.content.getContentWithQuery(
      searchText: searchText,
      query: filter,
    );

    setIsLoading(false);
  }

  bool isLoading = false;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  onTapContent(Content content) {
    app.viewModel.open(context, content);
    Navigator.of(context).pop();
  }

  onDoubleTapContent(Content content) {
    app.viewModel.openMainView(context, content);
    Navigator.of(context).pop();
  }
}
