import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/move_to_folder/move_to_folder_model.dart';
import 'package:stashmobile/app/workspace/folder_list_item.dart';

import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class MoveToFolderModal extends StatefulWidget {
  const MoveToFolderModal({Key? key, this.folder, this.resource, required this.onFolderSelected, this.workspaceViewModel}) : super(key: key);

  final WorkspaceViewModel? workspaceViewModel;
  final Workspace? folder; 
  final Resource? resource;

  final Function(Workspace folder) onFolderSelected;

  @override
  State<MoveToFolderModal> createState() => _MoveToFolderModalState();
}

class _MoveToFolderModalState extends State<MoveToFolderModal> {
  /*
    model
    sections
    - search
    - create new
    - folders in the current workspace
    - recent 
  */

  late MoveToFolderModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = MoveToFolderModel(context, setState,
      workspaceModel: widget.workspaceViewModel,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: HexColor.fromHex('111111'),
        child: Column(
          children: [
            _buildHeader(context),
            if (model.isLoaded)
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(padding: EdgeInsets.symmetric(vertical: 10)),
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: true,
                    leadingWidth: 0,
                    //collapsedHeight: 50,
                    //expandedHeight: 50,
                    backgroundColor: HexColor.fromHex('111111'),
                    title: _buildSearch(),
                  ),
                  SliverPadding(padding: EdgeInsets.symmetric(vertical: 6)),
                  SliverList.builder(
                    itemCount: model.visibleRecentFolders.length,
                    itemBuilder: (context, index) {
                      final folder = model.visibleRecentFolders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FolderListItem(
                          workspace: folder, 
                          onTap: () => model.moveToFolder(
                            context,
                            targetFolder: widget.folder,
                            targetResource: widget.resource,
                            destinationFolder: folder,
                            callback: widget.onFolderSelected
                          ), 
                          isFirstListItem: index == 0,
                          isLastListItem: index == model.visibleRecentFolders.length,
                        ),
                      );
                    }
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: HexColor.fromHex('222222'),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text('Cancel',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Text('Select Folder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 50,), 
            ],
          ),
          _buildItemDetails(context),
        ],
      ),
    );
  }

  Widget _buildItemDetails(BuildContext context) {
    return widget.folder != null 
      ? _buildFolderDetails(context)
      : _buildResourceDetails(context);
  }

  Widget _buildFolderDetails(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 10),
            child: Container(
              child: Icon(Icons.folder, size: 40)
            )
          ),
          Expanded(
            child: Text(widget.folder!.title ?? '', 
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
                fontSize: 30,  
                overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResourceDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Container(
              height: 35,
              width: 35,
              child: widget.resource!.favIconUrl != null 
                ? Image.network(widget.resource!.favIconUrl ?? '',
                  //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                  errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
                )
                : Icon(Icons.public, size: 35,)
              ),
          ),
          Expanded(
            child: Text(widget.resource!.title ?? '', 
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
                fontSize: 16,  
                overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return SearchField(
      onChanged: model.updateSearchResults,
      onSubmitted: model.updateSearchResults,
    );
  }

}