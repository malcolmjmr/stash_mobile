import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/content_icon/view.dart';
import 'package:stashmobile/app/common_widgets/content_title/view.dart';

import 'model.dart';

class HighlightView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = HighlightViewModel(context);
    return Column(
      children: [
        _buildHighlight(model),
        _buildDocument(model),
      ],
    );
  }

  Widget _buildHighlight(HighlightViewModel model) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContentIcon(model.highlight),
            Expanded(
              child: ListView(
                children: [
                  ContentTitle(
                    model.highlight,
                    fontSize: 20,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocument(HighlightViewModel model) {
    return GestureDetector(
      onTap: () => model.openDocument(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 30,
            child: Opacity(
              opacity: 0.8,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ContentIcon(model.document),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: ContentTitle(model.document),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
