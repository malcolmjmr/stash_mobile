import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/routing/app_router.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class FilterSelectionBar extends StatelessWidget {
  final Function(Content)? onFilterSelected;
  final FilterContext filterContext;
  FilterSelectionBar(
      {this.onFilterSelected, this.filterContext = FilterContext.search});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context, filterContext: filterContext),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOptions(model),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.filterSettings,
                    arguments: onFilterSelected),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 3.0, right: 3.0, top: 8, bottom: 8),
                  child: Icon(Icons.filter_list),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterOptions(ViewModel model) {
    return Expanded(
      child: ListView.builder(
        controller: model.scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: model.filters.length,
        itemBuilder: (context, index) {
          final filter = model.filters[index];
          return _buildFilterThumbnail(context,
              name: filter.name!,
              onTap: () => model.setFilter(filter, onFilterSelected),
              isSelected: filter.id == model.currentFilterId);
        },
      ),
    );
  }

  Widget _buildFilterThumbnail(
    BuildContext context, {
    required String name,
    Function()? onTap,
    bool isSelected = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: isSelected
                  ? Border(
                      bottom: BorderSide(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .displayLarge!
                              .color!,
                          width: 3.0))
                  : null),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                name,
                style: GoogleFonts.lato(fontSize: 14),
              ),
            ),
          ),
        ),
      );
}
