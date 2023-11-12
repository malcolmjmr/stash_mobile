import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class TextSelectionMenu extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const TextSelectionMenu({Key? key, 

    required this.workspaceModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            TextSelectionOption(
              icon: Symbols.travel_explore, 
              text: 'Search',
              onTap: () => workspaceModel.searchSelectedText(),
            ),
            if (workspaceModel.selectedText!.split(' ').length < 3)
            TextSelectionOption(
              icon: Symbols.style, 
              text: 'Tag',
              onTap: () => workspaceModel.tagTabWithSelectedText(),
            ),
            if (workspaceModel.selectedText!.contains('.') || workspaceModel.selectedText!.contains('?') || workspaceModel.selectedText!.length > 20)
            TextSelectionOption(
              icon: Symbols.ink_highlighter, 
              text: 'Highlight',
              onTap: () => workspaceModel.currentTab.model.createHighlight(),
            )
          ],
        ),
      ),
    );
  }
}

class TextSelectionOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? onTap;

  const TextSelectionOption({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            //padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: HexColor.fromHex('222222'),
            ),
            child: Center(
              heightFactor: 1,
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(icon, 
                        //color: Colors.amberAccent,
                      ),
                    ),
                    Text(text,
                      style: TextStyle(
                        //color: Colors.amberAccent,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}