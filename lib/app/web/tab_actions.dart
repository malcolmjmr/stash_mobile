import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/web/tab_actions_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/main.dart';
import 'package:stashmobile/models/tab_commands.dart';

class TabActions extends StatelessWidget {
  const TabActions({Key? key, required this.model}) : super(key: key);

  final TabActionsModel model;
  
  @override
  Widget build(BuildContext context) {
      return _buildDefaultActions(context);
  }

  Widget _buildDefaultActions(BuildContext context) {
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 10),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          model.workspaceModel.workspace.title != null 
          ? ActionIcon(
            padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 20),
            action: TabCommand(
              icon: Symbols.folder_open_rounded,
              name: 'Open Space',
              onTap: model.onOpenSpaceTapped,
              onLongPress: () => context.read(showHomeProvider).state = true,
              iconFillFunction: (_) => 0 // show open spaces modal

            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          )
          : _buildTabsIcon(
              padding: EdgeInsets.only(top: 5, bottom: 5, right: 10, left: 20),
              onTap: model.onOpenSpaceTapped,
              onLongPress: () => context.read(showHomeProvider).state = true,
            ),

          ActionIcon(
            action: TabCommand(
              icon: Symbols.star_rounded,
              name: 'Save',
              iconFillFunction: (model) => model.currentTab.model.resource.isSaved ? 1 : 0,
              onTap: () => model.onSaveTapped(context),
              onDoubleTap: () => null //model.workspaceModel.currentTab.model.scrollToNextHighlight()
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),

          ActionIcon(
            action: TabCommand(
              icon: Symbols.arrow_back_ios_rounded,
              name: 'Back',
              onTap: model.workspaceModel.goBack,
              onDoubleTap: model.workspaceModel.goToStart,
              onLongPress: () => model.workspaceModel.showBackHistory(context),
              iconFillFunction:  (model) {
                return model.currentTab.model.canGoBack ? 1 : 0;
              },
              opacity: model.workspaceModel.currentTab.model.canGoBack ? 1 : .5
            ), 
            color: model.workspaceColor,
            size: 24,
            workspaceModel: model.workspaceModel,
          ),

          ActionIcon(
            action: TabCommand(

              icon: Symbols.add_box_rounded,
              name: 'New Tab',
              onTap: model.onCreateTapped,
              onLongPress: model.onCreateLongPressed,
              iconFillFunction: (model) {
                return 1; //model.showCreateOptions ? 1 : 0;
              }
            ), 
            color: model.workspaceColor,
            size: 36,
            workspaceModel: model.workspaceModel,
          ),

           ActionIcon(
            
            action: TabCommand(
              icon: Symbols.arrow_forward_ios_rounded,
              name: 'Forward',
              onTap: model.workspaceModel.goForward,
              onLongPress: () => model.workspaceModel.showForwardQueue(context),
              iconFillFunction:  (model) {
                return model.currentTab.model.canGoForward ? 1 : 0;
              },
              opacity: model.workspaceModel.currentTab.model.canGoForward ? 1 : .5
            ), 
            color: model.workspaceColor,
            size: 24,
            workspaceModel: model.workspaceModel,
                         ),

          ActionIcon(
            action: TabCommand(
              icon: model.workspaceModel.showQuickActions ? Symbols.expand_circle_down_rounded : Symbols.expand_circle_up_rounded,
              name: 'Show Actions',
              onTap: model.onQuickActionsTapped,
              iconFillFunction: (model) {
                return model.showQuickActions ? 1 : 0;
              }
            ), 
            color: model.workspaceColor,
            workspaceModel: model.workspaceModel,
          ),
          ActionIcon(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 20),
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

  Widget _buildTabsIcon({ 
    Function()? onTap, 
    Function()? onDoubleTap, 
    Function()? onLongPress, 
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5) 
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 1,
                child: Container(
                  height: 23,
                  width: 23,
                  decoration: BoxDecoration(
                    border: Border.all(color: model.workspaceColor, width: 1.3),
                    borderRadius: BorderRadius.circular(3),
                    //color: model.workspaceColor
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 23,
                child: Text(model.workspaceModel.tabs.length.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: model.workspaceColor
                     
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            )
        
          ],
        
        ),
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
    required this.workspaceModel,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5) 
  }) : super(key: key);

  final TabCommand action;
  final double size;
  final Color? color;
  final WorkspaceViewModel workspaceModel;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      onDoubleTap: action.onLongPress,
      onLongPress: action.onLongPress,
      child: Padding(
        padding: padding,
        child: Container(
          child: Opacity(
            opacity: action.opacity,
            child: Icon(
              action.icon,
              size: size,
              fill: action.iconFillFunction != null 
                ? action.iconFillFunction!.call(workspaceModel) 
                : 0,
              color: color,
            ),
          )
        ),
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

List<TabCommand> quickActions = [
    TabCommand(
      icon: Symbols.arrow_left_alt_rounded, 
      name: 'Back', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.arrow_right_alt_rounded, 
      name: 'Forward', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.refresh, 
      name: 'Reload', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.text_to_speech, 
      name: 'Listen', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.subscriptions_rounded, 
      name: 'Create Playlist', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.chrome_reader_mode_rounded, 
      name: 'TOC', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.find_in_page_rounded, 
      name: 'Find in Page', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.ios_share_rounded, 
      name: 'Share', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.move_up_rounded, 
      name: 'Move to Top', 
      onTap: () => null,
    ),
    TabCommand(
      icon: Symbols.move_down_rounded, 
      name: 'Move to Bottom', 
      onTap: () => null,
    ),

  ];