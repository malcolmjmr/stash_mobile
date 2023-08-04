import 'package:flutter/material.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';

class WorkspaceListItem extends StatelessWidget {
  const WorkspaceListItem({Key? key, required this.workspace, required this.onTap}) : super(key: key);

  final Workspace workspace; 
  final onTap;
  
  @override
  Widget build(BuildContext context) {
  
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!),
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: _buildTitle()),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: const Icon(Icons.arrow_forward_ios, 
                  size: 16.0, 
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(workspace.title ?? 'Untitled', 
      style: TextStyle(
        fontSize: 20,
        overflow: TextOverflow.ellipsis,
        color: Colors.black,
      ),
    );
  }
}