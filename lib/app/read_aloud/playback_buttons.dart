import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';

class PlayBackButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(readAloudProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: model.goToPreviousContent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.skip_previous,
                size: 30,
                color: model.canGoToPrevious
                    ? null
                    : Theme.of(context).disabledColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: model.goToPreviousSection,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.fast_rewind,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: model.toggleIsPlaying,
            child: Icon(
              model.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              size: 60,
            ),
          ),
          GestureDetector(
            onTap: model.goToNextSection,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.fast_forward,
                size: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: model.goToNextContent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.skip_next,
                color:
                    model.canGoToNext ? null : Theme.of(context).disabledColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
