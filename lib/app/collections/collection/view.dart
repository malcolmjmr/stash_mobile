import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/collections/collection/filters/default_filters.dart';
import 'package:stashmobile/app/collections/collection/filters/view.dart';
import 'package:stashmobile/app/collections/collection/icon.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';
import 'package:stashmobile/models/collection/model.dart';

import 'model.dart';

class CollectionView extends StatelessWidget {
  final Collection collection;
  CollectionView(this.collection);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColorDark,
          child: ChangeNotifierProvider(
            create: (_) => CollectionViewModel(context, collection),
            lazy: false,
            child: Consumer<CollectionViewModel>(builder: (context, model, _) {
              return Column(
                children: [
                  _buildNavigation(model),
                  _buildHeader(model),
                  FilterSelection(
                      setFilterMethod: model.setFilter,
                      defaultFilters: defaultFilters),
                  Expanded(child: _buildFilteredList(model)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CollectionViewModel model) => Padding(
        padding: const EdgeInsets.only(left: 10.0, top: 5),
        child: Container(
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CollectionIcon(
                model.collection,
                onTap: () => null, // go to icon selection page,
                padding: EdgeInsets.only(top: 5),
                size: 40,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10.0),
                  child: Container(
                    height: 20,
                    child: Text(
                      model.collection.name,
                      style: GoogleFonts.lato(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildFilteredList(CollectionViewModel model) => model.isLoading
      ? Center(
          child: CircularProgressIndicator(),
        )
      : ListView.builder(
          itemBuilder: (context, index) {
            final content = model.filteredList[index];
            return ListItem(
              content,
              onDoubleTap: () => model.onDoubleTapContent(content),
              onTap: () => model.onTapContent(content),
            );
          },
          itemCount: model.filteredList.length,
        );

  BoxDecoration _editableDecoration(CollectionViewModel model) => BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(model.context).primaryColor,
          ),
          BoxShadow(
            color: Theme.of(model.context).primaryColor,
            spreadRadius: -5.0,
            blurRadius: 5.0,
          ),
        ],
      );

  Widget _buildDetails(CollectionViewModel model) => Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          //decoration: model.userIsOwner ? _editableDecoration(model) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDescription(model),
              _buildCategories(model),
            ],
          ),
        ),
      );

  Widget _buildDescription(CollectionViewModel model) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: model.userIsOwner ? _editableDecoration(model) : null,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: TextField(
              maxLines: null,
              autofocus: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Add description',
                isCollapsed: true,
              ),
              style: GoogleFonts.lato(
                  color: Theme.of(model.context).disabledColor),
            ),
          ),
        ),
      );

  Widget _buildCategories(CollectionViewModel model) =>
      model.collection.categories == null ||
              model.collection.categories!.isEmpty
          ? Chip(
              label: Text('+ Add Category'),
            )
          : Container();

  Widget _buildNavigation(CollectionViewModel model) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          height: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(model.context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              GestureDetector(
                onTap: model.openRoot,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    children: [
                      Icon(Icons.account_tree_outlined),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text('Root'),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: model.openSearch,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5),
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text('Search'),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: model.openRoot,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5),
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text('Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPages(CollectionViewModel model) => Expanded(
          child: Column(
        children: [
          Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: model.subPages
                    .map((page) => _buildPageTitle(model, page))
                    .toList(),
              )),
          Expanded(child: model.subPage.view(model.context))
        ],
      ));

  Widget _buildPageTitle(
          CollectionViewModel model, CollectionHomeSubPage page) =>
      GestureDetector(
        onTap: () => model.setPage(page),
        child: Container(
          decoration: model.subPage.name == page.name
              ? BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 3,
                          color: Theme.of(model.context)
                              .textTheme
                              .displayLarge!
                              .color!)))
              : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Icon(page.icon),
                Text(page.name, style: GoogleFonts.lato(fontSize: 18)),
              ],
            ),
          ),
        ),
      );

  Widget _buildTag({required String name, int count = 0, Function()? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Chip(
          elevation: 5,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('$name ${count > 0 ? count : null}')],
          ),
        ),
      );
}
