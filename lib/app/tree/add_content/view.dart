import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class AddContentOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ViewModel(context),
      child: Consumer<ViewModel>(builder: (context, model, _) {
        return Container(
          color: Theme.of(context).primaryColor,
          height: 40,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [
              _buildBackSliver(model),
              _buildContentTypeSelection(model),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBackSliver(ViewModel model) => SliverAppBar(
        automaticallyImplyLeading: false,
        floating: true,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: model.cancel,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(Icons.cancel),
          ),
        ),
      );

  Widget _buildContentTypeSelection(ViewModel model) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = model.items[index];
        final isSelected = model.selectedItem == item;
        return GestureDetector(
          onTap: () => model.setSelected(item),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 6.0, right: 6.0, top: 2, bottom: 2),
            child: Icon(
              item.icon,
              color: isSelected ? null : Theme.of(context).disabledColor,
            ),
          ),
        );
      }, childCount: model.items.length),
    );
  }
}
