import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

class FolderListItem extends StatelessWidget {
  const FolderListItem({Key? key, 

    required this.workspace, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
  }) : super(key: key);

  final Workspace workspace;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;

  @override
  Widget build(BuildContext context) {
    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      onTap: onTap,
      child: Slidable(
        key: Key(workspace.toString()),
        // startActionPane: ActionPane(
        //   children: [
           
        //   ],
        //   motion: const ScrollMotion(),
        //   // A pane can dismiss the Slidable
        //   openThreshold: 0.5,
        // ),
        // endActionPane: ActionPane(
        //   children: [
            
        //   ],
        //   motion: const StretchMotion(),
        //   // A pane can dismiss the Slidable.
        //   //dismissible: DismissiblePane(onDismissed: () => model.removeTab(resource)),
        //   openThreshold: 0.25,
        // ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 10),
                child: Container(
                  child: Icon(Icons.folder, 
                    size: 30, 
                    color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!),)
                )
              ),
              Expanded(
                child: Text(workspace.title ?? '', 
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    fontSize: 16,  
                    overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

