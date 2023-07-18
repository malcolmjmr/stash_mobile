import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';
import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class TypeFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  TypeFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: Container(height: 40, child: _buildTypeOptions(model)),
        );
      }),
    );
  }

  Widget _buildTypeOptions(ViewModel model) => model.typeListIsLoading
      ? CircularProgressIndicator()
      : ListView(
          scrollDirection: Axis.horizontal,
          children: model.typeList
              .map((typeModel) => _buildType(model, typeModel))
              .toList(),
        );

  Widget _buildType(ViewModel model, TypeViewModel typeViewModel) {
    final unselectedColor = Theme.of(model.context).disabledColor;
    return GestureDetector(
      onTap: () => model.toggleTypeSelection(typeViewModel),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          {
            ContentType.annotation: () => Icons.short_text,
            ContentType.filter: () => Icons.filter_list,
            ContentType.webSearch: () => Icons.travel_explore,
            ContentType.webSite: () => Icons.public,
            ContentType.topic: () => Icons.topic,
            ContentType.tag: () => Icons.local_offer,
            ContentType.note: () => Icons.article,
            ContentType.root: () => Icons.account_tree_outlined,
            ContentType.dailyPage: () => Icons.today,
            ContentType.task: () => Icons.check_box_outline_blank
          }[typeViewModel.type]!(),
          color: typeViewModel.isSelected ? null : unselectedColor,
        ),
      ),
    );
  }
}
