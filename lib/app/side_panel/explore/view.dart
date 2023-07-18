import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ExploreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExploreViewModel(context),
      child: Consumer<ExploreViewModel>(builder: (context, model, _) {
        return Container(
          color: Theme.of(context).primaryColor,
        );
      }),
    );
  }
}
