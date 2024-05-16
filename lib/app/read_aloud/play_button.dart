import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';

class PlayButton extends ConsumerWidget {
  const PlayButton({
    Key? key, 
    this.onTap, 
    this.padding = const EdgeInsets.all(3),
    this.size = 25,
  }) : super(key: key);


  final Function()? onTap;
  final EdgeInsets padding;
  final double size;


  @override
  Widget build(BuildContext context, ScopedReader watch) {
  final readAloud = watch(readAloudProvider);
  return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Icon(readAloud.isPlaying
          ? Symbols.pause
          : Symbols.play_arrow,
          fill: 1,
          size: size
        ),
      ),
    );
  }
}