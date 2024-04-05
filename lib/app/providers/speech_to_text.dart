import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechProvider = Provider<SpeechToText>((ref) => SpeechToText());