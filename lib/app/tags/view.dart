import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/search_bar/view.dart';
import 'package:stashmobile/routing/app_router.dart';

import 'model.dart';

class TagsView extends ConsumerWidget {
  final bool fullScreenMode;
  final Function()? goBack;
  TagsView({this.fullScreenMode = false, this.goBack});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(tagsViewProvider);
    return Container(
      height: (fullScreenMode ? 1 : .4) * MediaQuery.of(context).size.height,
      child: CustomScrollView(
        slivers: [
          _buildHeader(context, model),
          _buildTags(context, model),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TagsViewModel model) =>
      SliverAppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        floating: true,
        title: Row(
          children: [
            _buildCancelButton(context, model),
            Expanded(child: _buildInputField(context, model))
          ],
        ),
      );

  Widget _buildCancelButton(BuildContext context, TagsViewModel model) =>
      GestureDetector(
          onTap: () {
            if (goBack != null)
              goBack!.call();
            else
              model.goBack(context);
            if (fullScreenMode) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios_new),
          ));

  Widget _buildTag(BuildContext context, TagViewModel tagViewModel) {
    Color color = Theme.of(context).cardColor;
    if (tagViewModel.isSelected)
      color = Theme.of(context).canvasColor;
    else if (tagViewModel.isPartiallySelected)
      color = Theme.of(context).highlightColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
              '${tagViewModel.tag.name!} ${tagViewModel.tag.tag!.instances.length}'),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, TagsViewModel model) =>
      SearchBar(
        padding: EdgeInsets.only(top: 20, bottom: 10, right: 10),
        color: Theme.of(context).primaryColorDark,
        hintText: 'Enter tag',
        autofocus: fullScreenMode,
        controller: model.textController,
        onChanged: model.onSearchUpdated,
        onSubmit: (text) => model.onSearchSubmit(context, text),
        onTap: fullScreenMode
            ? null
            : () => Navigator.of(context).pushNamed(AppRoutes.contentTags),
      );

  Widget _buildTags(BuildContext context, TagsViewModel model) {
    final tags = model.relevantTags;
    return tags.isEmpty
        ? SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
                child: Text(model.textController.text.isEmpty
                    ? 'No tags yet'
                    : 'create "${model.textController.text.trim()}"')))
        : SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags
                      .map((tagViewModel) => GestureDetector(
                          onTap: () =>
                              model.toggleTagSelection(tagViewModel.tag),
                          onLongPress: () =>
                              model.openTag(context, tagViewModel.tag),
                          child: _buildTag(context, tagViewModel)))
                      .toList(),
                )),
          );
  }
}
