import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
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
        child: ListItem(
          icon: Icon(Icons.folder, 
            color: HexColor.fromHex(colorMap[workspace.color ?? 'grey']!),
            size: 30,
          ),
          title: workspace.title ?? 'Untitled',
        )
      )
    );
  }
}

