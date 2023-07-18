import 'package:flutter/material.dart' hide NavigationBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/menu/highlight/view.dart';
import 'package:stashmobile/app/menu/navigation/view.dart';
import 'package:stashmobile/app/read_aloud/play_bar/view.dart';
import 'package:stashmobile/app/share/notifications/view.dart';

import 'more/collapsed.dart';
import 'model.dart';

class MenuView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(menuViewProvider);
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          model.state == MenuState.navigationBar ? PlayBar() : Container(),
          _buildMenu(context, model),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context, MenuViewModel model) => {
        MenuState.closed: () => Container(height: 0),
        MenuState.navigationBar: () =>
            NavigationBar(), //_buildAddElementMenu(context, model),//_buildMenu(context, model),
        MenuState.textSelection: () => Container(height: 0),
        MenuState.highlight: () => HighlightMenu(
              key: UniqueKey(),
            ),
        MenuState.menu: () => CollapsedMenu(),
        MenuState.notifications: () => NotificationsView(),
      }[model.state]!();

  Widget _buildMenuListItem(
    BuildContext context,
    MenuViewModel model,
    SubItemModel item,
  ) =>
      GestureDetector(
        onTap: () => item.onTap?.call(context),
        onLongPress: () => item.onLongPress?.call(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            //color: Theme.of(context).focusColor,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Icon(item.icon),
                  ),
                  Text(item.name)
                ],
              ),
            ),
          ),
        ),
      );
}
