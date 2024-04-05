import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';

class PlayerView extends ConsumerWidget {
  const PlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(readAloudProvider);
    return SafeArea(
      child: Material(
        child: Container(
          child: Column(
            children: [
              _buildHeader(context, model),
              _buildCurrentSection(model),
              _buildPlayBar(context, model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReadAloudController model) =>
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'Read Aloud',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: Theme.of(context).focusColor,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildPlayBar(BuildContext context, ReadAloudController model) =>
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: model.goToPreviousResource,
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
              onTap: model.goToNextResource,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.skip_next,
                  color: model.tabModel!.canGoForward
                      ? null
                      : Theme.of(context).disabledColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCurrentSection(ReadAloudController model) => Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              model.textToRead,
              maxLines: null,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
}