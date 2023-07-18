import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';

import 'model.dart';

class StringFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  StringFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: _buildOptions(model),
        );
      }),
    );
  }

  Widget _buildSearch(ViewModel model) => Container();

  Widget _buildOptions(ViewModel model) => Container();
}
