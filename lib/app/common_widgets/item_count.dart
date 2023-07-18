import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCount extends StatelessWidget {
  final int count;
  final double fontSize;
  final EdgeInsets padding;
  ItemCount(
    this.count, {
    this.fontSize = 10,
    this.padding = const EdgeInsets.all(2.0),
  });
  @override
  Widget build(BuildContext context) {
    return count > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Theme.of(context).highlightColor,
                child: Padding(
                  padding: padding,
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.lato(fontSize: fontSize),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
