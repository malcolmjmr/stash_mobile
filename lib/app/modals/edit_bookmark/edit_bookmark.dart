import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/common_widgets/editable_tag.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_header.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/modals/tag_selection/tag_selection.dart';
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
              title: ModalHeader(
                titleText: 'Edit Bookmark',
                onDone: model.onDone,
              ), 
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
              child: _buildRating(),
            ),
            SliverToBoxAdapter(
              child: _buildSpaces(),
            ),
            SliverToBoxAdapter(
              child: _buildTags(),
            ),
            SliverToBoxAdapter(
              child: _buildImages(),
            ),
            SliverToBoxAdapter(
              child: _buildHighlights(),
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

              if (model.resource?.url != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Container(width: double.infinity, height: 2, color: HexColor.fromHex('444444'),),
              ),
              if (model.resource?.url != null)
              _buildLinkInfo(),
             
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkInfo() {
    return Container(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.link),
          ),
          Expanded(child: 
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [Center(child: Text(model.resource!.url!))]
            )
          )
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
            ? model.resource!.chat != null
              ? Icon(Symbols.forum_rounded, size: 28,)
              : model.resource!.note != null 
                ? Icon(Symbols.edit_document_rounded, size: 28,)
                : FavIcon(resource: model.resource!, size: 27,)
            : Icon(Icons.folder_rounded, 
                color: HexColor.fromHex(colorMap[model.space!.color ?? 'grey']!)
              ),
          ),
          Expanded(
            child: model.canEditTitle
            ? TextField(
                controller: model.titleController,
                onChanged: (value) => model.updateTitle(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
      child: Column(
          children: [
            SectionHeader(
              title: 'Spaces',
              actions: [
                _buildAddButton(),
              ],
              //onToggleCollapse: () => null,
              //isCollapsed: false,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: HexColor.fromHex('222222')
              ),
              child: Column(
                children: [
                  // _buildAddSpaceInput(
                  //   onChanged: (value) => null, 
                  //   onSubmitted: (value) => null,
                  // ),
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
                                isFirstListItem: true,
                                isLastListItem: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  //color: HexColor.fromHex('444444'),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
        child: Column(
          children: [
            
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 0, right: 0),
                child: SectionHeader(
                  title: 'Tags',
                  //trailing: Text('Edit'),
                  //onAddClicked: () => null,
                  actions: [
                    _buildAddButton(onTap: () {
                      Navigator.push(
                        context, 
                        PageTransition<dynamic>(
                          type: PageTransitionType.rightToLeft,
                          alignment: Alignment.topCenter,
                          curve: Curves.easeInExpo,
                          child: TagSelectionModal(
                            resource: model.resource!,
                            onDone: () => null,
                          ),
                          fullscreenDialog: true,
                        )
                      );
                    }),
                  ],
                  onToggleCollapse: () => null,
                  isCollapsed: model.tags.isNotEmpty ? model.showTags : null,
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
                  child: model.tags.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Container(
                      child: Text(
                        'No tags have been added',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
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

    Widget _buildAddButton({Function()? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('222222'),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Icon(Symbols.add_rounded, 
              weight: 1200, 
              size: 20,
              //color: Colors.amber,
            ),
          ),
        ),
      );
    }

    Widget _buildRating() {
      final color = HexColor.fromHex(colorMap[model.workspaceModel.workspace.color ?? 'grey']!);
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
        child: Column(
          children: [
            SectionHeader(
              title: 'Rating',
              
              //onToggleCollapse: () => null,
              //isCollapsed: false,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                child: Row(
                  children: [1, 2, 3, 4, 5, 6, 7].map((rating) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => model.setRating(rating),
                        child: Container(
                          decoration: BoxDecoration(
                              color: color.withOpacity((rating + 3)/10),
                              border: model.resource?.rating == rating
                              ?  Border.symmetric(vertical: BorderSide(color: Colors.black, width: 3))
                              : null
                            ),
                          height: 30,
                        ),
                      ),
                    );
                  }).toList(),
                )
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildHighlights() {
      return model.resource!.highlights.isNotEmpty 
      ? Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 15),
        child: Container(
          child: Column(
            children: [
              SectionHeader(title: 'Highlights'),
              Container(
                 decoration: BoxDecoration(
                  color: HexColor.fromHex('222222'),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: model.resource!.highlights.map((highlight)  {
                      return _buildHighlight(highlight);
                    }).toList(),
                  ),
                )
              )
            ],
          ),
        ),
      )
      : Container();
    }

    Widget _buildHighlight(Highlight highlight) {
      return Container(
        child: Text(highlight.text,
          style: TextStyle(
            fontSize: 16
          ),
        ),
      );
    }

  Widget _buildImages() {
    return model.resource!.images.isNotEmpty 
      ? Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 15),
        child: Container(
          child: Column(
            children: [
              SectionHeader(title: 'Images'),
              Container(
                 decoration: BoxDecoration(
                  color: HexColor.fromHex('222222'),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Container(
                     height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: PageView(
                      children: model.resource!.images.map((imageUrl)  {
                        return Image.network(imageUrl);
                      }).toList(),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      )
      : Container();
  }
}

