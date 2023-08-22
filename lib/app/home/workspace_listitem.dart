import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/home/delete_space_dialog.dart';
import 'package:stashmobile/app/move_to_folder/move_to_folder_modal.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WorkspaceListItem extends StatelessWidget {
  const WorkspaceListItem({Key? key, 
    required this.workspace, 
    required this.onTap, 
    this.onDelete,
    // required this.onShare,
    // required this.
    this.togglePin,
    this.isFirstListItem = false, 
    this.isLastListItem = false
  }) : super(key: key);

  final Workspace workspace; 
  final onTap;
  final onDelete;
  final Function(BuildContext)? togglePin;

  final bool isFirstListItem;
  final bool isLastListItem;

  
  @override
  Widget build(BuildContext context) {
  
    return SectionListItemContainer(
      onTap: onTap,
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      child: Slidable(
        startActionPane: ActionPane(
    
          motion: const StretchMotion(),
          dragDismissible: false,
          extentRatio: .25,
          openThreshold: .2,
          
          children: [
             SlidableAction(
              onPressed: togglePin,
              icon: workspace.isFavorite == true ? Icons.push_pin_outlined : Icons.push_pin,
              backgroundColor: workspace.isFavorite == true ? Colors.orange : Colors.yellow,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.75,
          children: [
            SlidableAction(
              onPressed: (context) => null,
              icon: Icons.ios_share_outlined,
              backgroundColor: Colors.blue,
            ),
            SlidableAction(
              backgroundColor: Colors.purple,
              onPressed: (context) => showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) => MoveToFolderModal(
                  folder: workspace, 
                  onFolderSelected: (folder) => null,
                )
              ),
              icon: Icons.folder_outlined,
            ),
            SlidableAction(
              backgroundColor: Colors.red,
              autoClose: false,
              onPressed: (context) => showCupertinoDialog(
                context: context, 
                builder: (context) => CupertinoAlertDialog(
                  title: Text('Delete "' + (workspace.title ?? 'Untitled') + '"'),
                  content: Text('Are you sure you want to delete this space?'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: onDelete,
                      child: Text('Delete',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                        style: TextStyle(
                          color: Colors.yellowAccent
                        ),
                      ),
                    )
    
                  ],
    
                )
              ),
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: ListItem(
          icon: Icon(Icons.folder, 
            color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!),
            size: 30,
          ),
          title: workspace.title ?? 'Untitled',
        )
      ),
    );
  }
}

