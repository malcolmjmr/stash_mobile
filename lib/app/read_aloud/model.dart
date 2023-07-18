import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/users.dart';
import 'package:stashmobile/app/web/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/type_fields/web_article.dart';

class ReadAloudController extends ChangeNotifier {
  UserManager userManager;
  ContentManager contentManager;
  WebManager webManager;
  final ProviderReference ref;
  late AppViewModel appView;
  ReadAloudController({
    required this.userManager,
    required this.contentManager,
    required this.webManager,
    required this.ref,
  }) {
    appView = ref.read(appViewProvider);
    loadQueue();
    initiateTextToSpeech();
  }

  FlutterTts tts = FlutterTts();
  initiateTextToSpeech() async {
    await tts.setLanguage('en');
    await tts.setSpeechRate(speechRate);
    await tts.setSharedInstance(true);
    await tts.awaitSpeakCompletion(true);
    await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);

    tts.setCompletionHandler(playNextSection);
  }

  double speechRate = 0.7;
  updateSpeechRate({double increment = 0.1}) async {
    speechRate = speechRate + increment;
    if (speechRate > 1.0) speechRate = 0.5;
    await tts.setSpeechRate(speechRate);
    resetPlay();
    notifyListeners();
  }

  int queuePosition = -1;
  List<Content> queue = [];
  loadQueue() {
    queuePosition = userManager.me.playListPosition ?? -1;
    queue = contentManager.getContentByIds(userManager.me.playList);
  }

  saveQueue() {
    userManager.me.playListPosition = queuePosition;
    userManager.me.playList = queue.map((content) => content.id).toList();
    userManager.saveCurrentUser();
    notifyListeners();
  }

  addToQueue(Content content) {
    queue.add(content);
    saveQueue();
  }

  readContent(BuildContext context, Content content, {Function()? callback}) {
    if (isPlaying) tts.stop();
    final contentIndex = queue.indexWhere((c) => c.id == content.id);
    if (contentIndex >= 0) {
      queue[contentIndex] = content;
      queuePosition = contentIndex;
    } else {
      queue.insert(0, content);
      queuePosition = 0;
    }
    saveQueue();
    if (showPlayBar == false) setShowPlayBar(true);
    if (callback != null) openModal(context, callback: callback);
    play();
  }

  addUpNext(Content content) {
    final contentIndex = queue.indexWhere((c) => c.id == content.id);
    if (contentIndex >= 0) {
      queue.removeAt(contentIndex);
    }
    queue.insert(queuePosition + 1, content);
  }

  bool get canGoToPrevious => queuePosition > 0;
  goToPreviousContent() {
    if (!canGoToPrevious) return;
    queuePosition = queuePosition - 1;
    resetPlay();
    notifyListeners();
  }

  goToPreviousSection() async {
    final article =
        queue.isNotEmpty ? queue[queuePosition].webArticle?.article : null;
    if (article == null || article.place <= 0) return;
    print('going to previous section');
    article.place -= 1;
    await resetPlay();
    notifyListeners();
  }

  bool isPlaying = false;
  toggleIsPlaying() {
    if (isPlaying) {
      stop();
    } else {
      if (showPlayBar == false) setShowPlayBar(true);
      play();
    }
  }

  stop() {
    tts.stop();
    isPlaying = false;
    notifyListeners();
  }

  play() async {
    isPlaying = true;
    notifyListeners();
    await playNextSection();
  }

  playNextSection() async {
    Content? content;
    Article? article;

    bool stillPlaying() {
      content = queue.isNotEmpty ? queue[queuePosition] : null;
      if (content == null) return false;
      article = content!.webArticle?.article;
      bool needToFetchArticle =
          content!.type == ContentType.webSite && article == null;

      if (needToFetchArticle) getContentArticle();

      bool moreSections = article != null &&
          article!.currentSection != null &&
          article!.currentSection!.index < article!.sections.length - 1;
      bool moreContent = queue.length > queuePosition + 1;
      print('checking if still playing');
      print('more sections: $moreSections');
      print('more content: $moreContent');
      return isPlaying && (moreSections || moreContent);
    }

    if (!stillPlaying()) {
      isPlaying = false;
      return;
    }

    String textToRead = '';
    if (article != null) {
      textToRead = content!.webArticle!.article!.currentSection!.text;
    } else {
      textToRead = content!.title;
    }
    await tts.speak(textToRead);
    if (article != null) {
      article!.place += 1;
      final shouldNavigateToSection = appView.view == ContentViewType.website &&
          appView.root.id == content?.id;
      if (shouldNavigateToSection) webManager.navigateToSection(article!.place);
    } else {
      queuePosition += 1;
    }
    //notifyListeners();
  }

  getContentArticle() {}

  goToNextSection() async {
    final article =
        queue.isNotEmpty ? queue[queuePosition].webArticle?.article : null;
    if (article == null || article.place >= article.sections.length) return;
    article.place += 1;
    await resetPlay();
    notifyListeners();
  }

  bool get canGoToNext => queuePosition < queue.length - 1;
  Content? get nextInQueue => queue[queuePosition + 1];
  goToNextContent() {
    if (!canGoToNext) return;
    queuePosition = queuePosition + 1;
    resetPlay();
    notifyListeners();
  }

  resetPlay() async {
    if (isPlaying) {
      await tts.stop();
      play();
    }
  }

  bool get listeningToArticle =>
      content!.webArticle?.article?.currentSection != null;
  Content? get content => queue.isNotEmpty ? queue[queuePosition] : null;

  viewCurrentSectionInWebView(BuildContext context) async {}

  bool showPlayBar = false;
  setShowPlayBar(bool value) {
    showPlayBar = value;
    notifyListeners();
  }

  closePlayBar() {
    queue.removeAt(queuePosition);
    if (!canGoToNext) queuePosition -= 1;
    setShowPlayBar(false);
  }

  openModal(BuildContext context, {Function()? callback}) {
    // showMaterialModalBottomSheet(
    //   context: context,
    //   builder: (context) => ReadAloudView(),
    //   expand: true,
    // ).then((value) => callback?.call());
  }

  openToCurrentSection(
    BuildContext context,
  ) async {
    final app = context.read(appProvider);
    app.web.goToSection = true;
    await app.viewModel.openMainView(context, content);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }
}
