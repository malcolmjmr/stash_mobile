import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/create_new_space_list_item.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/workspace/space_list_item.dart';

import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

import 'move_tabs_model.dart';

class MoveToSpaceModal extends StatefulWidget {
  const MoveToSpaceModal({Key? key, 
    this.resource, 
    required this.onSpaceSelected, 
    required this.workspaceViewModel
  }) : super(key: key);

  final WorkspaceViewModel workspaceViewModel;
  final Resource? resource;

  final Function(Workspace folder) onSpaceSelected;

  @override
  State<MoveToSpaceModal> createState() => _MoveToSpaceModalState();
}

class _MoveToSpaceModalState extends State<MoveToSpaceModal> {
  /*
    model
    sections
    - search
    - create new
    - folders in the current workspace
    - recent 
  */

  late MoveToSpaceModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = MoveToSpaceModel(context, setState,
      workspaceModel: widget.workspaceViewModel,
      selectedResource: widget.resource,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: HexColor.fromHex('111111'),
        child: !model.isLoaded 
          ? Container()
          : Column(
          children: [
            _buildHeader(context),
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
                  if (model.searchText.isEmpty || model.visibleSpaces.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CreateNewSpaceListItem(
                        title: model.searchText,
                        onSpaceCreated: (space) => model.moveToSpace(context, destinationSpace: space),
                        
                      ),
                    )
                  ),
                  SliverList.builder(
                    itemCount: model.visibleSpaces.length,
                    itemBuilder: (context, index) {
                      final space = model.visibleSpaces[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SpaceListItem(
                          workspace: space, 
                          onTap: () => model.moveToSpace(
                            context,
                            destinationSpace: space,
                            callback: widget.onSpaceSelected
                          ), 
                          isLastListItem: index == model.visibleSpaces.length - 1,
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
      padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
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
              Text('Move to Space',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 50,), 
            ],
          ),
          _buildResourceDetails(context)
        ],
      ),
    );
  }

  Widget _buildResourceDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Container(
              height: 35,
              width: 35,
              child: model.resources.first.favIconUrl != null 
                ? Image.network(model.resources.first.favIconUrl ?? '',
                  //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                  errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
                )
                : Icon(Icons.public, size: 35,)
              ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.resources.first.title ?? '', 
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontSize: 16,  
                    overflow: TextOverflow.ellipsis),
                  ),
                Text('${model.resources.length} resource${model.resources.length > 1 ? "s" : ""} selected')
              ],
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