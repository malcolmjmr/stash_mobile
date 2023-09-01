import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_header.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

class EditBookmarkModal extends StatefulWidget {
  const EditBookmarkModal({Key? key, this.space, this.resource, required this.workspaceViewModel}) : super(key: key);

  final WorkspaceViewModel workspaceViewModel;
  final Workspace? space; 
  final Resource? resource;

  @override
  State<EditBookmarkModal> createState() => _EditBookmarkModalState();
}

class _EditBookmarkModalState extends State<EditBookmarkModal> {
  /*
    model
    sections
    - search
    - create new
    - spaces in the current workspace
    - recent 
  */

  late EditBookmarkModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = EditBookmarkModel(context, setState,
      resource: widget.resource,
      workspaceModel: widget.workspaceViewModel,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: HexColor.fromHex('111111'),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(title: ModalHeader(titleText: 'Edit Bookmark'), floating: true,),
            SliverAppBar(title: _buildTitle(), pinned: true),
            SliverToBoxAdapter(
              child: _buildSpaces(),
            ),
            if (model.showTags) 
            SliverToBoxAdapter(
              child: _buildTags(),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: HexColor.fromHex('222222'),
          borderRadius: BorderRadius.circular(8)

        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: model.resource != null
              ? FavIcon(resource: model.resource!)
              : Icon(Icons.folder_rounded, 
                  color: HexColor.fromHex(colorMap[model.space!.color ?? 'grey']!)
                ),
            ),
            Expanded(
              child: model.canEditTitle
              ? TextField(
                  controller: model.titleController,
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  model.resource?.title ?? model.space!.title!,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpaces() {
    return Container(
      child: Column(
        children: [
          SectionHeader(
            title: 'Spaces',
            onAddClicked: () => null,
            onToggleCollapse: () => null,
            isCollapsed: false,
          ),
          Container(
            child: Column(
              children: model.spaces.map(
                (space) => Container()
            ).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTags() {
    return Container(
      child: Column(
        children: [
          SectionHeader(
            title: 'Spaces',
            onAddClicked: () => Navigator.pushNamed(context, AppRoutes.tagSelection, arguments: model.resource),
            onToggleCollapse: () => null,
            isCollapsed: false,
          ),
          Container(
            child: Column(
              children: model.spaces.map(
                (space) => Container()
            ).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Function() onAddClicked;
  final Function() onToggleCollapse;
  final bool isCollapsed;
  const SectionHeader({
    Key? key, 
    required this.title,
    required this.onAddClicked,
    required this.onToggleCollapse,
    required this.isCollapsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          Icon(Icons.add),
          Expanded(child: Container(),),
          Icon(isCollapsed 
            ? Icons.keyboard_arrow_down 
            : Icons.keyboard_arrow_right
          ),
        ],
      ),
    );
  }
}