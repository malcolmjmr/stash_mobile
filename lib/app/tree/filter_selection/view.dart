import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class TreeViewFilterSelection extends StatelessWidget {
  const TreeViewFilterSelection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          color: Theme.of(context).primaryColorDark,
          height: 35,
          child: ListView(
            controller: model.scrollController,
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterButton(model),
              ...model.filters
                  .map((filter) => _buildFilterTitle(model, filter))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterButton(ViewModel model) => GestureDetector(
        onTap: () => model.openFilterSettings(null),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.add),
        ),
      );

  Widget _buildFilterTitle(ViewModel model, Content filter) {
    final isCurrentFilter = filter.id == model.filters.first.id;
    return GestureDetector(
      onTap: () => !isCurrentFilter ? model.setFilter(filter) : null,
      onDoubleTap: () => model.openFilterSettings(filter),
      child: Container(
        decoration: isCurrentFilter
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
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
          child: !model.filterIsSaved && isCurrentFilter
              ? Icon(Icons.tune)
              : Text(filter.title),
        ),
      ),
    );
  }
}
