import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class FilterSelection extends StatelessWidget {
  final Function(Content) setFilterMethod;
  final List<String> defaultFilters;
  const FilterSelection(
      {Key? key, required this.setFilterMethod, this.defaultFilters = const []})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(
        context,
        setFilterCallback: setFilterMethod,
        defaultFilters: defaultFilters,
      ),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          color: Theme.of(context).primaryColorDark,
          height: 35,
          child: CustomScrollView(
            controller: model.scrollController,
            scrollDirection: Axis.horizontal,
            slivers: [
              _buildFilterButton(model),
              _buildFilterOptions(model),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterButton(ViewModel model) => SliverAppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30,
        titleSpacing: 0,
        floating: true,
        backgroundColor: Colors.transparent,
        title: GestureDetector(
          onTap: () => model.openFilterSettings(null),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.add),
          ),
        ),
      );

  Widget _buildFilterOptions(ViewModel model) => SliverList(
        delegate: SliverChildListDelegate(
          model.filters
              .map((filter) => _buildFilterTitle(model, filter))
              .toList(),
        ),
      );

  Widget _buildFilterTitle(ViewModel model, Content filter) => GestureDetector(
        onTap: () => model.setFilter(filter),
        onDoubleTap: () => model.openFilterSettings(filter),
        child: Container(
          decoration: filter.id == model.currentFilter.id
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(model.context).hintColor,
                      width: 2,
                    ),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
            child: Text(filter.title),
          ),
        ),
      );
}
