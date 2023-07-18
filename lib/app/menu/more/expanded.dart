import 'package:flutter/material.dart';

import 'model.dart';

class ExpandedMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = ViewModel(context);
    return Material(
      color: Theme.of(context).primaryColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: 50, maxHeight: MediaQuery.of(context).size.height * .5),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = model.items[index];
            return GestureDetector(
              onTap: () {
                item.onTap?.call(context);
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: item.widget != null
                        ? item.widget!
                        : item.icon != null
                            ? Icon(item.icon)
                            : Container(),
                  ),
                  Expanded(child: Text(item.name)),
                ],
              ),
            );
          },
          itemCount: model.items.length,
        ),
      ),
    );
  }
}
