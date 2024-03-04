import 'package:flutter/material.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({
    Key? key, 
    required this.workspace,
    required this.onColorSelected,
  }) : super(key: key);
  final Workspace workspace;

  final Function(String color) onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          //color: HexColor.fromHex('444444'),
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colorMap.entries.map((e) {
            final isSelectedColor = workspace.color == e.key || (workspace.color == null && e.key == 'grey');
            final circleSize = isSelectedColor ? 35.0 : 30.0;
            return GestureDetector(
              onTap: () {
                onColorSelected(e.key);
              },
              child: Container(
                height: circleSize,
                width: circleSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  // border: e.key == 'grey'
                  //   ? Border.all(
                  //       color: Colors.white, 
                  //       width: 2.0
                  //     ) : null,
                  color: HexColor.fromHex(e.value)
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}