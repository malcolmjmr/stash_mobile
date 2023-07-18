import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SearchViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  SearchViewModel(this.context) {
    app = context.read(appProvider);
    loadTags();
  }

  String contentSearchText = '';
  String tagSearchText = '';
  TextEditingController textController = TextEditingController();
  updateSearch(String text) {
    if (showTags) {
      tagSearchText = text;
    } else {
      contentSearchText = text;
    }
    notifyListeners();
  }

  onSearchSubmit(String text) => updateSearch(text);

  bool showTags = true;
  setShowTags(bool value) {
    showTags = value;
    textController.text = showTags ? tagSearchText : contentSearchText;
    textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length));
    notifyListeners();
  }

  List<Content> selectedTags = [];
  List<Content> availableTags = [];
  bool tagsAreLoading = true;
  loadTags() {
    availableTags = app.tagsView.allTags;
    availableTags.sort(
        (a, b) => b.tag!.instances.length.compareTo(a.tag!.instances.length));
    tagsAreLoading = false;
    notifyListeners();
  }

  selectTag(Content tag) {
    availableTags.remove(tag);
    selectedTags.add(tag);
    notifyListeners();
  }

  unSelectTag(Content tag) {
    selectedTags.remove(tag);
    availableTags.add(tag);
    notifyListeners();
  }

  updateTagResults() {}

  updateContentResults() {}
}
