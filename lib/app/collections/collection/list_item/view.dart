import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/collections/collection/icon.dart';
import 'package:stashmobile/models/collection/model.dart';

class CollectionListItem extends StatelessWidget {
  final Collection collection;
  final bool isCurrentCollection;
  final Function()? onTap;
  final Function()? onLongPress;
  CollectionListItem(
    this.collection, {
    this.isCurrentCollection = false,
    this.onTap,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        height: 40,
        child: Row(
          children: [
            CollectionIcon(
              collection,
              padding: EdgeInsets.all(5),
            ),
            Expanded(
              child: Text(
                collection.name,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: isCurrentCollection
                      ? null
                      : Theme.of(context).disabledColor,
                  fontWeight: isCurrentCollection ? null : FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            collection.hasUpdates
                ? Container(
                    height: 10,
                    width: 10,
                    color: Theme.of(context).highlightColor,
                  )
                : Container(),
            //CollectionUpdates()
          ],
        ),
      ),
    );
  }
}
