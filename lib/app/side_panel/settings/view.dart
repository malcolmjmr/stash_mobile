import 'package:flutter/material.dart';
import 'package:stashmobile/app/side_panel/settings/model.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = SettingsViewModel();
    return _buildMenu(context, model);
  }

  Widget _buildMenu(BuildContext context, SettingsViewModel model) => Container(
        child: ListView(
          children: model.menuItems
              .map((item) => ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: () => Navigator.of(context).pushNamed(item.route),
                  ))
              .toList(),
        ),
      );
}
