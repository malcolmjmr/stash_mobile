import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';

import 'model.dart';

class LinksFilterBasic extends StatelessWidget {
  final FilterViewModel filterViewModel;
  final FilterFieldViewModel fieldModel;
  LinksFilterBasic({required this.filterViewModel, required this.fieldModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: Container(),
        );
      }),
    );
  }
}
