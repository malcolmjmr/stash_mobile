import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';
import 'package:stashmobile/app/scent/colors.dart';

import 'model.dart';

class RatingFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  RatingFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return FieldConfigContainer(
          fieldModel: fieldModel,
          filterViewModel: filterViewModel,
          config: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Container(
              height: 30,
              child: _buildPrioritySelector(model),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOperationSelection(ViewModel model) => Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(FontAwesomeIcons.greaterThanEqual),
            ),
            Icon(FontAwesomeIcons.lessThanEqual)
          ],
        ),
      );

  Widget _buildPrioritySelector(ViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PriorityColors.valueToShades.entries
            .map(
              (e) => Expanded(
                child: GestureDetector(
                  onTap: () => model.updateRating(e.key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[e.value],
                      border: model.rating == e.key
                          ? Border.all(
                              color: Colors.white70,
                              width: 2,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}
