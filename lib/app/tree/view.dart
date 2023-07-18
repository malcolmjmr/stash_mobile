import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/app/common_widgets/header.dart';
import 'package:stashmobile/app/tree/add_content/view.dart';

import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/app/tree/node/model.dart';
import 'package:stashmobile/routing/app_router.dart';

import 'filter_selection/view.dart';
import 'node/view.dart';

class TreeView extends ConsumerWidget {
  // Todo: create model
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(treeViewProvider);
    // print(model.treeNodes
    //     .firstWhere((node) => node.content.title == 'sensemaking')
    //     .children
    //     .map((n) => n.content)
    //     .toList());
    return Container(
      color: Theme.of(context).primaryColorDark,
      child: Stack(
        children: [
          Column(
            children: [
              // Todo: - build header as page view
              ContentHeader(model.rootNode.content),
              model.showFilter
                  ? TreeViewFilterSelection(
                      key: ValueKey(model.rootNode.content.id))
                  : Container(),
              _buildContent(context, model),
              model.showAddContentOptions ? AddContentOptions() : Container(),
            ],
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: _buildFilterToggle(context, model),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TreeViewModel model) => Column(
        children: [
          _buildHeaderPageView(context, model),
        ],
      );

  Widget _buildHeaderPageView(BuildContext context, TreeViewModel model) =>
      Container(
        color: Theme.of(context).primaryColor,
        height: 50,
        child: PageView(
          scrollDirection: Axis.vertical,
          controller: model.headerPageController,
          onPageChanged: model.onHeaderPageChanged,
          children: [
            _buildHeaderTitlePage(context, model),
            _buildHeaderMenu(context, model),
          ],
        ),
      );

  Widget _buildHeaderTitlePage(BuildContext context, TreeViewModel model) =>
      Row(
        children: [
          // Expanded(child: ContentHeader(model.rootNode.content)),
          GestureDetector(
            onTap: () => model.showMenu(context),
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
      );

  Widget _buildHeaderMenu(BuildContext context, TreeViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLinkDirectionToggle(context, model),
          _buildExpandAllToggle(context, model),
          _buildFilterToggle(context, model),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.style_outlined),
          ),
          //FilterThumbnail(),
          _buildSelectAllToggle(context, model),
          //_buildShareButton(context, model),
        ],
      );

  Widget _buildFilterToggle(BuildContext context, TreeViewModel model) =>
      GestureDetector(
        onTap: () => model.setShowFilter(!model.showFilter),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              model.showFilter
                  ? Icons.account_tree_outlined
                  : Icons.filter_list,
            ),
          ),
        ),
      );

  Widget _buildContent(BuildContext context, TreeViewModel model) => Expanded(
        child: model.isLoading
            ? Container()
            : GestureDetector(
                onTap: () => model.onBackgroundTap(context),
                child: model.showFilteredList
                    ? _buildFilterList(context, model)
                    : _buildTree(context, model),
              ),
      );

  Widget _buildTree(BuildContext context, TreeViewModel model) {
    print('rebuilding tree');
    return model.rootNode.children.isNotEmpty
        ? ListView.builder(
            controller: model.scrollController,
            itemBuilder: (context, index) {
              TreeNodeViewModel node = model.rootNode.children[index];
              return TreeNodeView(
                key: UniqueKey(),
                model: node,
              );
            },
            itemCount: model.rootNode.children.length,
          )
        : Center(
            child: Text(
              'No links here yet',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          );
  }

  Widget _buildFilterList(BuildContext context, TreeViewModel model) =>
      model.treeNodes.isNotEmpty
          ? ListView.builder(
              controller: model.scrollController,
              itemBuilder: (context, index) {
                final node = model.treeNodes[index];
                return TreeNodeView(
                  key: UniqueKey(),
                  model: node,
                );
              },
              itemCount: model.treeNodes.length,
            )
          : Center(
              child: Text(
                'No links here yet',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            );

  Widget _buildRootMenu(BuildContext context, TreeViewModel model) => Material(
        child: Container(
          height: 200,
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
              _buildLinkDirectionToggle(context, model),
              _buildExpandAllToggle(context, model),

              //FilterThumbnail(),
              _buildSelectAllToggle(context, model),
              _buildShareButton(context, model),
            ],
          ),
        ),
      );

  Widget _buildLinkDirectionToggle(BuildContext context, TreeViewModel model) =>
      GestureDetector(
        onTap: () => model.setLinkDirection(
            context,
            model.linkDirection == LinkDirection.back
                ? LinkDirection.forward
                : LinkDirection.back),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, right: 8, left: 8),
          child: Container(
            width: 30,
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Icon(Icons.north_west,
                        color: model.linkDirection == LinkDirection.back
                            ? null
                            : Theme.of(context).disabledColor),
                  ),
                  Positioned(
                    top: 3,
                    left: 3,
                    child: Icon(
                      Icons.south_east,
                      color: model.linkDirection == LinkDirection.forward
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildExpandAllToggle(BuildContext context, TreeViewModel model) =>
      model.expandAll == true
          ? GestureDetector(
              onTap: () => model.setExpandAll(false),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                child: Icon(Icons.unfold_less),
              ),
            )
          : GestureDetector(
              onTap: () => model.setExpandAll(true),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                child: Icon(Icons.unfold_more),
              ),
            );

  Widget _buildSelectAllToggle(BuildContext context, TreeViewModel model) =>
      model.selectAll
          ? GestureDetector(
              onTap: () => model.setSelectAll(false),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                child: Icon(Icons.select_all_outlined),
              ),
            )
          : GestureDetector(
              onTap: () => model.setSelectAll(true),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 3.0, bottom: 3.0, left: 15, right: 15),
                child: Icon(Icons.select_all),
              ),
            );

  Widget _buildShareButton(BuildContext context, TreeViewModel model) =>
      GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.shareRoot),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 15, right: 15),
          child: Icon(Icons.ios_share),
        ),
      );
}
