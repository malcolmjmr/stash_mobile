import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/color_selector.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

/*

  Todo:
  - edit title
  - set color
  - add to favorites 
  - set as incognito
  - set parent spaces 
  - close
  - delete
  

*/

class WorkspaceMenu extends StatelessWidget {
  const WorkspaceMenu({Key? key, required this.model}) : super(key: key);
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: MediaQuery.of(context).size.width * .8,
          //height: MediaQuery.of(context).size.height * .5,
          decoration: BoxDecoration(
            color: HexColor.fromHex('222222'),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HexColor.fromHex('333333'), width: 3)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWorkspaceTitle(),
              _buildColorSelection(context),
              _buildMenuItems(),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildWorkspaceTitle() {
    final textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
      
        child: TextField(
          controller: TextEditingController(text: model.workspace.title),
          onChanged: (title) {
            model.setState(() {
              model.workspace.title = title;
            });
          },
          style: textStyle,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 8),
            border: InputBorder.none,
            hintStyle: textStyle.copyWith(
              color: Colors.white.withOpacity(0.8)
            )
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelection(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width * .8,
      child: Container(
        height: 50,
        child: ColorSelector(
          workspace: model.workspace,
          onColorSelected: (color) => null,
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      child: Column(
        children: [
          MenuItem(
            icon: Symbols.drive_file_move,
            title: 'Move',
          ),
          MenuItem(
            title: 'Close',
            icon: Symbols.close,
          ),
          MenuItem(
            icon: Symbols.archive,
            title: 'Archive',
          ),
          MenuItem(
            icon: Symbols.delete,
            title: 'Delete'
          )
        ],
      ),
    );
  }

}

class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key, 
    this.icon,
    required this.title,
  }) : super(key: key);

  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: HexColor.fromHex('222222')))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: Row(
          children: [
            if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            Text(title,
              style: TextStyle(
                fontSize: 24
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuDivider extends StatelessWidget {
  const MenuDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
    );
  }
}