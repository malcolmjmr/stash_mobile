import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final Function()? onTap;
  final Function()? onLongPress;
  final Function()? onDoubleTap;
  final Color? selectionColor;
  final Color? fontColor;
  final Color? backgroundColor;
  const TagChip({Key? key, 
    this.isSelected = false, 
    required this.tag,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.selectionColor,
    this.fontColor,
    this.backgroundColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
            ? selectionColor ?? Colors.amber.withOpacity(0.9)
            : backgroundColor ?? HexColor.fromHex('333333'),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
          child: Text(tag.name,
            style: TextStyle(
              fontSize: 16,
              color: isSelected 
                ? Colors.black 
                : fontColor != null 
                  ? fontColor 
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}