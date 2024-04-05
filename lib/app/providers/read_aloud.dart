import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/models/article.dart';

final readAloudProvider = ChangeNotifierProvider((ref) => ReadAloudController(
      ref: ref,
    ));


class ReadAloudController extends ChangeNotifier {

  final ProviderReference ref;
  TabViewModel? tabModel;
  ReadAloudController({
    required this.ref,
  }) {
    initiateTextToSpeech();
  }

  FlutterTts tts = FlutterTts();
  initiateTextToSpeech() async {
    await tts.setLanguage('en');
    await tts.setSpeechRate(speechRate);
    await tts.setSharedInstance(true);
    await tts.awaitSpeakCompletion(true);
    await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ], IosTextToSpeechAudioMode.spokenAudio);

    tts.setCompletionHandler(playNextSection);
  }

  double speechRate = 0.6;
  updateSpeechRate({double increment = 0.1}) async {
    speechRate = speechRate + increment;
    if (speechRate > 1.0) speechRate = 0.5;
    await tts.setSpeechRate(speechRate);
    resetPlay();
    notifyListeners();
  }

  int queuePosition = -1;


  bool get canGoToPrevious => queuePosition > 0;
  goToPreviousResource() {
    if (!canGoToPrevious) return;
    tabModel!.goBack();
    resetPlay();
    notifyListeners();
  }

  goToPreviousSection() async {
    final article = tabModel!.resource.article;
    if (article == null || article.place <= 0) return;
    article.place -= 1;
    await resetPlay();
    notifyListeners();
  }

  bool isPlaying = false;
  toggleIsPlaying() {
    if (isPlaying) {
      stop();
    } else {
      play();
    }
  }

  bool isWaitingForNextArticle = false;

  stop() {
    tts.stop();
    isPlaying = false;
    notifyListeners();
  }

  pause() {
    tts.pause();
    isPlaying = false;
    notifyListeners();
  }

  play({TabViewModel? model}) async {
    tabModel = model;
    if (!tabModel!.workspaceModel.isPlayingJourney){
      tabModel!.workspaceModel.setIsPlayingJourney(true);
      tabModel!.setShowJourney(false);
    }
    isPlaying = true;
    notifyListeners();
    await playNextSection();
  }

  String textToRead = '';

  playNextSection() async {

    Article? article = tabModel?.resource.article;
    print(article?.currentSection?.text);

    bool stillPlaying() {
      
      if (article != null) {

      }
      bool moreSections = article != null &&
          article.currentSection != null &&
          article.place < article.sections.length - 1;
      bool moreContent = tabModel!.canGoForward;

      return isPlaying && (moreSections || moreContent);
    }

    if (!stillPlaying()) {
      isPlaying = false;
      return;
    }

    textToRead = '';
    if (article != null) {
      textToRead = article.currentSection!.text;
    } else {
      textToRead = tabModel!.resource.title!;
      isPlaying = false;
    }
    notifyListeners();
    await tts.speak(textToRead);
    if (article != null) {
      if (article.place < article.sections.length -1) {
        article.place += 1;
        final shouldNavigateToSection = tabModel!.workspaceModel.showWebView;
        if (shouldNavigateToSection) tabModel!.navigateToSection(article.place);
        // Timer(Duration(milliseconds: 500), () {
        //   playNextSection();
        // });
        
      } else {

        Timer(Duration(seconds: 3), () {
          textToRead = 'End of content. Navigating to next article.';
          notifyListeners();
          tts.speak(textToRead);
          isPlaying = false;
          // Timer(Duration(seconds: 2), () {
          //   tabModel!.goForward();
          // });
        });
      }
    }


    
  }

  getContentArticle() {}

  goToNextSection() async {
    final article = tabModel!.resource.article;
    if (article == null || article.place >= article.sections.length) return;
    article.place += 1;
    await resetPlay();
    notifyListeners();
  }
  
  goToNextResource() {
    if (!tabModel!.canGoForward) return;
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

  openToCurrentSection(
    BuildContext context,
  ) async {
   
  }


}
