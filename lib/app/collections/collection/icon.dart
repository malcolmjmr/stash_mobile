import 'package:flutter/material.dart';
import 'package:stashmobile/models/collection/model.dart';

class CollectionIcon extends StatelessWidget {
  final Collection collection;
  final double size;
  final EdgeInsetsGeometry padding;
  final Function()? onTap;
  CollectionIcon(this.collection,
      {this.size = 30, this.padding = const EdgeInsets.all(8.0), this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: size,
            width: size,
            child: collection.iconUrl != null
                ? Image.network(
                    collection.iconUrl!,
                    fit: BoxFit.fitHeight,
                  )
                : Icon(Icons.book, size: size),
          ),
        ),
      ),
    );
  }
}
