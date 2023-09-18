import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final Function()? onTap;
  const TagChip({Key? key, 
    this.isSelected = false, 
    required this.tag,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.amberAccent : HexColor.fromHex('333333'),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
          child: Text(tag.name,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}