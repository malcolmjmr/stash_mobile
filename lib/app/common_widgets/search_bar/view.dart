import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  final String? hintText;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final Function()? onTap;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final Color? color;
  final bool autofocus;
  final TextAlign textAlign;
  final double? height;

  SearchBar({
    this.hintText,
    this.focusNode,
    this.controller,
    this.onSubmit,
    this.onChanged,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 10, right: 10, top: 10),
    this.fontSize = 16,
    this.color,
    this.onTap,
    this.autofocus = false,
    this.textAlign = TextAlign.left,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
            color: color ?? Theme.of(context).primaryColor,
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                leading != null
                    ? leading!
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(),
                      ),
                Expanded(
                  child: TextField(
                    autofocus: autofocus,
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: textAlign,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: GoogleFonts.lato(
                        fontSize: fontSize,
                        letterSpacing: 2,
                      ),
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmit,
                    onTap: onTap,
                  ),
                ),
                trailing != null ? trailing! : Container(),
              ],
            )),
      ),
    );
  }
}
