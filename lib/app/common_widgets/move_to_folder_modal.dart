import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class MoveToFolderModal extends StatelessWidget {
  const MoveToFolderModal({Key? key, this.workspace, this.resource}) : super(key: key);

  final Workspace? workspace; 
  final Resource? resource;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: HexColor.fromHex('222222'),
        child: Column(
          children: [
            _buildHeader(context),
            _buildItemDetails(context, ),
            _buildSearch(context),
            _buildFolderList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: Text('Cancel',
                style: TextStyle(
                  color: Colors.amber,
                ),
              ),
            ),
          ),
          Text('Select Folder',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 30,), 
        ],
      ),
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    return Container();
  }

  Widget _buildSearch(BuildContext context) {
    return Container();
  }

  Widget _buildFolderList(BuildContext context) {
    return Container();
  }
}