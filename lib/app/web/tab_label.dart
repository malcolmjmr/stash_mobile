

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/move_tabs/move_tabs_modal.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/read_aloud/play_button.dart';
import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/web/tab_menu.dart';
import 'package:stashmobile/app/web/vertical_tabs_modal.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/routing/app_router.dart';

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

    final isIncognito = model.tabs.firstWhereOrNull((t) => t.model.resource.id == resource.id)?.model.isIncognito == true;

    List<SlidableAction> leftActions = [];

  


    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      isHighlighted: isLastActiveTab,
      onTap: onTap,
      child: GestureDetector(
        onLongPress: () {
          model.currentTab.model.stopLoading();
        },
        onDoubleTap: () {
          model.createChat(getSummary: true);
        },
        child: Slidable(
          key: Key(resource.toString()),
          closeOnScroll: true,
          startActionPane: model.currentTab.model.viewType == null
            ? null
            : ActionPane(
            children: [
              if (model.workspace.title != null && !resource.isSaved)
              SlidableAction(
                icon: Symbols.move_to_inbox_rounded,
                foregroundColor: Colors.black,
                backgroundColor: HexColor.fromHex(model.workspaceHexColor),
                onPressed: (context) => model.stashTab(resource),
                padding: EdgeInsets.only(right: 1),
              ),

              SlidableAction(
                icon: Symbols.drive_file_move_rounded,
                foregroundColor: Colors.black,
                backgroundColor: HexColor.fromHex(model.workspaceHexColor),
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return MoveToSpaceModal(
                      resource: model.currentTab.model.resource,
                      workspaceViewModel: model,
                      onSpaceSelected: (folder) => model.removeTab(model.currentTab.model.resource)
                    );
                    //return MoveToFolderModa(resource: resource, onFolderSelected: (_) => null,);
                  }
                )
              ),
              // if (resource.isSaved)
              // SlidableAction(
              //   icon: Icons.bookmark_rounded,
              //   backgroundColor: Colors.green,
              //   onPressed: (context) => showCupertinoModalBottomSheet(
              //     context: context, 
              //     builder: (context) {
              //       return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
              //       //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
              //     }
              //   )
              // )
              // else 
              // SlidableAction(
              //   icon: Symbols.bookmark_add_rounded,
              //   backgroundColor: Colors.green,
              //   onPressed: (context) => model.workspace.title != null 
              //     ? model.saveTab(resource) 
              //     : showCupertinoModalBottomSheet(
              //         context: context, 
              //         builder: (context) {
              //           return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
              //           //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
              //         }
              //       )
              // ),
              // if (resource.isSaved)
              // SlidableAction(
              //   icon: Symbols.priority_high_rounded,
              //   backgroundColor: Colors.green.withOpacity(0.8),
              //   onPressed: (context) => showCupertinoModalBottomSheet(
              //     context: context, 
              //     builder: (context) {
              //       return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
              //       //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
              //     }
              //   )
              // ),
              // if (resource.isSaved)
              // SlidableAction(
              //   icon: Symbols.tag_rounded,
              //   backgroundColor: Colors.green.withOpacity(0.6),
              //   onPressed: (context) => showCupertinoModalBottomSheet(
              //     context: context, 
              //     builder: (context) {
              //       return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
              //       //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
              //     }
              //   )
              // ),
              // SlidableAction(
              //   icon: Symbols.ios_share_rounded,
              //   backgroundColor: Colors.blue.withOpacity(0.6),
              //   onPressed: (context) => model.onShare(resource),
              // ),
            ],
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () => model.workspace.title != null && !resource.isSaved
              ? model.stashTab(resource)
              : showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return EditBookmarkModal(resource: resource, workspaceViewModel: model,);
                    //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
                  }
                )
            ),
            openThreshold: 0.3,
            extentRatio: .4,
          ),
          endActionPane: model.currentTab.model.viewType == null
            ? null
            : ActionPane(
           children: [
            //   SlidableAction(
            //     icon: Icons.more_horiz,
            //     backgroundColor: Colors.blue,
            //     onPressed: (context) => showCupertinoModalBottomSheet(
            //       context: context, 
            //       builder: (context) {
            //         return TabMenu(
            //           resource: resource,
            //           workspaceModel: model,
            //         );
            //       }
            //     ),
            //   ),
              // SlidableAction(
              //   icon: Icons.ios_share,
              //   backgroundColor: Colors.blue,
              //   onPressed: (context) => model.onShare(resource),
              // ),
              // SlidableAction(
              //   icon: Icons.refresh,
              //   backgroundColor: Colors.orange,
              //   foregroundColor: Colors.white,
              //   onPressed: (context) => model.reloadTab(resource)
              // ),
              // SlidableAction(
              //   icon: Icons.add_box_rounded,
              //   backgroundColor: Colors.green,
              //   onPressed: (context) => model.createNewTab(),
              // ),
              // SlidableAction(
              //   icon: Symbols.new_window_rounded,
              //   backgroundColor: Colors.orange,
              //   foregroundColor: Colors.white,
              //   onPressed: (context) => Navigator.of(context).pushNamed(AppRoutes.workspace),
              // )

              SlidableAction(
                icon: Symbols.tab_move_rounded,
                foregroundColor: Colors.black,
                backgroundColor: HexColor.fromHex(model.workspaceHexColor),
                onPressed: (context) => model.moveTabToNewSpace(context)
              ),
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(
              onDismissed: () => model.moveTabToNewSpace(context)
              //closeOnCancel: true,
              //confirmDismiss: () => Future.value(false),
            ),
            
            openThreshold: 0.25,
            extentRatio: 0.40,
          ),
          child: model.tabs.firstWhere((t) => t.model.resource == resource).model.viewType == null
            ? _buildNewTabInputField()
            : Opacity(
            opacity: model.currentTab.model.isIncognito ? .5 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (model.readAloud.tabModel == model.currentTab.model)
                  PlayButton(
                    onTap: () => model.readAloud.isPlaying 
                      ? model.readAloud.pause() 
                      : model.readAloud.play(),
                    padding: EdgeInsets.only(left: 8.0),
                  )
                  else if (resource.url == null || (resource.favIconUrl != null && resource.favIconUrl!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 25,
                      width: 25,
                      child: model.currentTab.model.viewType == TabViewType.web 
                        ? resource.favIconUrl != null 
                          ? Image.network(resource.favIconUrl ?? '',
                            //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                            errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 25,),
                          )
                          : Icon(Icons.public, size: 25,)
                        : model.currentTab.model.viewType == TabViewType.chat
                          ? Icon(Symbols.forum_rounded)
                          : Icon(Symbols.edit_document_rounded, fill: 1,)
                      ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * ( isIncognito ? .65 : .74)),
                            child: Text(resource.title != null && resource.title!.isNotEmpty
                              ? resource.title!
                              : model.currentTab.model.viewType == TabViewType.web 
                                ? resource.url!
                                : model.currentTab.model.viewType == TabViewType.chat
                                  ? 'New Chat'
                                  : 'New Note'
                              , 
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                fontSize: 16,  
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                      
                          if (model.currentTab.model.isIncognito && !(model.workspace.isIncognito == true)) 
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.visibility_off),
                          ),
                          // if (resource.isSaved == true) 
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 5),
                          //   child: Icon(Icons.star_rounded, color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!)),
                          // ),
                        ],
                      ),
                    ),
                  ),
            
                  GestureDetector(
                    onTap: () => model.closeTab(resource),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(100),
                        //   color: HexColor.fromHex('333333')
                        // ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 8.0, right: 8.0),
                          child: Icon(Icons.close_rounded),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewTabInputField() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Opacity(
          opacity: .6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text('Enter search, website or need',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Icon(Symbols.mic,
                  fill: 1,
                
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
