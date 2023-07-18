import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/read_aloud/model.dart';

class PlayBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(readAloudProvider);
    return model.showPlayBar
        ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).focusColor, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildTitle(context, model)),
                GestureDetector(
                  onTap: model.toggleIsPlaying,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      model.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: model.closePlayBar,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.clear,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget _buildTitle(BuildContext context, ReadAloudController model) =>
      GestureDetector(
        onTap: () => model.openToCurrentSection(context),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 30,
                  child: model.content?.iconUrl != null
                      ? Image.network(model.content!.iconUrl!)
                      : Container(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 20,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Text(
                      model.content!.title,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
