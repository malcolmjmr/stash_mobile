

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/move_tabs/move_tabs_modal.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/web/tab_menu.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class OpenTabLabel extends StatelessWidget {
  const OpenTabLabel({Key? key, 
    required this.model, 
    required this.resource, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
    this.isLastActiveTab = false,
  }) : super(key: key);

  final WorkspaceViewModel model;
  final Resource resource;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;
  final bool isLastActiveTab;

  @override
  Widget build(BuildContext context) {

    List<SlidableAction> leftActions = [];

    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      onTap: onTap,
      child: GestureDetector(
        onLongPress: () {
          if (model.workspace.showWebView) return;
          HapticFeedback.mediumImpact();
          showCupertinoModalBottomSheet(
            context: context, 
            builder: (context) => Material(
              type: MaterialType.transparency,
              child: Container(
                height: MediaQuery.of(context).size.height * .66,
                width: MediaQuery.of(context).size.width * .66,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(resource.url!)),
                ),
              ),
            )
          );
        },
        child: Slidable(
          key: Key(resource.toString()),
          
          startActionPane: ActionPane(
            children: [
              if (model.workspace.title != null)
              SlidableAction(
                icon: Icons.move_to_inbox_outlined,
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
                onPressed: (context) => model.stashTab(resource),
              ),
              if (resource.isSaved)
              SlidableAction(
                icon: Icons.edit_outlined,
                backgroundColor: Colors.green,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
                    //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
                  }
                )
              )
              else 
              SlidableAction(
                icon: Icons.bookmark_add_outlined,
                backgroundColor: Colors.green,
                onPressed: (context) => model.workspace.title != null 
                  ? model.saveTab(resource) 
                  : showCupertinoModalBottomSheet(
                      context: context, 
                      builder: (context) {
                        return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
                        //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
                      }
                    )
              ),
              SlidableAction(
                icon: Symbols.move_item,
                backgroundColor: Colors.purple,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return MoveToSpaceModal(
                      resource: resource,
                      onSpaceSelected: (space) => model.removeTab(resource), 
                      workspaceViewModel: model
                    );
                  }
                ),
              ),
            ],
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () => model.workspace.title != null 
              ? model.stashTab(resource)
              : showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
                    //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
                  }
                )
            ),
            openThreshold: 0.5,
          ),
          endActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.more_horiz,
                backgroundColor: Colors.blue,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return TabMenu(
                      resource: resource,
                      workspaceModel: model,
                    );
                  }
                ),
              ),
              // SlidableAction(
              //   icon: Icons.ios_share,
              //   backgroundColor: Colors.blue,
              //   onPressed: (context) => model.onShare(resource),
              // ),
              SlidableAction(
                icon: Icons.refresh,
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                onPressed: (context) => model.reloadTab(resource)
              ),
              SlidableAction(
                icon: Icons.add,
                backgroundColor: Colors.green,
                onPressed: (context) => model.createNewTab(),
              )
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () => model.createNewTab()),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    height: 25,
                    width: 25,
                    child: resource.favIconUrl != null 
                      ? Image.network(resource.favIconUrl ?? '',
                        //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                        errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 25,),
                      )
                      : Icon(Icons.public, size: 25,)
                    ),
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (resource.isSaved == true ? .65 : .75)),
                        child: Text(resource.title ?? '', 
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isLastActiveTab ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            fontSize: 16,  
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ),
                      if (resource.isSaved == true) 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.star_rounded, color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!)),
                      ),
                    ],
                  ),
                ),
                
                // GestureDetector(
                //   onTap: () => showCupertinoModalBottomSheet(
                //     context: context, 
                //     builder: (context) {
                //       return TabMenu(
                //         resource: resource,
                //         workspaceModel: model,
                //       );
                //     }
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 3.0),
                //     child: Icon(Icons.more_vert),
                //   ),
                // ),
                //Expanded(child: Container(),),
                GestureDetector(
                  onTap: () => model.closeTab(resource),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: HexColor.fromHex('333333')
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(Icons.close),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
