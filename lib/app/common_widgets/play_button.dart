import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/web/tab_model.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({Key? key, this.tabModel}) : super(key: key);

  final TabViewModel? tabModel;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
  final readAloud = watch(readAloudProvider);
  return readAloud.isPlaying
    ? GestureDetector(
        onTap: () => context.read(readAloudProvider).pause(),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Icon(Symbols.pause_rounded, size: 30,),
        ),
      )
    : GestureDetector(
      onTap: () => context.read(readAloudProvider).play(model: tabModel),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Icon(Symbols.play_arrow_rounded, size: 30,),
      ),
    );
  }
}