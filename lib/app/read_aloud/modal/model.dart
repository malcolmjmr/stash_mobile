import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context, {this.showListenOptions = false}) {
    app = context.read(appProvider);
    final contentIndex =
        app.readAloud.queue.indexWhere((i) => i.id == app.viewModel.root.id);
    bool contentIsInQueue = contentIndex >= 0;
    if (contentIsInQueue) app.readAloud.queuePosition = contentIndex;
    showListenOptions = !contentIsInQueue;
  }

  bool showListenOptions;

  goBack() {
    app.menuView.setSubMenuView(null);
    app.menuView.openNavBar();
  }

  bool isListeningNow = false;
  listenNow() {
    showListenOptions = false;
    Navigator.of(context).pop();
    app.readAloud.readContent(context, app.viewModel.root);
    notifyListeners();
  }

  listenNext() {
    showListenOptions = false;
    app.readAloud.addUpNext(app.viewModel.root);
    Navigator.of(context).pop();
    //notifyListeners();
  }

  addToQueue() {
    app.readAloud.addToQueue(app.viewModel.root);
    Navigator.of(context).pop();
  }

  bool playBarIsOpen = false;
  onPlayButtonTap() {
    togglePlay();
    playBarIsOpen = true;
    notifyListeners();
  }

  bool audioSettingsIsOpen = false;
  openAudioSettings() {}
  goToPreviousContent() {}
  goToPreviousSection() {
    app.readAloud.goToPreviousSection();
  }

  bool get isPlaying => app.readAloud.isPlaying;
  togglePlay() {
    app.readAloud.toggleIsPlaying();
    notifyListeners();
  }

  goToNextSection() {
    app.readAloud.goToNextSection();
  }

  goToNextContent() {
    //app.readAloud.goToNextContent();
  }

  bool playlistIsOpen = false;
  openPlaylist() {}
}

enum ListenViews {
  listenOptions,
  playMenu,
  settings,
}
