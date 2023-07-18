import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class CollectionSearch extends StatelessWidget {
  final String searchText;
  CollectionSearch(this.searchText);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context, searchText),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container();
      }),
    );
  }
}
