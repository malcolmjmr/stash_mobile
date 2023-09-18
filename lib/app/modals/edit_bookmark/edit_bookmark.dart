import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_header.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
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
            SliverAppBar(
              title: ModalHeader(titleText: 'Edit Bookmark'), 
              backgroundColor: HexColor.fromHex('111111'),
              floating: true, 
              automaticallyImplyLeading: false,
              leadingWidth: 0,
              leading: null,
            ),
            SliverToBoxAdapter(
              child: _buildDescription(),
            ),
            SliverToBoxAdapter(
              child: _buildSpaces(),
            ),
            SliverToBoxAdapter(
              child: _buildTags(),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: HexColor.fromHex('222222')
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              _buildTitle(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Container(width: double.infinity, height: 2, color: HexColor.fromHex('444444'),),
              ),
              _buildLinkInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkInfo() {
    return Container(
      child: Row(

        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.link),
          ),
          Expanded(child: Text(model.resource!.url!))
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: model.resource != null
            ? FavIcon(resource: model.resource!, size: 27,)
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
    );
  }

  Widget _buildSpaces() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: model.spaces.isNotEmpty
        ? SectionHeader(
            title: 'Spaces',
            onAddClicked: () => null,
            onToggleCollapse: () => null,
            isCollapsed: false,
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: HexColor.fromHex('222222')
            ),
            child: model.spaces.isEmpty
              ? Container(
                height: 40,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.add),
                    ),
                    Text('Add Space',
                      style: TextStyle(
                        fontSize: 18
                      ),
                    )
                  ],
                ),
              )
              : Column(
                children: model.spaces.map(
                  (space) => Container()
              ).toList(),
            ),
          )
        );
  }

    Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          if (model.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
              child: SectionHeader(
                title: 'Tags',
                onAddClicked: () => null,
                onToggleCollapse: () => null,
                isCollapsed: model.showTags,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: HexColor.fromHex('222222')
              ),
              child: model.tags.isEmpty
                ? GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.tagSelection, arguments: model.resource),
                  child: Container(
                    height: 40,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.add),
                        ),
                        Text('Add Tag',
                          style: TextStyle(
                            fontSize: 18
                          ),
                        )
                      ],
                    ),
                  ),
                )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: model.tags.map(
                        (tag) => TagChip(
                          tag: Tag(name: tag,), 
                          //isSelected: true,
                        )
                    ).toList(),
                  ),
                ),
            ),
        ],
      )
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
              fontSize: 22,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(isCollapsed 
              ? Icons.keyboard_arrow_down 
              : Icons.keyboard_arrow_right
            ),
          ),
          Expanded(child: Container(),),
          Icon(Icons.add)
        ],
      ),
    );
  }
}