import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';

import 'model.dart';

class ReadAloudView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(readAloudProvider);
    return SafeArea(
      child: Material(
        child: Container(
          child: Column(
            children: [
              _buildHeader(context, model),
              _buildPlayBar(context, model),
              _buildPlaylist(model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReadAloudController model) =>
      GestureDetector(
        onTap: () {
          context.read(appViewProvider).open(context, model.content!);
          Navigator.of(context).pop();
        },
        onDoubleTap: () {
          context.read(appViewProvider).openMainView(context, model.content!);
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                model.content!.title,
                style: GoogleFonts.lato(
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
                  color: model.canGoToNext
                      ? null
                      : Theme.of(context).disabledColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildPlaylist(ReadAloudController model) => Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.list,
                size: 30,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: model.goToNextContent,
                child: Text(
                  model.canGoToNext
                      ? model.nextInQueue!.title
                      : 'No more articles in queue',
                  style: GoogleFonts.lato(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 30,
            ),
          ],
        ),
      );

  Widget _buildSectionPage(ReadAloudController model, String? text) => Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              text ?? '',
              maxLines: null,
              style: GoogleFonts.lato(fontSize: 16),
            ),
          ],
        ),
      );
}
