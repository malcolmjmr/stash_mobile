import 'package:flutter/material.dart';
import 'package:stashmobile/models/content/content.dart';


class TagView extends StatelessWidget {
  final Content content;
  final Color? color;
  final Function()? onTap;
  final Function()? onLongPress;
  TagView(
    this.content, {
    this.color,
    this.onTap,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text('${content.name!} ${content.tag!.instances.length}'),
        ),
      ),
    );
  }
}
