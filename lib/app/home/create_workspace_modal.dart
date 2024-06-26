import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/color_selector.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';

class CreateWorkspaceModal extends StatefulWidget {

  final Workspace? workspace;
  final String? initialTitle;
  final String? initialColor;
  final Function(Workspace workspace) onDone;
  const CreateWorkspaceModal({Key? key, 
  required this.onDone, 
  this.workspace, 
  this.initialTitle,
  this.initialColor,
  }) : super(key: key);


  @override
  State<CreateWorkspaceModal> createState() => _CreateWorkspaceModalState();
}

class _CreateWorkspaceModalState extends State<CreateWorkspaceModal> {

  late Workspace workspace;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.workspace != null) {
      workspace = widget.workspace!;
    } else {
      workspace = Workspace();
    }

    if (widget.initialColor != null) {
      workspace.color = widget.initialColor;
    }

    if (widget.initialTitle != null) {
      workspace.title = widget.initialTitle;
    }

    if (workspace.title != null) {
      textController.text = workspace.title!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
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
            _buildTitleField(),
            
            ColorSelector(
              workspace: workspace, 
              onColorSelected: (color) {
                setState(() {
                  workspace.color = color;
                });
              }
            ),
            _buildGoalField(),

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
            Text('Create New Space',
              style: TextStyle(
                fontSize: 20, 
                //color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!)
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

  Widget _buildTitleField() {

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
                    hintText: 'Enter space name',
                    border: InputBorder.none,
                    
                  ),
                  onChanged: (value) => setState(() {
                    workspace.goal = textController.text;
                  }),
                  onSubmitted: (value) => setState(() {
                    workspace.goal = textController.text;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: HexColor.fromHex('4444444')
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            autofocus: true,
            maxLines: 1000,
            minLines: 4,
            decoration: InputDecoration(
              hintText: 'Why are you creating this space?',
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
      ),
    );
  }

  
}