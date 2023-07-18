import 'package:flutter/material.dart' hide SearchBar;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';

import 'model.dart';

class FilterValueSelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChangeNotifierProvider(
          create: (context) => ViewModel(context),
          child: Consumer<ViewModel>(builder: (context, model, _) {
            return Container();
          }),
        ),
      ),
    );
  }

  Widget _buildValueSearchBar(BuildContext context, ViewModel model) =>
      SearchBar(
        hintText: 'Find Value',
        onChanged: (text) => null,
        onSubmit: (text) => null,
      );

  Widget _buildValueList(BuildContext context, ViewModel model) => Expanded(
        child: ListView(
          children: model.relevantValues
              .map(
                (valueModel) => ListTile(
                  onTap: () => model.addValue(valueModel),
                  // leading: model.field!.type == FieldType.contentType
                  //     ? ContentIcon(
                  //         Content(type: valueModel.value as ContentType))
                  //     : ContentIcon(valueModel.value as Content),
                  title: Text(
                    valueModel.name,
                    style: valueModel.isSelected
                        ? GoogleFonts.lato(fontWeight: FontWeight.bold)
                        : GoogleFonts.lato(
                            color: Theme.of(context).disabledColor),
                  ),
                  trailing: valueModel.count != 0
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: valueModel.isSelected
                                ? Theme.of(context).primaryColorLight
                                : Theme.of(context).disabledColor,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(valueModel.count.toString(),
                                  style: valueModel.isSelected
                                      ? GoogleFonts.lato(
                                          fontWeight: FontWeight.bold)
                                      : GoogleFonts.lato(
                                          color:
                                              Theme.of(context).disabledColor)),
                            ),
                          ),
                        )
                      : null,
                ),
              )
              .toList(),
        ),
      );
}
