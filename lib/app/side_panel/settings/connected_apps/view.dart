import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/app_bar_container.dart';

import 'model.dart';

class ConnectedAppsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Model();
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBarContainer(title: 'Connected Apps'),
            ),
            body: _buildBody(context, model)));
  }

  Widget _buildBody(BuildContext context, Model model) => Container(
        child: ListView(
          children: model.menuItems
              .map((item) => ListTile(
                    leading: Image.network(item.logoUrl),
                    title: Text(item.title),
                    onTap: () => Navigator.of(context).pushNamed(item.route),
                  ))
              .toList(),
        ),
      );
}
