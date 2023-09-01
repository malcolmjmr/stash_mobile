import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
import 'package:stashmobile/app/common_widgets/new_folder_dialog.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';

class CreateNewSpaceListItem extends StatelessWidget {
  const CreateNewSpaceListItem({Key? key, 
    this.title,
    required this.onSpaceCreated, 
  }) : super(key: key);

  final Function(Workspace space) onSpaceCreated;
  final String? title;

  @override
  Widget build(BuildContext context) {

    
    return SectionListItemContainer(
      isFirstListItem: true,
      isLastListItem: (title ?? '').isNotEmpty  ? true : false,
      onTap: () => showCupertinoModalBottomSheet(
        context: context, 
        builder: (context) {
          return CreateWorkspaceModal(
            workspace: Workspace(title: title),
            onDone: (workspace) => onSpaceCreated(workspace),
          );
        }
      ),
      child: ListItem(
        icon: Icon(Symbols.create_new_folder,
          fill: 0, 
          color: Colors.amber,
          size: 30,
        ),
        title: 'New Space',
        textColor: Colors.amber,
      )
    );
  }
}

