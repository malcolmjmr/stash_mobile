import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/editable_tag.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_header.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
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
              title: ModalHeader(titleText: 'Edit Bookmark',), 
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
            // SliverList.builder(
            //   itemCount: model.spaces.length + 1,
            //   itemBuilder: (context, index) {
            //     if (index == 0) {

            //     } else {
            //       final space = model.spaces[index];
            //       return 
            //     }
                
            //   }
            // ),
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
                onSubmitted: (value) => model.updateTitle(),
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
      child: Column(
          children: [
            SectionHeader(
              title: 'Spaces',
              //onAddClicked: () => null,
              //onToggleCollapse: () => null,
              //isCollapsed: false,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: HexColor.fromHex('222222')
              ),
              child: Column(
                children: [
                  _buildAddSpaceInput(
                    onChanged: (value) => null, 
                    onSubmitted: (value) => null,
                  ),
                  ...model.spaces.map(
                    (space) => GestureDetector(
                      onTap: () => model.removeSpace(space),
                      child: Container(

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: WorkspaceListItem(
                                onTap: () => null,
                                workspace: space,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: HexColor.fromHex('444444'),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(Icons.remove),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ).toList(),
                ]
              ),
            )
          ],
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
                  //trailing: Text('Edit'),
                  //onAddClicked: () => null,
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
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        _buildAddTagChip(
                          onChanged: model.onTagSearchChange,
                          onSubmitted: model.addTag, 
                        ), 
                        // need to 
                        ...model.tags.map(
                        (tag) => EditableTagChip(
                          tag: Tag(name: tag,), 
                          isSelected: true,
                          onTap: () => model.removeTag(tag),
                        )
                    ).toList()],
                  ),
                ),
              ),
          ],
        )
      );
    }

    Widget _buildEditButton({Function()? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Text('Edit',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      );
    }

    Widget _buildAddSpaceInput({
      required Function(String value) onChanged, 
      required Function(String value) onSubmitted
    }) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 15),
            child: Icon(Symbols.add_rounded, weight: 800,),
          ),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: TextStyle(
                fontSize: 20
              ),
              decoration: InputDecoration(
                hintText: 'Add Space',
                hintStyle: TextStyle(
                  fontSize: 20,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildAddTagChip({
      required Function(String value) onChanged, 
      required Function(String value) onSubmitted
    }) {
      return Container(
        decoration: BoxDecoration(
          color: HexColor.fromHex('444444'),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(Symbols.add_rounded, weight: 800,),
              ),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  style: TextStyle(
                    fontSize: 16
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add Tag',
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
}

