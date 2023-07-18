import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:stashmobile/app/menu/more/expanded.dart';
import 'package:stashmobile/models/content/content.dart';

import 'content_icon/view.dart';

class ContentHeader extends StatelessWidget {
  final Content content;
  ContentHeader(this.content);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 45,
        maxHeight: 80,
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0, left: 8.0),
                child: ContentIcon(
                  content,
                  size: 30,
                ),
              ),
              Expanded(
                child: Text(
                  content.title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: content.title.length < 20 ? 18 : 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => MBS.showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => ExpandedMenu(),
                  expand: false,
                  //expand: true,
                ),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
