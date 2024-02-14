

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';

class TabActionsModel {

  Function(Function()) setState;

  WorkspaceViewModel workspaceModel;

  TabActionsModel({
    required this.workspaceModel, 
    required this.setState
  }){

  }



  List quickActions = [];


  onOpenSpaceTapped() {
    workspaceModel.goBackToWorkspaceView();
  }

  onSaveTapped(context) {

    final resource = workspaceModel.currentTab.model.resource;

    if (resource.isSaved) {
      showCupertinoModalBottomSheet(
        context: context, 
        builder: (context) {
          return EditBookmarkModal(resource: resource, workspaceViewModel: workspaceModel);
          //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
        }
      );
      
    } else {
      workspaceModel.saveTab(resource);
      
    }
     
  }

  onCreateTapped() {
    workspaceModel.createNewTab();
    HapticFeedback.mediumImpact();
  }

  onCreateLongPressed() {
    workspaceModel.setShowCreateOptions(true);
  }

  onQuickActionsTapped() {
    workspaceModel.setShowQuickActions(!workspaceModel.showQuickActions);
  }

  onNewSessionTapped(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.workspace);
    HapticFeedback.mediumImpact();
  }

  onNewSessionLongPressed(BuildContext context) {
    Navigator.pushNamed(context, 
      AppRoutes.workspace, 
      arguments: WorkspaceViewParams(
        isIncognito: true
      )
    );
  }



  Color get workspaceColor => HexColor.fromHex(colorMap[workspaceModel.workspace.color ?? 'grey']!);

  /*

    Tab Menu Command => Quick Action
    Quick action
      - name
      - icon
      - onClick
      - onDobuleClick


    quick actions are stored in workspace?
    global quick actions are derived?

    if there are no quick actions just show the menu

    
  */
}