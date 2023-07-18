import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/tags/model.dart';
import 'package:stashmobile/app/tags/tag.dart';

class SingleRowTagView extends ConsumerWidget {
  final double height;
  const SingleRowTagView({Key? key, this.height = 30}) : super(key: key);
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(tagsViewProvider);
    return Container(
      color: Colors.transparent,
      height: height,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.tagViewModels.length,
          itemBuilder: (context, index) {
            final tagViewModel = model.tagViewModels[index];
            Color color = Theme.of(context).cardColor;
            if (tagViewModel.isSelected)
              color = Theme.of(context).canvasColor;
            else if (tagViewModel.isPartiallySelected)
              color = Theme.of(context).highlightColor;
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: GestureDetector(
                onTap: () => model.toggleTagSelection(tagViewModel.tag),
                child: TagView(tagViewModel.tag, color: color),
              ),
            );
          }),
    );
  }
}
