import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';

import 'model.dart';

class FilterSearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => ViewModel(context),
        child: Consumer<ViewModel>(
          builder: (context, model, _) {
            return Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(child: Text('Back')),
              ),
            );
          },
        ),
      ),
    ));
  }

  Widget _buildSearchBar(ViewModel model) => Row(
        children: [
          SearchBar(),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.cancel),
            ),
          )
        ],
      );
}
