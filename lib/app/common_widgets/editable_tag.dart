import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/tag.dart';

class EditableTagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final Function()? onTap;
  const EditableTagChip({Key? key, 
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
          color: HexColor.fromHex('444444'),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tag.name,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Icon(isSelected ? Icons.remove : Icons.add, size: 16,),
              )
            ],
          ),
        ),
      ),
    );
  }
}