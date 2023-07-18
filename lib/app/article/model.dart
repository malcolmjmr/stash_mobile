import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';

import 'package:stashmobile/models/content/type_fields/web_article.dart';

class ArticleViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late Article article;

  ArticleViewModel(this.context) {
    app = context.read(appProvider);
    article = app.viewModel.root.webArticle!.article!;
  }

  goBack() => app.menuView.setSubMenuView(null);

  onSectionTap(ArticleSection section) {
    app.web.navigateToSection(section.index);
    notifyListeners();
  }

  onSectionDoubleTap(ArticleSection section) {
    article.place = section.index;
    app.readAloud.readContent(
      context,
      app.viewModel.root,
      callback: () => app.web.navigateToSection(
        article.currentSection!.index,
      ),
    );
  }

  // Play bar
  bool playBarIsOpen = false;
  onPlayButtonTap() {
    togglePlay();
    playBarIsOpen = true;
    notifyListeners();
  }

  bool audioSettingsIsOpen = false;
  openAudioSettings() {}
  goToPreviousSection() {}
  togglePlay() {}
  goToNextSection() {}

  bool playlistIsOpen = false;
  openPlaylist() {}
}
