import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';

import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/links/basic/view.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';
import 'package:stashmobile/models/field/field.dart';
import 'package:stashmobile/routing/app_router.dart';

import 'fields/date/basic/view.dart';
import 'fields/number/basic/view.dart';
import 'fields/rating/basic/view.dart';
import 'fields/string/basic/view.dart';
import 'fields/tags/basic/view.dart';
import 'fields/type/basic/view.dart';
import 'model.dart';

class FilterView extends StatelessWidget {
  final Content? filter;
  final bool fromBranch;
  FilterView({this.filter, this.fromBranch = true});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FilterViewModel(context, filter),
      child: Consumer<FilterViewModel>(builder: (context, model, _) {
        return SafeArea(
          child: Scaffold(
            body: KeyboardVisibilityBuilder(
                builder: (context, keyboardIsVisible) {
              return Container(
                color: Theme.of(context).primaryColorDark,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        controller: model.scrollController,
                        slivers: [
                          _buildHeader(model),
                          _buildRecentFilters(model),
                          _buildFieldSearch(model),
                          _buildFieldList(model),
                        ],
                      ),
                    ),
                    keyboardIsVisible
                        ? Container()
                        : _buildPageSelection(model),
                  ],
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(FilterViewModel model) => SliverAppBar(
        automaticallyImplyLeading: false,
        floating: true,
        //pinned: true,
        toolbarHeight: 50,
        title: model.editingFilterTitle
            ? _buildFilterTitleTextField(model)
            : Row(
                children: [
                  GestureDetector(
                    onTap: () => model.goBack(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios),
                      ],
                    ),
                  ),
                  Expanded(
                    child: model.filters.filterIsSaved
                        ? _buildFilterTitle(model)
                        : _buildUnsavedFilterTitle(model),
                  ),
                ],
              ),
      );

  Widget _buildFilterTitleTextField(FilterViewModel model) => TextField(
        autofocus: true,
        onChanged: (text) => null,
        onSubmitted: model.saveFilterTitle,
        decoration: InputDecoration(
          hintText: 'Enter filter name',
          border: InputBorder.none,
        ),
      );

  Widget _buildFilterTitle(FilterViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 30,
              child: Center(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: model.updateFilterTitle,
                      child: Text(
                        model.filters.contentFilter.name!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: model.clearFilter,
            child: Icon(Icons.close),
          )
        ],
      );

  Widget _buildUnsavedFilterTitle(FilterViewModel model) => Row(
        children: [
          Expanded(
            child: Text(
              'New curation',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: model.updateFilterTitle,
            child: Icon(Icons.star_border),
          )
        ],
      );

  Widget _buildRecentFilters(FilterViewModel model) {
    final recentFilters = model.filters.recentFilters;
    //final scrollController = ScrollController();
    return SliverAppBar(
      toolbarHeight: 50,
      titleSpacing: 0,
      backgroundColor: Theme.of(model.context).primaryColorDark,
      automaticallyImplyLeading: false,
      title: Container(
        height: 30,
        child: Row(
          children: [
            GestureDetector(
              onTap: () =>
                  Navigator.of(model.context).pushNamed(AppRoutes.filterSearch),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Icon(Icons.search, size: 28),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentFilters.length,
                itemBuilder: (context, index) {
                  final filter = recentFilters[index];
                  return _buildFilterThumbnail(
                    context,
                    name: filter.name!,
                    onTap: () => model.setFilter(filter),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterThumbnail(
    BuildContext context, {
    required String name,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildFieldSearch(FilterViewModel model) => SliverAppBar(
        backgroundColor: Theme.of(model.context).primaryColorDark,
        //toolbarHeight: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SearchBar(
                hintText: 'Find field',
                controller: model.fieldSearchController,
                onChanged: (text) => model.updateRelevantFields(),
              ),
            ),
            model.canClearConfig
                ? GestureDetector(
                    onTap: model.clearConfig,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 5, bottom: 5, right: 5),
                      child: Icon(
                        Icons.clear_all,
                        size: 40,
                      ),
                    ))
                : Container()
          ],
        ),
      );

  Widget _buildFieldList(FilterViewModel model) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final fieldModel = model.relevantFields[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 12.0, right: 8.0),
              child: {
                FilterViewPage.filter: () =>
                    _buildFieldToFilter(model, fieldModel),
                FilterViewPage.sort: () => _buildFieldToSort(model, fieldModel),
                FilterViewPage.view: () => _buildFieldToView(model, fieldModel),
              }[model.page]!(),
            );
          },
          childCount: model.relevantFields.length,
        ),
      );

  Widget _buildFieldToFilter(
      FilterViewModel model, FilterFieldViewModel fieldModel) {
    // Todo: Add filter count
    switch (fieldModel.field.type) {
      case FieldType.contentType:
        return TypeFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.link:
        return LinksFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.tag:
        return TagFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.rating:
        return RatingFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.date:
        return DateFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.time:
        return Container();
      case FieldType.number:
        return NumberFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
      case FieldType.string:
        return StringFilterBasic(
          filterViewModel: model,
          fieldModel: fieldModel,
        );
    }
  }

  Widget _buildFieldToSort(
          FilterViewModel model, FilterFieldViewModel fieldModel) =>
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => model.toggleSortField(fieldModel),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: fieldModel.isSelected
                    ? Icon(Icons.check_circle)
                    : Icon(Icons.radio_button_off),
              ),
            ),
            Expanded(child: Text(fieldModel.field.name)),
            fieldModel.hasSortBy
                ? GestureDetector(
                    onTap: () => model.toggleSortDirection(fieldModel),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      child: Stack(
                        children: [
                          Icon(
                            FontAwesomeIcons.sort,
                            color: Theme.of(model.context).disabledColor,
                          ),
                          fieldModel.sortAscending
                              ? Icon(FontAwesomeIcons.sortUp)
                              : Icon(FontAwesomeIcons.sortDown),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );

  Widget _buildFieldToView(
          FilterViewModel model, FilterFieldViewModel fieldModel) =>
      Container(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => model.toggleFieldVisibility(fieldModel),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: fieldModel.isSelected
                    ? Icon(Icons.check_circle)
                    : Icon(Icons.radio_button_off),
              ),
            ),
            Expanded(child: Text(fieldModel.field.name)),
          ],
        ),
      );

  Widget _buildFieldConfigurationIcons(FieldSpec? fieldSpec) =>
      fieldSpec != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                fieldSpec.isVisible == true
                    ? Icon(Icons.visibility)
                    : Container(),
                fieldSpec.operations != null && fieldSpec.operations!.isNotEmpty
                    ? Icon(Icons.filter_alt)
                    : Container(),
                fieldSpec.sortAscending != null
                    ? fieldSpec.sortAscending!
                        ? Icon(FontAwesomeIcons.sortUp)
                        : Icon(FontAwesomeIcons.sortDown)
                    : Container(),
              ],
            )
          : Container();

  Widget _buildPageSelection(FilterViewModel model) => Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pageSelection(
              model,
              name: 'Filter',
              icon: Icons.filter_alt,
              page: FilterViewPage.filter,
            ),
            _pageSelection(
              model,
              name: 'Sort',
              icon: FontAwesomeIcons.sort,
              iconSize: 18,
              page: FilterViewPage.sort,
            ),
            _pageSelection(
              model,
              name: 'View',
              icon: Icons.list_alt,
              page: FilterViewPage.view,
            )
          ],
        ),
      );

  Widget _pageSelection(
    FilterViewModel model, {
    required String name,
    required IconData icon,
    required FilterViewPage page,
    double iconSize = 20,
  }) {
    final count = model.getPageConfigCount(page);
    return GestureDetector(
      onTap: () => model.setPage(page),
      child: Container(
        decoration: model.page == page
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white, width: 2)))
            : null,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Icon(
                  icon,
                  size: iconSize,
                ),
              ),
              Text(name, style: GoogleFonts.lato(fontSize: 14)),
              count > 0
                  ? Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Theme.of(model.context).highlightColor,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              count.toString(),
                              style: GoogleFonts.lato(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
