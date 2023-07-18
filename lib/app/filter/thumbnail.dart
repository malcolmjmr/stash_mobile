import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/common_widgets/item_count.dart';
import 'package:stashmobile/app/filter/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/routing/app_router.dart';

class FilterThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.read(appProvider);
    final currentFilter = app.filters.contentFilter;
    return GestureDetector(
        child: currentFilter.name != null
            ? _buildSavedFilterView(context, currentFilter)
            : _buildFilterButtons(context, app.filters));
  }

  Widget _buildSavedFilterView(BuildContext context, Content currentFilter) =>
      GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.filterSettings),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Icon(Icons.filter_list),
            ),
            Text(currentFilter.name!, style: GoogleFonts.lato(fontSize: 14)),
          ],
        ),
      );

  Widget _buildFilterButtons(BuildContext context, FilterManager filters) =>
      Container(
          child: Row(
        children: [
          _buildFilterButton(
            context,
            page: FilterViewPage.filter,
            icon: Icons.filter_alt,
            count: filters.filterCount,
          ),
          _buildFilterButton(
            context,
            page: FilterViewPage.sort,
            icon: FontAwesomeIcons.sort,
            iconSize: 18,
            count: filters.sortCount,
          ),
          _buildFilterButton(
            context,
            page: FilterViewPage.view,
            icon: Icons.list_alt,
            count: filters.viewCount,
          )
        ],
      ));

  Widget _buildFilterButton(BuildContext context,
          {required FilterViewPage page,
          required IconData icon,
          double iconSize = 20,
          int count = 0}) =>
      GestureDetector(
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.filterSettings, arguments: page),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Icon(icon, size: iconSize),
              ),
              ItemCount(count),
            ],
          ),
        ),
      );
}
