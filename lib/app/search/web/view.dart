import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';

import 'model.dart';

class WebSearch extends StatelessWidget {
  final String searchText;
  WebSearch(this.searchText);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context, searchText),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return model.searchText.isEmpty
            ? _buildRecentSearches(model)
            : Container();
      }),
    );
  }

  Widget _buildRecentSearches(ViewModel model) => ListView.builder(
        itemBuilder: (context, index) {
          final search = model.relevantSearches[index];
          return ListItem(
            search,
            onTap: () => model.openExistingSearch(search),
          );
        },
        itemCount: model.relevantSearches.length,
      );
}
