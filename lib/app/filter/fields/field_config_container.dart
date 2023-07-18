import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stashmobile/app/filter/model.dart';
import 'package:stashmobile/routing/app_router.dart';

class FieldConfigContainer extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  final Widget? titleConfig;
  final Widget config;
  FieldConfigContainer({
    required this.fieldModel,
    required this.filterViewModel,
    required this.config,
    this.titleConfig,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeading(context),
        fieldModel.hasFilters ? config : Container(),
      ],
    );
  }

  Widget _buildHeading(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => filterViewModel.toggleFilterField(fieldModel),
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: fieldModel.hasFilters
                    ? Icon(Icons.check_circle)
                    : Icon(Icons.radio_button_off),
              ),
            ),
            Expanded(
                child: Row(
              children: [
                Text(
                  fieldModel.field.name,
                  style: GoogleFonts.lato(),
                ),
                fieldModel.hasFilters && titleConfig != null
                    ? Expanded(
                        child: titleConfig!,
                      )
                    : Container(),
              ],
            )),
            fieldModel.hasFilters
                ? GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.filterFieldSettings,
                            arguments: fieldModel.field)
                        .then(filterViewModel.refreshPageOnPop),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Icon(
                        Icons.more_horiz,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      );
}
