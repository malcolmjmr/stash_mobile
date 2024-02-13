import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/web/tab_actions_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/tab_commands.dart';

class TabActions extends StatefulWidget {
  const TabActions({Key? key, required this.workspaceModel}) : super(key: key);

  final WorkspaceViewModel workspaceModel;

  @override
  State<TabActions> createState() => _TabActionsState();
}

class _TabActionsState extends State<TabActions> {
  /*

    Default actions (hidden when quick actions are shown)

    Quick actions (expand widget)

    Tab Menu (screen)

  */

  late TabActionsModel model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = TabActionsModel(
      workspaceModel: widget.workspaceModel, 
      setState: setState
    );
  }
  
  @override
  Widget build(BuildContext context) {
      return model.workspaceModel.showCreateOptions 
        ? _buildQuickActions()
        : _buildDefaultActions();
  }

  Widget _buildDefaultActions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          ActionIcon(
            action: TabCommand(
              icon: Symbols.folder_open_rounded,
              name: 'Open Space',
              onTap: model.onOpenSpaceTapped,
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),

          ActionIcon(
            action: TabCommand(
              icon: Symbols.star_rounded,
              name: 'Save',
              iconFillFunction: (model) => model.currentTab.model.resource.isSaved ? 1 : 0,
              onTap: () => model.onSaveTapped(context)
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),

          ActionIcon(
            action: TabCommand(
              icon: Symbols.add_box_rounded,
              name: 'New Tab',
              onTap: model.onCreateTapped,
              onLongPress: model.onCreateLongPressed
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),

          ActionIcon(
            action: TabCommand(
              icon: Symbols.expand_circle_up_rounded,
              name: 'Show Actions',
              onTap: model.onShowActionsTapped
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),
          ActionIcon(
            action: TabCommand(
              icon: Symbols.new_window_rounded,
              name: 'New Session',
              onTap: () => model.onNewSessionTapped(context)
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      child: Wrap(
        children: model.quickActions.map((action) {
          return Container();
        }).toList(),
      ),
    );
  }
}


class ActionIcon extends StatelessWidget {
  const ActionIcon({
    Key? key, 
    required this.action, 
    this.size = 25, 
    this.color, 
    required this.workspaceModel
  }) : super(key: key);

  final TabCommand action;
  final double size;
  final Color? color;
  final WorkspaceViewModel workspaceModel;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      onDoubleTap: action.onDoubleTap,
      child: Container(
        child: Icon(
          action.icon,
          size: size,
          fill: action.iconFillFunction != null 
            ? action.iconFillFunction!.call(workspaceModel) 
            : 0,
          color: color,
        )
      ),
    );

  }
}

class ActionListItem extends StatelessWidget {
  const ActionListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
        ],
      ),
    );
  }
}