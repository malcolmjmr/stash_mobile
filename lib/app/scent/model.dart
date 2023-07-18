import 'package:flutter/material.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/ratings.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late Content root;
  ViewModel(this.context, {Content? content}) {
    app = context.read(appProvider);
    if (content != null)
      root = content;
    else
      root = app.treeView.rootNode.content;

    loadRating();
  }

  bool ratingIsDisabled = false;

  int rating = 0;
  loadRating() {
    final selected = app.treeView.selected;
    if (selected.isNotEmpty) {
      final tempRating = selected.first.content.ratings?.value;
      bool allRatingsAreTheSame =
          selected.every((s) => s.content.ratings?.value == tempRating);
      if (allRatingsAreTheSame) {
        rating = tempRating ?? 0;
      } else {
        ratingIsDisabled = true;
        rating = 0;
      }
    } else {
      rating = root.ratings?.value ?? 0;
    }
    notifyListeners();
  }

  back() => Navigator.of(context).pop();

  updateValue(int value) async {
    if (ratingIsDisabled) return;
    rating = value;
    updateContent(Content content) async {
      if (content.ratings == null) content.ratings = ContentRatings();
      content.ratings!.updateRating(value);
      await app.content.saveContent(content);
      bool inWebView = app.viewModel.state.view == ContentViewType.website;

      if (inWebView) {
        bool updatingAnnotation = content.type == ContentType.annotation;
        bool updatingLink = content.type == ContentType.webSite &&
            app.treeView.selected.isNotEmpty;
        if (updatingAnnotation)
          app.web.updateAnnotation(content);
        else if (updatingLink) app.web.updateLink(content);
      }
    }

    final selected = app.treeView.selected;
    if (selected.isNotEmpty) {
      selected
          .forEach((selection) async => await updateContent(selection.content));
    } else {
      updateContent(root);
    }
    //app.menuView.setSubMenuView(null);
    notifyListeners();
  }

  bool get showClearRating => rating > 0;
  clearRating() async {
    updateContent(Content content) async {
      if (content.ratings != null) content.ratings!.updateRating(0);
      await app.content.saveContent(content);
    }

    final selected = app.treeView.selected;
    if (selected.isNotEmpty) {
      selected
          .forEach((selection) async => await updateContent(selection.content));
    } else {
      updateContent(root);
    }
    //app.menuView.setSubMenuView(null);
    notifyListeners();
  }
}
