import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/main.dart';

class HomeIcon extends StatelessWidget {
  const HomeIcon({Key? key, this.size = 25, this.padding = const EdgeInsets.all(3.0)}) : super(key: key);
  final double size;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read(showHomeProvider).state = true;
      },
      child: Padding(
        padding: padding,
        child: Icon(
          Symbols.home_rounded,
          fill: 1,
          color: Colors.white,
          size: size,
        ),
      ),
    );
  }
}