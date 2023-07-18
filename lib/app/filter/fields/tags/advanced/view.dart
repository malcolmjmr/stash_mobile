import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';
import 'package:stashmobile/app/tags/model.dart';

import 'model.dart';

class TagFilterAdvanced extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return CustomScrollView(
          slivers: [
            _buildHeader(model),
            _buildSearchField(model),
            _buildTags(model)
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ViewModel model) => SliverAppBar(
        floating: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: model.goBack,
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
              child: Icon(Icons.style),
            ),
            Text('Tags')
          ],
        ),
      );

  Widget _buildSearchField(ViewModel model) => SliverToBoxAdapter(
        child: SearchBar(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          color: Theme.of(model.context).primaryColorDark,
          hintText: 'Find tag',
          //focusNode: model.focusNode,
          controller: model.textController,
          onChanged: model.onSearchUpdated,
          onSubmit: model.onSearchSubmit,
        ),
      );

  Widget _buildTags(ViewModel model) => model.tagsAreLoading
      ? SliverFillRemaining(
          hasScrollBody: false, child: CircularProgressIndicator())
      : SliverFillRemaining(
          hasScrollBody: false,
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: model.relevantTags
                .map((tagViewModel) => _buildTag(
                      model,
                      tagViewModel,
                    ))
                .toList(),
          ));

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
              padding: const EdgeInsets.all(5.0),
              child: Text(
                  '${tagViewModel.tag.name!} ${tagViewModel.tag.tag!.instances.length}'),
            ),
          ),
        ),
      );
}
