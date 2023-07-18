import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/content_icon/view.dart';
import 'package:stashmobile/models/content/content.dart';

import 'model.dart';

class TypeFilterBasic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return CustomScrollView(
          slivers: [_buildHeader(model), _buildTypeList(model)],
        );
      }),
    );
  }

  Widget _buildHeader(ViewModel model) => SliverAppBar(
        floating: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(model.context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(Icons.category),
            ),
            Text('Type')
          ],
        ),
      );

  Widget _buildTypeList(ViewModel model) => model.typeListIsLoading
      ? SliverFillRemaining(child: CircularProgressIndicator())
      : SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final typeViewModel = model.typeList[index];
            return _buildTypeListItem(
              model,
              typeViewModel,
            );
          }, childCount: model.typeList.length),
        );

  Widget _buildTypeListItem(ViewModel model, TypeViewModel typeViewModel) {
    final unselectedColor = Theme.of(model.context).textTheme.displayLarge!.color!;
    return GestureDetector(
      onTap: () => model.toggleTypeSelection(typeViewModel),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: ContentIcon(
                Content(type: typeViewModel.type),
                size: 30,
                color: typeViewModel.isSelected ? null : unselectedColor,
              ),
            ),
            Text(
              typeViewModel.title,
              style: GoogleFonts.lato(
                fontSize: 20,
                color: typeViewModel.isSelected ? null : unselectedColor,
              ),
            ),
            typeViewModel.isSelected
                ? Padding(
                    padding: const EdgeInsets.only(top: 5.0, left: 8.0),
                    child: Icon(
                      Icons.cancel,
                      size: 12,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
