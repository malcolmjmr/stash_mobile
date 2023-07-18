import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/menu/text_selection/model.dart';

class TextSelectionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = TextSelectionMenuModel(context);
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200),
        child: _buildMenuItems(model));
  }

  Widget _buildMenuItems(TextSelectionMenuModel model) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListItem(
                text: 'Search the web',
                icon: Icons.travel_explore,
                onTap: model.onSearch),
            _buildListItem(
                text: 'Add highlight',
                icon: Icons.short_text,
                onTap: model.onAddHighlight),
            model.showAddTag
                ? _buildListItem(
                    text: 'Add tag',
                    icon: Icons.local_offer,
                    onTap: model.onAddTag)
                : SizedBox.shrink(),
            model.showAddTag
                ? _buildListItem(
                    text: 'Add to properties',
                    icon: Icons.list,
                    onTap: model.onAddFieldValue)
                : SizedBox.shrink(),
          ],
        ),
      );

  Widget _buildListItem(
          {required String text, required IconData icon, Function()? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Opacity(
                  opacity: .7,
                  child: Icon(
                    icon,
                    size: 20,
                  ),
                ),
              ),
              Text(
                text,
                style: GoogleFonts.lato(fontSize: 14),
              ),
            ],
          ),
        ),
      );
}
