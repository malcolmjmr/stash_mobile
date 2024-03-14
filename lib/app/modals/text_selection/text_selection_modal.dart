import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class TextSelectionMenu extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const TextSelectionMenu({Key? key, 
    required this.workspaceModel,

  }) : super(key: key);

  /*
    Search
    Copy (onLongPress: copy to note)
    Tag
    Chat ()
    Highlight
  */

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(workspaceModel.workspaceHexColor);
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
              onLongPress: () => workspaceModel.searchSelectedText(openInNewTab: false),
              onTap: () => workspaceModel.searchSelectedText(),
              color: color,
            ),
            TextSelectionOption(
              icon: Symbols.content_copy_rounded, 
              text: 'Copy',
              onLongPress: () => workspaceModel.copySelectionToLastLocation(),
              onTap: () => workspaceModel.openCopyModal(context),
              color: color,
            ),
            if (workspaceModel.selectedText!.split(' ').length < 3)
            TextSelectionOption(
              icon: Symbols.style, 
              text: 'Tag',
              onTap: () => workspaceModel.tagTabWithSelectedText(),
              color: color,
            ),
            TextSelectionOption(
              icon: Symbols.forum_rounded, 
              text: 'Chat',
              onLongPress: () => workspaceModel.createChat(withLastPrompt: true),
              onTap: () => workspaceModel.createChat(),
              color: color,
            ),
            if (workspaceModel.selectedText!.contains('.') || workspaceModel.selectedText!.contains('?') || workspaceModel.selectedText!.length > 20)
            TextSelectionOption(
              icon: Symbols.ink_highlighter, 
              text: 'Highlight',
              onTap: () => workspaceModel.currentTab.model.createHighlight(),
              color: color,
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
  final Function()? onLongPress;
  final Color? color;
  final bool showText;

  const TextSelectionOption({
    Key? key,
    required this.icon,
    required this.text,
    this.onLongPress,
    this.onTap,
    this.color,
    this.showText = false,
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
              color: color ?? HexColor.fromHex('222222'),
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
                      padding: EdgeInsets.only(right: showText ? 5.0 : 0.0),
                      child: Icon(icon, 
                        //color: Colors.amberAccent,
                      ),
                    ),
                    if (showText)
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