import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class FindInPage extends StatelessWidget {
  const FindInPage({Key? key, required this.model}) : super(key: key);

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: HexColor.fromHex('333333')
              ),
              child: TextField(
                onChanged: (value) => model.currentTab.model.controller.findAllAsync(find: value),
              ),
            ),
            GestureDetector(
              onTap: () => model.currentTab.model.controller.findNext(forward: true),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Symbols.arrow_downward),
              ),
            ),
            GestureDetector(
              onTap: () => model.currentTab.model.controller.findNext(forward: false),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Symbols.arrow_upward),
              ),
            )
          ],
        ),
      ),
    );
  }
}