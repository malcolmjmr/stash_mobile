import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class ContentTitle extends StatelessWidget {
  final Content content;
  ContentTitle(
    this.content, {
    this.maxLines = 3,
    this.fontSize = 14,
    this.fontWeight,
    this.color,
    this.height = 45,
  });
  final double height;
  final int? maxLines;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.lato(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
    return ChangeNotifierProvider(
      create: (_) => ContentTitleModel(content, context),
      child: Consumer<ContentTitleModel>(builder: (context, model, _) {
        return content.editName
            ? _buildTextField(model, textStyle: textStyle)
            : _buildText(model, textStyle: textStyle);
      }),
    );
  }

  Widget _buildTextField(ContentTitleModel model,
          {required TextStyle textStyle}) =>
      TextField(
        focusNode: model.focusNode,
        controller: model.textController,
        style: textStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle:
              textStyle.copyWith(color: Theme.of(model.context).disabledColor),
          hintText: 'Enter Name',
          isCollapsed: true,
        ),
        keyboardType: TextInputType.text,
        maxLines: null,
        autofocus: true,
        onChanged: (name) => null,
        onSubmitted: (name) => null,
      );

  Widget _buildText(ContentTitleModel model, {required TextStyle textStyle}) {
    return GestureDetector(
      //onLongPress: () => model.setEditName(true),
      child: Text(
        content.title,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        style: textStyle,
      ),
    );
  }
}
