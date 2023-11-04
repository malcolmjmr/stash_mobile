import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';

class SectionListItemContainer extends StatefulWidget {
  const SectionListItemContainer({
    Key? key, 
    required this.isFirstListItem, 
    required this.isLastListItem,
    this.isHighlighted = false,
    this.onTap,
    this.child
  }) : super(key: key);

  final bool isFirstListItem;
  final bool isLastListItem;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  State<SectionListItemContainer> createState() => _SectionListItemContainerState();
}

class _SectionListItemContainerState extends State<SectionListItemContainer> {

  bool isTapped = false;
  bool isDraggable = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        if (isDraggable) return;
        setState(() {
          isTapped = true;
         
        });

         Timer(Duration(seconds: 1), () {
            setState(() {
              isTapped = false;
            });
          });
        widget.onTap?.call();
      },
      onLongPressStart: (details) => setState(() {
        isDraggable = true;
      }),
      onLongPressCancel: () => setState(() {
        isDraggable = false;
      }),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: widget.isFirstListItem ? Radius.circular(10.0) : Radius.circular(0.0),
          topRight: widget.isFirstListItem ? Radius.circular(10.0) : Radius.circular(0.0),
          bottomLeft: widget.isLastListItem ? Radius.circular(10.0) : Radius.circular(0.0),
          bottomRight: widget.isLastListItem ? Radius.circular(10.0) : Radius.circular(0.0), 
        ),
        child: Container(
            decoration: BoxDecoration(
              color: isTapped || widget.isHighlighted ? HexColor.fromHex('333333') : HexColor.fromHex('222222'),
            ),
          child: Container(
            child: widget.child,
            decoration: BoxDecoration(
                border: widget.isLastListItem ? null : Border(
                bottom: BorderSide(
                  color: HexColor.fromHex('333333')
                )
              ),
            ),
          ),
        ),
      ),
    );
  }
}