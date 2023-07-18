import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';

import 'model.dart';

class DateFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  DateFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: Container(height: 30, child: _buildDateOptions(model)),
        );
      }),
    );
  }

  Widget _buildDateOptions(ViewModel model) => Container(
        child: Center(child: Text('{Date selection}')),
      );
}
