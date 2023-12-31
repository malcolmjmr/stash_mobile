

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/web/tab_preview_modal.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class TabListItem extends StatelessWidget {
  const TabListItem({Key? key, 
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
      isHighlighted: isLastActiveTab,
      onTap: onTap,
      child: GestureDetector(
        onLongPress: () {
          if (model.workspace.showWebView) return;
          HapticFeedback.mediumImpact();
          showCupertinoModalBottomSheet(
            context: context, 
            builder: (context) => TabPreviewModal(resource: resource,)
          );
        },
        child: Slidable(
          key: Key(resource.toString()),
          startActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.move_to_inbox_outlined,
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
                onPressed: (context) => model.stashTab(resource),
              ),
              SlidableAction(
                icon: Icons.bookmark_add_outlined,
                backgroundColor: Colors.green,
                onPressed: (context) => model.saveTab(resource),
              ),
            ],
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () => model.stashTab(resource)),
            openThreshold: 0.5,
          ),
          endActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.ios_share,
                backgroundColor: Colors.blue,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return Container();//ShareModal()
                  }
                )
              ),
              SlidableAction(
                icon: Icons.folder_outlined,
                backgroundColor: Colors.purple,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return EditBookmarkModal(workspaceViewModel: model, resource: resource);
                    //return MoveToFolderModal(resource: resource, onFolderSelected: (folder) => null);
                  }
                )
              ),
              SlidableAction(
                icon: Icons.close,
                backgroundColor: Colors.redAccent,
                onPressed: (context) => model.removeTab(resource),
              )
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () => model.removeTab(resource)),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Container(
                    height: 35,
                    width: 35,
                    child: resource.favIconUrl != null 
                      ? Image.network(resource.favIconUrl ?? '',
                        //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                        errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
                      )
                      : Icon(Icons.public, size: 35,)
                    ),
                ),
                Expanded(
                  child: Text(resource.title ?? '', 
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      fontSize: 16,  
                      overflow: TextOverflow.ellipsis),
                    ),
                  ),
                if (resource.isSaved == true) 
                Icon(Icons.star_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
