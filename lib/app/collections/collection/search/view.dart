import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/collections/collection/list_item/view.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart'
    as SearchBarView;
import 'package:stashmobile/models/collection/category.dart';

import 'model.dart';

class CollectionSearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider(
          create: (context) => CollectionSearchViewModel(context),
          child:
              Consumer<CollectionSearchViewModel>(builder: (context, model, _) {
            return Container(
              color: Theme.of(context).primaryColorDark,
              child: CustomScrollView(
                slivers: [
                  model.category == null
                      ? _buildMainHeader(model)
                      : _buildCategoryHeader(model),
                  model.category == null
                      ? model.userIsSearching
                          ? _buildSearchResults(model)
                          : _buildCategories(model)
                      : _buildCategoryCollections(model),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMainHeader(CollectionSearchViewModel model) => SliverAppBar(
        backgroundColor: Theme.of(model.context).primaryColorDark,
        floating: true,
        toolbarHeight: 60,
        leading: GestureDetector(
          onTap: () => Navigator.of(model.context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        leadingWidth: 24,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: SearchBarView.SearchBar(
            leading: Icon(Icons.search),
            color: Theme.of(model.context).primaryColorDark,
            hintText: 'Search Collection',
            controller: model.textController,
            onTap: model.onSearchOpen,
            onChanged: model.onSearchChange,
            onSubmit: model.onSearchSubmit,
          ),
        ),
      );

  Widget _buildSearchResults(CollectionSearchViewModel model) =>
      model.searchIsLoading
          ? SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      CollectionListItem(model.searchResults[index]),
                  childCount: model.searchResults.length),
            );

  Widget _buildCategoryHeader(CollectionSearchViewModel model) => SliverAppBar(
      toolbarHeight: 50,
      floating: true,
      leading: GestureDetector(
        onTap: () => model.setCategory(null),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
      title: Text(model.category!.name));

  Widget _buildCategories(CollectionSearchViewModel model) =>
      model.categoriesAreLoading
          ? SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                crossAxisCount: 2,
                mainAxisExtent: 60,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = model.categories[index];
                return _buildCategoryThumbnail(context, category,
                    onTap: () => model.setCategory(category));
              }, childCount: model.categories.length),
            );

  Widget _buildCategoryThumbnail(BuildContext context, Category category,
          {Function()? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                category.name,
                style: GoogleFonts.lato(fontSize: 16),
              ),
            ),
          ),
        ),
      );

  Widget _buildCategoryCollections(CollectionSearchViewModel model) => model
          .collectionsAreLoading
      ? SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      : SliverList(
          delegate: SliverChildBuilderDelegate(
              (context, index) => CollectionListItem(model.collections[index]),
              childCount: model.collections.length),
        );
}
