import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/filter/fields/field_config_container.dart';
import 'package:stashmobile/app/filter/model.dart';
import 'package:stashmobile/app/tags/model.dart';

import 'model.dart';

class TagFilterBasic extends StatelessWidget {
  final FilterFieldViewModel fieldModel;
  final FilterViewModel filterViewModel;
  TagFilterBasic({required this.fieldModel, required this.filterViewModel});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Column(
          children: [
            FieldConfigContainer(
              fieldModel: fieldModel,
              filterViewModel: filterViewModel,
              titleConfig: _buildSearchField(model),
              config: Container(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [_buildTags(model)],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchField(ViewModel model) {
    final style = GoogleFonts.lato(fontSize: 12);
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: model.textController,
              onChanged: model.onSearchUpdated,
              onSubmitted: model.onSearchSubmit,
              style: style,
              decoration: InputDecoration(
                hintStyle: style,
                hintText: 'Search',
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          _buildInclusionToggle(model, style),
        ],
      ),
    );
  }

  Widget _buildInclusionToggle(ViewModel model, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Any',
              style: style,
            ),
          ),
          Text(
            'All',
            style: style,
          )
        ],
      ),
    );
  }

  Widget _buildTags(ViewModel model) => model.tagsAreLoading
      ? CircularProgressIndicator()
      : Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: model.relevantTags
                .map((tagViewModel) => _buildTag(
                      model,
                      tagViewModel,
                    ))
                .toList(),
          ),
        );

  Widget _buildTag(ViewModel model, TagViewModel tagViewModel) =>
      GestureDetector(
        onTap: () => model.toggleSelection(tagViewModel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            color: tagViewModel.isSelected
                ? Theme.of(model.context).highlightColor
                : Theme.of(model.context).disabledColor,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 2.0,
                bottom: 2.0,
                left: 3,
                right: 3,
              ),
              child: Text(
                  '${tagViewModel.tag.name!} ${tagViewModel.tag.tag!.instances.length}'),
            ),
          ),
        ),
      );
}
