import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/models/content/content.dart';

import '../content_icon/view.dart';

class ListItem extends StatelessWidget {
  final Content content;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final EdgeInsetsGeometry padding;
  final int maxLines;
  final double? fontSize;
  final double? iconSize;
  final CrossAxisAlignment crossAxisAlignment;
  ListItem(
    this.content, {
    this.onTap,
    this.onDoubleTap,
    this.padding = const EdgeInsets.all(5.0),
    this.maxLines = 3,
    this.fontSize,
    this.iconSize = 20,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        onTap: onTap,
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  ContentIcon(
                    content,
                    size: iconSize,
                  ),
                  Expanded(
                    child: Text(
                      content.title,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(fontSize: fontSize),
                    ),
                  ),
                ],
              ),
              _buildListItemBody(context),
              _buildListItemAttributes(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItemBody(BuildContext context) => Container();

  Widget _buildListItemAttributes(BuildContext context) => Container();
}
