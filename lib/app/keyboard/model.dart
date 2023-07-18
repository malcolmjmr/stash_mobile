import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';

class KeyboardViewModel extends ChangeNotifier {
  late AppController app;
  BuildContext context;
  KeyboardViewModel(this.context) {
    app = context.read(appProvider);
    loadCharacters();
    getFrequenciesFromContent();
    setIsLoading(false);
  }

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String vowels = 'aeiouy';
  String alphabet = ' abcdefghijklmnopqrstvwuxyz';
  String numerals = '1234567890';
  Map<String, Map<String, int>> characterMap = {};

  loadCharacters() {
    for (int i = 0; i < alphabet.length; i++) characterMap[alphabet[i]] = {};

    for (int i = 0; i < numerals.length; i++) characterMap[numerals[i]] = {};
    sortedCharacters = characterMap.keys.toList();
  }

  Map<String, Map<String, int>> wordMap = {};
  getFrequenciesFromContent() {
    print('getting character frequencies');
    print('start');
    final start = DateTime.now();
    List<Content> highlights = app.content.allContent.values
        .where((c) => c.type == ContentType.annotation)
        .toList();

    highlights.sort(
      (a, b) => (b.ratings?.value ?? 0).compareTo(a.ratings?.value ?? 0),
    );

    highlights.forEach((content) {
      if (content.title.isEmpty) return;
      final normTitle = content.title.toLowerCase();
      final splitTitle = normTitle.replaceAll('\n', '').split('');

      for (int charIndex = 0; charIndex < splitTitle.length - 1; charIndex++) {
        final currentChar = splitTitle[charIndex];
        final nextChar = splitTitle[charIndex + 1];
        Map<String, int>? charFrequencies = characterMap[currentChar];
        if (charFrequencies == null || !characterMap.keys.contains(nextChar))
          continue;
        int? count = charFrequencies[nextChar];
        if (count == null) count = 0;
        count++;
        characterMap[currentChar]![nextChar] = count;
      }
    });
    print('done');
    final end = DateTime.now();
    print(
      Duration(
        milliseconds: end.millisecondsSinceEpoch - start.millisecondsSinceEpoch,
      ).inSeconds,
    );
    //print(characterMap);
  }

  List<String> get sortedVowels =>
      sortedCharacters.where((c) => vowels.contains(c)).toList();

  List<String> get sortedNumbers =>
      sortedCharacters.where((c) => numerals.contains(c)).toList();

  List<String> get sortedConsonants => sortedCharacters
      .where((c) => !vowels.contains(c) && alphabet.contains(c))
      .toList();

  List<String> sortedCharacters = [];
  loadSortedCharacters(String char) {
    if (char.isEmpty) {
      char = ' ';
    }

    //print(characterMap);

    if (!characterMap.containsKey(char)) return;
    setIsLoading(true);
    List<MapEntry<String, int>> charFrequencies =
        characterMap[char]!.entries.toList();
    charFrequencies.sort((a, b) => b.value.compareTo(a.value));
    //print(charFrequencies);
    sortedCharacters = charFrequencies.map((e) => e.key).toList();
    setIsLoading(false);
  }

  String text = '';
  onInput(String char) {
    text += char;
    loadSortedCharacters(char);
  }

  onBackspace() {
    String char;
    if (text.length <= 1) {
      text = '';
      char = text;
    } else {
      text = text.substring(0, text.length - 1);
      char = text[text.length - 1];
    }

    loadSortedCharacters(char);
  }

  onClear() {
    text = '';
    loadSortedCharacters(text);
  }
}
