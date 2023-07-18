import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';
import 'package:stashmobile/app/providers/fields.dart';
import 'package:stashmobile/routing/app_router.dart';

import 'model.dart';

class FieldsView extends ConsumerWidget {
  final bool fullScreenMode;
  FieldsView({this.fullScreenMode = false});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(fieldViewProvider);
    return Container(
      height:
          (model.showFullScreen ? 1 : .4) * MediaQuery.of(context).size.height,
      child: CustomScrollView(
        slivers: [
          _buildHeader(context, model),
          _buildContentFields(context, model),
          _buildSuggestedFields(context, model),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FieldsViewModel model) =>
      SliverAppBar(
        toolbarHeight: 50,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        floating: true,
        title: Row(
          children: [
            _buildBackButton(context, model),
            Expanded(child: _buildInputField(context, model))
          ],
        ),
      );

  Widget _buildBackButton(BuildContext context, FieldsViewModel model) =>
      GestureDetector(
        onTap: () {
          model.goBack(context);
          if (fullScreenMode) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.arrow_back_ios),
        ),
      );

  Widget _buildInputField(BuildContext context, FieldsViewModel model) =>
      SearchBar(
        height: 40,
        padding: EdgeInsets.only(top: 5, bottom: 5, right: 15),
        color: Theme.of(context).primaryColorDark,
        hintText: 'Search Field',
        //textAlign: TextAlign.center,
        autofocus: model.shouldAutoFocusSearch(context),
        controller: model.searchTextController,
        onChanged: model.onSearchUpdated,
        onSubmit: (text) => model.onSearchSubmit(context, text),
        onTap: fullScreenMode
            ? null
            : () => Navigator.of(context).pushNamed(AppRoutes.contentFields),
      );

  Widget _buildContentFields(BuildContext context, FieldsViewModel model) =>
      model.needToCreateNewField
          ? SliverFillRemaining(
              child: Center(
                child:
                    Text('create "${model.searchTextController.text.trim()}"'),
              ),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildContentField(
                    context, model, model.contentFields[index]),
                childCount: model.contentFields.length,
              ),
            );

  Widget _buildContentField(BuildContext context, FieldsViewModel viewModel,
          FieldViewModel fieldModel) =>
      Container(
        child: Row(
          children: [
            _buildFieldTypeIcon(viewModel, fieldModel),
            Expanded(
                flex: 1,
                child: _buildFieldName(context, viewModel, fieldModel)),
            Expanded(
                flex: 2,
                child: _buildFieldValue(context, viewModel, fieldModel)),
          ],
        ),
      );

  Widget _buildFieldTypeIcon(
    FieldsViewModel viewModel,
    FieldViewModel fieldModel,
  ) =>
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: fieldModel.value != null
            ? Icon(viewModel.typeToIconMap[fieldModel.field.type]!)
            : Container(
                height: 30,
                width: 30,
                child: PageView(
                  onPageChanged: (typeIndex) =>
                      viewModel.onFieldTypeChange(fieldModel, typeIndex),
                  scrollDirection: Axis.vertical,
                  controller: PageController(
                      initialPage: viewModel.typeToIconMap.keys
                          .toList()
                          .indexOf(fieldModel.field.type)),
                  children: viewModel.typeToIconMap.values
                      .map((icon) => Icon(icon))
                      .toList(),
                ),
              ),
      );

  Widget _buildTextField(FieldViewModel fieldModel,
          {String? hintText, Function(String)? onSubmitted}) =>
      TextField(
        autofocus: true,
        controller: TextEditingController(
          text: fieldModel.nameIsSelected
              ? fieldModel.field.name
              : fieldModel.value != null
                  ? fieldModel.value.toString()
                  : null,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          isCollapsed: true,
          border: InputBorder.none,
        ),
        onSubmitted: onSubmitted,
      );

  Widget _buildFieldName(
    BuildContext context,
    FieldsViewModel viewModel,
    FieldViewModel fieldModel,
  ) =>
      fieldModel.nameIsSelected
          ? _buildTextField(fieldModel,
              onSubmitted: (text) => viewModel.saveFieldName(fieldModel, text))
          : GestureDetector(
              onLongPress: () =>
                  viewModel.onLongPressFieldName(context, fieldModel),
              child: Text(
                fieldModel.field.name,
                textAlign: TextAlign.center,
              ),
            );

  Widget _buildFieldValue(BuildContext context, FieldsViewModel viewModel,
      FieldViewModel fieldModel) {
    print(fieldModel.value);
    return fieldModel.valueIsSelected
        ? _buildTextField(fieldModel,
            hintText: 'Enter value',
            onSubmitted: (text) => viewModel.saveFieldValue(fieldModel, text))
        : GestureDetector(
            onLongPress: () =>
                viewModel.onLongPressFieldValue(context, fieldModel),
            child: Text(fieldModel.value != null
                ? fieldModel.value.toString()
                : 'Press to add value'),
          );
  }

  Widget _buildSuggestedFields(BuildContext context, FieldsViewModel model) =>
      SliverFillRemaining(
        child: model.suggestedFields.isEmpty && model.contentFields.isEmpty
            ? Center(child: Text('No fields added yet'))
            : Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: model.suggestedFields
                      .map(
                        (fieldModel) =>
                            _buildSuggestedField(context, model, fieldModel),
                      )
                      .toList(),
                ),
              ),
      );

  Widget _buildSuggestedField(BuildContext context, FieldsViewModel viewModel,
          FieldViewModel fieldModel) =>
      GestureDetector(
        onTap: () => viewModel.addFieldFromSuggestions(context, fieldModel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(fieldModel.field.name),
            ),
          ),
        ),
      );
}
