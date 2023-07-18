import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/note/view.dart';
import 'package:stashmobile/app/scent/view.dart';
import 'package:stashmobile/app/reminder/view.dart';
import 'package:stashmobile/app/tags/single_row.dart';
import 'package:stashmobile/app/tags/view.dart';

import 'model.dart';

class HighlightMenu extends StatelessWidget {
  const HighlightMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(),
      child: ChangeNotifierProvider(
        create: (context) => ViewModel(context),
        child: Consumer<ViewModel>(builder: (context, model, _) {
          return Container(
            color: Theme.of(model.context).primaryColor,
            child: {
              HighlightMenuView.main: () => _buildCollapsedMenu(model),
              HighlightMenuView.tags: () => TagsView(goBack: model.goBack),
              HighlightMenuView.rating: () => ScentSelectionView(),
              HighlightMenuView.note: () => NoteView(),
              HighlightMenuView.reminder: () =>
                  ReminderView(goBack: model.goBack),
              HighlightMenuView.delete: () => _buildDeleteDialog(model)
            }[model.view]!(),
          );
        }),
      ),
    );
  }

  Widget _buildCollapsedMenu(ViewModel model) => Column(
        children: [
          ScentSelectionView(height: 35),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SingleRowTagView(key: UniqueKey(), height: 35),
          ),
          _buildMenuOptions(model),
        ],
      );

  Widget _buildMenuOptions(ViewModel model) => Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuIcon(
              onTap: model.openNote,
              icon: Icons.edit,
            ),
            _buildMenuIcon(
              onTap: model.openTags,
              icon: Icons.style_outlined,
            ),
            _buildMenuIcon(
              onTap: model.openReminder,
              icon: Icons.alarm,
            ),
            _buildMenuIcon(
              onTap: () => null, //model.share
              icon: Icons.public,
            ),
            _buildMenuIcon(
              onTap: () => null, //model.post,
              icon: Icons.ios_share,
            ),
            _buildMenuIcon(
              onTap: () => null, // model.more
              icon: Icons.more_horiz,
            ),
          ],
        ),
      );

  Widget _buildMenuIcon({Function()? onTap, required IconData icon}) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon),
        ),
      );

  Widget _buildVerticalMenu(ViewModel model) => Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItem(
              onTap: model.openNote,
              icon: Icons.edit,
              title: 'Add note',
            ),
            _buildMenuItem(
              onTap: model.openTags,
              icon: Icons.style_outlined,
              title: 'Add tags',
            ),
            _buildMenuItem(
              onTap: model.openRating,
              icon: Icons.priority_high,
              title: 'Add priority level',
            ),
            _buildMenuItem(
              onTap: model.openReminder,
              icon: Icons.alarm,
              title: 'Add reminder',
            ),
            _buildMenuItem(
              onTap: model.share,
              icon: Icons.public,
              title: 'Share',
            ),
            _buildMenuItem(
              onTap: model.attemptDelete,
              icon: Icons.delete,
              title: 'Delete',
            ),
          ],
        ),
      );

  Widget _buildMenuItem({
    Function()? onTap,
    required IconData icon,
    required String title,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Opacity(
                  child: Icon(icon),
                  opacity: 0.6,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.lato(fontSize: 14),
              )
            ],
          ),
        ),
      );

  Widget _buildDeleteDialog(ViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Are you sure?',
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: model.confirmDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Theme.of(model.context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => model.setView(HighlightMenuView.main),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Theme.of(model.context).highlightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
