/*

  type (tab, que)

*/




import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/web/tab_preview_modal.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';

/*

*/



class ResourceListItem extends StatelessWidget {
  const ResourceListItem({Key? key, 
    required this.model, 
    required this.resource, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
    this.isLastActiveTab = false,
    this.showHighlights = false,
    this.showImages = false,
  }) : super(key: key);

  final WorkspaceViewModel model;
  final Resource resource;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;
  final bool isLastActiveTab;
  final bool showHighlights;
  final bool showImages;

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
                icon: Icons.edit_outlined,
                backgroundColor: Colors.purple,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return EditBookmarkModal(
                      workspaceViewModel: model,
                      resource: resource,
                    );
                    //return MoveToFolderModal(resource: resource , onFolderSelected: (_) => null,);
                  }
                )
              ),
              SlidableAction(
                icon: Icons.delete_outline,
                backgroundColor: Colors.redAccent,
                onPressed: (context) => model.deleteResource(resource),
              )
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () => model.deleteResource(resource)),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildTitle(context),
                if (resource.images.isNotEmpty && showImages)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildImages(context),
                ),
                if (resource.highlights.isNotEmpty && showHighlights)
                _buildHighlights(context),
                _buildTags(context),
              ],
            )      
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      child: Column(
      //mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resource.favIconUrl != null && resource.favIconUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 5.0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resource.title ?? '', 
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 16,  
                        overflow: TextOverflow.ellipsis),
                      ),
                    if (resource.url != null)
                    Row(
                      children: [
                        Text(Uri.parse(resource.url!).host.replaceAll('www.', '') ?? '', 
                          maxLines: 1,
                          style: TextStyle(
                            color: isLastActiveTab ? Colors.amber : Colors.white,
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

      ],
        ),
    );

  }

  Widget _buildHighlights(BuildContext context) {
    final selectedTagNames = model.selectedTags.map((t) => t.name).toList();
    final highlights = resource.highlights
      .where((h) {
        final text = h.text.toLowerCase();
        return selectedTagNames.every((t) => text.contains(t.substring(0, min(t.length, 4)).toLowerCase()));
      });
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: highlights.map((h) {
              return GestureDetector(
                onTap: () => model.openResource(context, resource, highlightId: h.id),
                onDoubleTap: () => model.searchSelectedText(text: h.text, openInNewTab: true),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    child: Text(h.text,
                      maxLines: 50,
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              );
            }).toList()
        )
      ),
    );
  }

  Widget _buildImages(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: PageView.builder(
        //scrollDirection: Axis.,
        itemCount: resource.images.length,
        padEnds: true,
        itemBuilder: (context, index) {
          final imageUrl = resource.images[index];
          return Image.network(imageUrl);
        }
      ),
    );
  }

  Widget _buildTags(BuildContext context) {

    final selectedTagNames = model.selectedTags.map((t) => t.name).toList();
    final tags = resource.tags.where((tag) => !selectedTagNames.contains(tag.toLowerCase())).toList();
    return tags.isEmpty 
      ? Container() 
      : Padding(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Container(
          height: 35,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tags.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2),
                  );
                } else {
                  final tag = Tag(name: tags[index - 1]);
                  return Padding(
                    padding: const EdgeInsets.only(top: 5, right: 8.0),
                    child: TagChip(
                      tag: tag, 
                      onTap: () => model.toggleTagSelection(tag),
                      onDoubleTap: () => model.searchSelectedTags(tag: tag),
                      onLongPress: () => model.searchSelectedTags(tag: tag, isSemantic: true),
                    ),
        
                  );
                }
                
              }
            ),
        ),
      );
    
  }
}
