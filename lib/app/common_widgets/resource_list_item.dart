/*

  type (tab, que)

*/




import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/models/workspace.dart';

/*

*/



class ResourceListItem extends StatelessWidget {
  const ResourceListItem({Key? key, 
    
    required this.resource, 
    required this.onTap,
    this.onTagClicked,
    this.workspace,
    this.isFirstListItem = false,
    this.isLastListItem = false,
    this.isLastActiveTab = false,
    this.view = ResourceViewType.singleLine,
  }) : super(key: key);


  final Resource resource;
  final Workspace? workspace;
  final VoidCallback onTap;
  final Function(Tag)? onTagClicked;
  final bool isLastListItem;
  final bool isFirstListItem;
  final bool isLastActiveTab;

  final ResourceViewType  view;

  @override
  Widget build(BuildContext context) {

    List<SlidableAction> leftActions = [];
    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTitle(),
            _buildWorkspaceInfo(),
            _buildTags(context),
          ],
        )
      ),
    );
  }



  Widget _buildTitle() { 
    return Row(
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
    );
  }

  Widget _buildWorkspaceInfo() {
    return workspace == null ? Container() : Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
      
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(Icons.folder, 
                color: HexColor.fromHex(colorMap[workspace!.color ?? 'grey']!),
              )
            ),
            Expanded(
              child: Text(workspace!.title ?? '', 
                maxLines: 1,
                style: TextStyle(
                  // color: isLastActiveTab ? Colors.amber : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 16,  
                  overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return resource.tags.isEmpty 
      ? Container() 
      : Container(
        height: 30,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: resource.tags.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 40),
                );
              } else {
                final tag = Tag(name: resource.tags[index - 1]);
                return Padding(
                  padding: const EdgeInsets.only(top: 5, right: 8.0),
                  child: TagChip(tag: tag, onTap: () => onTagClicked?.call(tag),),
                );
              }
              
            }
          ),
      );
    
  }


}


enum ResourceViewType {
  card,
  singleLine,
  grid,
}