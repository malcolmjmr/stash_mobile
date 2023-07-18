import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:stashmobile/app/article/view.dart';
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/scent/view.dart';
import 'package:stashmobile/app/read_aloud/modal/view.dart';
import 'package:stashmobile/app/reminder/view.dart';
import 'package:stashmobile/app/share/modal/view.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;

import 'expanded.dart';

class ViewModel {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
    loadItems();
  }

  close() {
    app.treeView.clearSelected();
    app.menuView.openNavBar();
  }

  expand() {
    MBS.showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => ExpandedMenu(),
      //expand: true,
    ).then((value) => app.menuView.openNavBar());
  }

  goBack() => app.menuView.setSubMenuView(null);

  List<SubItemModel> items = [];
  loadItems() {
    List<SubItemModel> allItems = [
      SubItemModel(
        name: 'Back links',
        icon: Icons.north_west,
        count: (context) => app.treeView.backLinkCount,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.linkDirection == LinkDirection.forward &&
            app.treeView.selected.isEmpty,
        onTap: (context) =>
            app.treeView.setLinkDirection(context, LinkDirection.back),
      ),
      SubItemModel(
        name: 'Forward links',
        icon: Icons.south_east,
        count: (context) => app.treeView.forwardLinkCount,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.linkDirection == LinkDirection.back &&
            app.treeView.selected.isEmpty,
        onTap: (context) =>
            app.treeView.setLinkDirection(context, LinkDirection.forward),
      ),
      SubItemModel(
        name: 'Show filters',
        icon: Icons.filter_list,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            !app.treeView.showFilter &&
            app.treeView.selected.isEmpty,
        onTap: (context) {
          app.treeView.setShowFilter(true);
          app.menuView.refresh();
        },
      ),
      SubItemModel(
        name: 'Hide filters',
        icon: Icons.filter_list,
        secondaryIcon: Icons.clear,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.showFilter &&
            app.treeView.selected.isEmpty,
        onTap: (context) => app.treeView.setShowFilter(false),
      ),
      SubItemModel(
        name: 'Expand all',
        icon: Icons.unfold_more,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.selected.isEmpty &&
            app.treeView.expandAll != true,
        onTap: (context) => app.treeView.setExpandAll(true),
      ),
      SubItemModel(
        name: 'Collapse all',
        icon: Icons.unfold_more,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.selected.isEmpty &&
            app.treeView.expandAll == true,
        onTap: (context) => app.treeView.setExpandAll(false),
      ),
      SubItemModel(
        name: 'Refresh page',
        icon: Icons.refresh,
        condition: (context) => app.viewModel.webViewIsOpen,
        onTap: (context) async {
          await app.web.controller.reload();
        },
      ),
      SubItemModel(
        name: 'View contents',
        icon: Icons.chrome_reader_mode,
        condition: (context) =>
            app.viewModel.webViewIsOpen &&
            app.viewModel.root.webArticle?.article != null,
        onTap: (context) {
          MBS.showCupertinoModalBottomSheet(
            expand: false,
            context: context,
            //backgroundColor: Colors.transparent,
            builder: (context) => ArticleView(),
          );
        },
      ),
      SubItemModel(
        name: 'Edit title',
        icon: Icons.title,
        condition: (context) => app.treeView.selected.length == 1,
        onTap: (context) {
          app.treeView.setFocus(app.treeView.selected.first);
          app.menuView.close(); //.setIsEditing(true);
        },
      ),
      SubItemModel(
        name: 'Add tags',
        icon: Icons.style,
        onTap: (context) {
          app.tagsView.refresh();
          app.menuView.setSubMenuView(SubMenuView.tags);
        },
      ),
      SubItemModel(
        name: 'Set priority',
        icon: Icons.priority_high,
        onTap: (context) => MBS.showMaterialModalBottomSheet(
          expand: false,
          context: context,
          builder: (context) => ScentSelectionView(),
        ).then((value) => app.treeView.reloadTree()),
      ),
      SubItemModel(
          name: 'Add properties',
          icon: Icons.list,
          onTap: (context) {
            app.fieldsView.loadFields();
            app.menuView.setSubMenuView(SubMenuView.fields);
          }),
      SubItemModel(
          name: 'Read aloud',
          icon: Icons.headset,
          onTap: (context) {
            MBS.showCupertinoModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => ReadAloudModal(),
            );
          },
          condition: (context) {
            final inWebView = app.viewModel.view == ContentViewType.website;
            final inTreeView = app.viewModel.view == ContentViewType.links;
            final webContent = [
              ContentType.webArticle,
              ContentType.webSite,
            ];
            final rootIsWebContent =
                webContent.contains(app.treeView.rootNode.content.type);

            return (inWebView && rootIsWebContent) || inTreeView;
          }),
      // SubItemModel(
      //   name: 'Comments',
      //   icon: Icons.forum,
      //   onTap: (context) => null,
      // ),
      // SubItemModel(
      //   name: 'History',
      //   icon: Icons.history,
      //   onTap: (context) => null,
      // ),

      SubItemModel(
        name: 'Set reminder',
        icon: Icons.alarm,
        onTap: (context) => MBS.showCupertinoModalBottomSheet(
            context: context, builder: (context) => ReminderView()),
      ),
      // Should a pinned item appear on every daily page until unpinned or archived
      // SubItemModel(
      //   name: 'Pin',
      //   icon: Icons.push_pin,
      //   onTap: (context) => null,
      // ),
      SubItemModel(
          name: 'Share',
          icon: Icons.person_add,
          onTap: (context) {
            MBS.showMaterialModalBottomSheet(
                expand: false,
                context: context,
                builder: (context) => ShareModal());
          }),
      SubItemModel(
        name: 'Paste',
        icon: Icons.paste,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.clipboard.items.isNotEmpty,
        onTap: (context) {
          app.clipboard.pasteToSelected(context);
          app.menuView.openNavBar();
        },
        onLongPress: (context) => null, // show clipboard view
      ),
      SubItemModel(
        name: 'Copy',
        icon: Icons.copy,
        condition: (context) => app.viewModel.view == ContentViewType.links,
        onTap: (context) {
          app.clipboard.copySelected(context);
          app.menuView.openNavBar();
        },
      ),
      SubItemModel(
        name: 'Cut',
        icon: Icons.cut,
        condition: (context) =>
            app.viewModel.view == ContentViewType.links &&
            app.treeView.selected.isNotEmpty,
        onTap: (context) {
          app.clipboard.cutSelected(context);
          app.menuView.openNavBar();
        },
      ),
      SubItemModel(
        name: 'Archive',
        icon: Icons.archive,
        condition: (context) => app.viewModel.view == ContentViewType.links,
        onTap: (context) {
          app.treeView.archiveSelected();
          app.menuView.openNavBar();
        },
      ),
    ];
    items = allItems
        .where((model) =>
            model.condition == null || model.condition!.call(context))
        .toList();
  }
}

class SubItemModel {
  String name;
  IconData? icon;
  IconData? secondaryIcon;
  Widget? widget;
  Function(BuildContext)? count;
  Function(BuildContext)? onTap;
  Function(BuildContext)? onLongPress;
  bool Function(BuildContext)? condition;
  String Function(BuildContext)? value;
  SubItemModel({
    required this.name,
    this.count,
    this.icon,
    this.secondaryIcon,
    this.widget,
    this.onTap,
    this.onLongPress,
    this.condition,
  });
}
