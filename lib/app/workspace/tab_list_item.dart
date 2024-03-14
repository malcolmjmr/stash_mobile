

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

/*

*/



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

    bool isSelected = model.selectedResources.firstWhereOrNull((resourceId) => resourceId == resource.id) != null;

    List<SlidableAction> leftActions = [];

    return Stack(
      children: [

        SectionListItemContainer(
          isFirstListItem: isFirstListItem,
          isLastListItem: isLastListItem,
          isHighlighted: isLastActiveTab || isSelected,
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
                    onPressed: (context) => model.saveTab(resource)
                  ),
                ],
                motion: const ScrollMotion(),
                dismissible: DismissiblePane(onDismissed: () => model.stashTab(resource)),
                openThreshold: 0.5,
              ),
              endActionPane: ActionPane(
                children: [
                  // SlidableAction(
                  //   icon: Icons.ios_share,
                  //   backgroundColor: Colors.blue,
                  //   onPressed: (context) => showCupertinoModalBottomSheet(
                  //     context: context, 
                  //     builder: (context) {
                  //       return Container();//ShareModal()
                  //     }
                  //   )
                  // ),
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
                    _buildIcon(isSelected),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(resource.title ?? '', 
                            maxLines: 1,
                            style: TextStyle(
                              //color: isLastActiveTab ? Colors.amber : Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              fontSize: 16,  
                              overflow: TextOverflow.ellipsis),
                            ),
                          Row(
                            children: [
                              Text(Uri.parse(resource.url ?? '').host.replaceAll('www.', '') ?? '', 
                                maxLines: 1,
                                style: TextStyle(
                                  //color: isLastActiveTab ? Colors.amber : Colors.white,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                  fontSize: 14,  
                                  overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ),
                    
                  ],
                ),
              ),
            ),
          ),
        ),
        if (resource.isSaved == true) 
        Positioned(
          child: Icon(Icons.star_rounded, 
            size: 28, 
            color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!)
          ),
          bottom: 5,
          left: 25
        ),
      ],
    );
  }

  Widget _buildIcon(bool isSelected) {
    
    return GestureDetector(
      onTap: () => model.toggleResourceSelection(resource),
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Container(
          height: 35,
          width: 35,
          child: isSelected 
            ? Icon(Symbols.select_check_box_rounded, size: 35, fill: 1)
            : resource.favIconUrl != null 
              ? Image.network(resource.favIconUrl ?? '',
                //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
              )
              : Icon(Icons.public, size: 35,)
          ),
      ),
    );
  }
}
