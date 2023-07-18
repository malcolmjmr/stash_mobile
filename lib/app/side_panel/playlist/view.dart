import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/read_aloud/model.dart';
import 'package:stashmobile/app/read_aloud/playback_buttons.dart';

class PlaylistView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(readAloudProvider);
    print(model.queuePosition);
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNowPlaying(context, model),
          _buildQueue(context, model),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context, ReadAloudController model) =>
      model.queuePosition >= 0
          ? Container(
              color: Theme.of(context).canvasColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Now playing',
                        style: GoogleFonts.lato(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ListItem(
                          model.content!,
                          onDoubleTap: () =>
                              model.openToCurrentSection(context),
                          fontSize: 20,
                          iconSize: 30,
                          maxLines: 2,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    PlayBackButtons(),
                  ],
                ),
              ),
            )
          : Container();

  Widget _buildQueue(BuildContext context, ReadAloudController model) =>
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Up next',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: model.queue
                    .sublist(model.queuePosition + 1)
                    .map((content) => ListItem(
                          content,
                          iconSize: 16,
                          onTap: () => model.readContent(context, content),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
}
