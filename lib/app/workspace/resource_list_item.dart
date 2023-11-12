/*

  type (tab, que)

*/




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
              //mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 38,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(resource.title ?? '', 
                              maxLines: 1,
                              style: TextStyle(
                                color: isLastActiveTab ? Colors.amber : Colors.white,
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
                if (resource.images.isNotEmpty && showImages)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildImages(context),
                ),
                if (resource.highlights.isNotEmpty && showHighlights)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildHighlights(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlights(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: PageView.builder(
        //scrollDirection: Axis.,
        itemCount: resource.highlights.length,
        padEnds: true,
        itemBuilder: (context, index) {
          final highlight = resource.highlights[index];
          return Text(highlight.text, 
            style: TextStyle(
              fontSize: 16,
            ),
            maxLines: 200,
            
            overflow: TextOverflow.ellipsis,
          );
        }
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
}
