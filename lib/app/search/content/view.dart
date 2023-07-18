import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';

import 'model.dart';

class ContentSearch extends StatelessWidget {
  final String searchText;
  ContentSearch(this.searchText);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      key: UniqueKey(),
      create: (_) => ViewModel(context, searchText),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Column(
          children: [
            //FilterSelectionBar(callback: model.loadResults),
            _buildResults(model),
          ],
        );
      }),
    );
  }

  Widget _buildResults(ViewModel model) => Expanded(
        child: model.isLoading
            ? Center(child: CircularProgressIndicator())
            : model.results.isNotEmpty
                ? ListView.builder(
                    itemCount: model.results.length,
                    itemBuilder: (context, index) {
                      final content = model.results[index];
                      return ListItem(
                        content,
                        onTap: () => model.onTapContent(content),
                        onDoubleTap: () => model.onDoubleTapContent(content),
                      );
                    })
                : model.searchText.isNotEmpty
                    ? Center(
                        child: Text('Could not find "${model.searchText}"'))
                    : Container(),
      );
}
