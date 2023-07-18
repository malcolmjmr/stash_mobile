import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';

import 'model.dart';

class NumberFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  NumberFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: Container(height: 50, child: _buildSlider(model)),
        );
      }),
    );
  }

  Widget _buildSlider(ViewModel model) => RangeSlider(
        values: model.rangeValues,
        onChanged: model.onRangeChanged,
      );

  Widget _buildNoValue(ViewModel model) => Container(child: Text('Empty'));
  Widget _buildMin(ViewModel model) => Container();

  Widget _buildMax(ViewModel model) => Container();
}
