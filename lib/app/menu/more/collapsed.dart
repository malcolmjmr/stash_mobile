import 'package:flutter/material.dart';
import 'package:stashmobile/app/article/view.dart';
import 'package:stashmobile/app/fields/view.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/save_for_later/view.dart';
import 'package:stashmobile/app/scent/view.dart';
import 'package:stashmobile/app/reminder/view.dart';
import 'package:stashmobile/app/tags/view.dart';

import 'model.dart';

class CollapsedMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ViewModel(context);
    return model.app.menuView.subMenuView == null
        ? _buildMainMenu(model)
        : _buildSubMenu(model);
  }

  Widget _buildMainMenu(ViewModel model) {
    return Center(
      child: Container(
        height: 50,
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: 50,
              leadingWidth: 0,
              floating: true,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              title: GestureDetector(
                onTap: model.expand,
                child: Icon(Icons.expand),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = model.items[index];
                return GestureDetector(
                  onTap: () => item.onTap?.call(context),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 15, right: 15),
                    child: item.widget != null
                        ? item.widget
                        : item.icon != null
                            ? Icon(item.icon)
                            : Container(),
                  ),
                );
              }, childCount: model.items.length),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenu(ViewModel model) =>
      {
        SubMenuView.tags: () => TagsView(),
        SubMenuView.fields: () => FieldsView(),
        SubMenuView.rating: () => ScentSelectionView(),
        SubMenuView.saveForLater: () => SaveForLaterModal(),
        SubMenuView.reminder: () => ReminderView(goBack: model.goBack),
        //SubMenuView.play: () => ReadAloudView(),
        SubMenuView.article: () => ArticleView(),
      }[model.app.menuView.subMenuView]
          ?.call() ??
      Container(
        child: Center(
          child:
              GestureDetector(onTap: model.goBack, child: Text('No View Set')),
        ),
      );
}
