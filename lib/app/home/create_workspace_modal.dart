import 'package:flutter/material.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';

class CreateWorkspaceModal extends StatefulWidget {

  final Function(Workspace workspace) onDone;
  const CreateWorkspaceModal({Key? key, required this.onDone}) : super(key: key);


  @override
  State<CreateWorkspaceModal> createState() => _CreateWorkspaceModalState();
}

class _CreateWorkspaceModalState extends State<CreateWorkspaceModal> {

  Workspace workspace = Workspace();
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 500,
        width: double.infinity,
        decoration: BoxDecoration(
          color: HexColor.fromHex('222222'),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5.0), 
            topRight: Radius.circular(5.0)
          )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(),
            _buildInputField(),
            _buildColorSelectionField(),
          ])
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: 50,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('Cancel',
                style: TextStyle(
                  color: Colors.amber
                ),
              ),
            ),
            Text(workspace.title != null && workspace.title!.isNotEmpty ? workspace.title! : 'New Space',
              style: TextStyle(
                fontSize: 20, 
                color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!)
              ),
            ),
            GestureDetector(
              onTap: () => widget.onDone(workspace),
              child: Text('Done',
                style: TextStyle(
                  color: Colors.amber, 
                  fontWeight: FontWeight.w500
                ),
              ),
            )
          ]
        ),
      ),
    );
  }

  Widget _buildInputField() {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: HexColor.fromHex('4444444')
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'New Space',
                    border: InputBorder.none,
                    
                  ),
                  onChanged: (value) => setState(() {
                    workspace.title = textController.text;
                  }),
                  onSubmitted: (value) => setState(() {
                    workspace.title = textController.text;
                  }),
                ),
              ),
              if (textController.text.length > 0) 
              GestureDetector(
                onTap: () => setState(() {
                  workspace.title = null;
                  textController.clear();
                }),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: HexColor.fromHex('555555'),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(Icons.clear_outlined, 
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelectionField() {
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          //color: HexColor.fromHex('444444'),
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colorMap.entries.map((e) {
            final isSelectedColor = workspace.color == e.key || (workspace.color == null && e.key == 'grey');
            final circleSize = isSelectedColor ? 35.0 : 30.0;
            return GestureDetector(
              onTap: () => setState(() {
                workspace.color = e.key;
              }),
              child: Container(
                height: circleSize,
                width: circleSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  // border: e.key == 'grey'
                  //   ? Border.all(
                  //       color: Colors.white, 
                  //       width: 2.0
                  //     ) : null,
                  color: HexColor.fromHex(e.value)
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}