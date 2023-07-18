import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/models/content/content.dart';

import 'colors.dart';
import 'model.dart';

class ScentSelectionView extends StatelessWidget {
  final Content? content;
  final double height;
  ScentSelectionView({this.content, this.height = 45});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context, content: this.content),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          color: Colors.transparent,
          height: height,
          child: _buildScentShades(model),
        );
      }),
    );
  }

  Widget _buildBackButton(ViewModel model) => GestureDetector(
        onTap: model.back,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.arrow_back_ios),
        ),
      );

  Widget _buildRatingStars(ViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [1, 2, 3, 4, 5, 6, 7]
            .map(
              (rating) => GestureDetector(
                onTap: () => model.updateValue(rating),
                child: rating <= model.rating
                    ? Icon(Icons.star, size: 30)
                    : Icon(
                        Icons.star_border,
                        size: 30,
                        color: model.ratingIsDisabled
                            ? Theme.of(model.context).disabledColor
                            : null,
                      ),
              ),
            )
            .toList(),
      );

  Widget _buildScentShades(ViewModel model) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PriorityColors.valueToShades.entries
            .map(
              (e) => Expanded(
                child: GestureDetector(
                  onTap: () => model.updateValue(e.key),
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

  Widget _buildClearButton(ViewModel model) => model.showClearRating
      ? GestureDetector(
          onTap: model.clearRating,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.clear),
          ),
        )
      : Container(
          width: 30,
        );
}
