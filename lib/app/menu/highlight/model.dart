import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';

enum HighlightMenuView {
  main,
  note,
  tags,
  rating,
  reminder,
  delete,
}

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late Content highlight;
  ViewModel(this.context) {
    app = context.read(appProvider);
    highlight = app.treeView.selected.first.content;
  }

  HighlightMenuView view = HighlightMenuView.main;
  setView(HighlightMenuView value) {
    view = value;
    notifyListeners();
  }

  goBack() => app.menuView.openNavBar();

  openNote() => setView(HighlightMenuView.note);

  openTags() {
    app.tagsView.refresh();
    setView(HighlightMenuView.tags);
  }

  openRating() => setView(HighlightMenuView.rating);

  openReminder() => setView(HighlightMenuView.reminder);

  share() async => await app.content.shareContent(highlight);

  attemptDelete() => setView(HighlightMenuView.delete);

  confirmDelete() async => await app.content.deleteContent(highlight);
}
