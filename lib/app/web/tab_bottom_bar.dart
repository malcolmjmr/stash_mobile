import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/web/horizontal_tabs.dart';
import 'package:stashmobile/app/web/tab_actions.dart';
import 'package:stashmobile/app/web/tab_actions_model.dart';
import 'package:stashmobile/app/modals/text_selection/text_selection_modal.dart';
import 'package:stashmobile/app/web/vertical_tabs.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tab_commands.dart';

class TabBottomBar extends StatelessWidget {
  const TabBottomBar({Key? key, required this.model}) : super(key: key);

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {

    final showTopBar = (model.selectedHighlight != null || model.notificationIsVisible || model.selectedText != null);
    return AnimatedSize(
      alignment: showTopBar ? Alignment.bottomCenter : Alignment.topCenter,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 2000),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        width: MediaQuery.of(context).size.width,
        height: showTopBar
          ? 60
          : model.showToolbar 
            ? 110 
            : 0,
        child: Column(
          children: [
            Expanded(
              child: _buildTopSection(context)
            ),
            if (!showTopBar)
            Container(
              height: 50,
              child: TabActions(model: TabActionsModel(workspaceModel: model),)
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTopSection(BuildContext context) {

    final borderColor = HexColor.fromHex('222222');
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
          top: BorderSide(color: borderColor, width: 2)
        )
      ),
      child: _getTopSectionView(context),
    );
  }

  
  Widget _getTopSectionView(BuildContext context) {

    /*
      Todo:
      model.showCreateOptions

    */

    final highlight = model.selectedHighlight != null 
      ? model.currentTab.model.resource
        .highlights.firstWhereOrNull((h) => h.id == model.selectedHighlight)
      : null;



    if (model.isInEditMode) {
      return _buildEditModeMenu();
    } else if (model.notificationIsVisible) {
      return _buildNotification();
    } else if (model.showTextSelectionMenu) {
      //Might want this to take up the full bottom bar
      return TextSelectionMenu(workspaceModel: model);
    } else if (model.showCreateOptions) {
      return _buildCreateOptions();
    } else if (model.showQuickActions) {
      return _buildQuickActions(context);
    } else if (highlight != null) {
      return _buildHighlightActions(highlight);
    } else {
      return VeritcalTabs(workspaceModel: model);
    }
  }



  

  Widget _buildQuickActions(BuildContext context) {

    List<TabCommand> quickActions = [
    TabCommand(
      icon: Symbols.refresh, 
      name: 'Reload', 
      onTap: () {
        model.reloadTab(model.currentTab.model.resource); 
      },
    ),
    TabCommand(
      icon: Symbols.ios_share_rounded, 
      name: 'Share', 
      onTap: () {
        model.onShare(model.currentTab.model.resource);
      }
    ),
    TabCommand(
      icon: Symbols.text_to_speech, 
      name: 'Listen', 
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
      onTap: () {
        model.setShowFindInPage(true);
      },
    ),
    TabCommand(
      icon: Symbols.move_up_rounded, 
      name: 'Move to Top', 
      onTap: () => model.moveTabToTop(),
    ),
    TabCommand(
      icon: Symbols.move_down_rounded, 
      name: 'Move to Bottom', 
      onTap: () => model.moveTabToBottom(),
    ),

  ];

    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: quickActions.map((a) {
          return _buildActionButton(
            title: a.name, 
            icon: a.icon, 
            onTap: a.onTap
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreateOptions() {
    return Row(
      children: [
        // Expanded(
        //   child: _buildActionButton(
        //     title: 'Tab',
        //     icon: Symbols.tab_rounded,
        //     onTap: () => model.createNewTab()
        //   ),
        // ),
        Expanded(
          child: _buildActionButton(
            title: 'Private',
            icon: Symbols.visibility_off_rounded,
            onTap: () => model.createNewTab(incognito: true),
            useTitle: true
          ),
        ),
        Expanded(
          child: _buildActionButton(
            title: 'Note',
            icon: Symbols.edit_document_rounded,
            onTap: () => model.createNote(),
            useTitle: true
          ),
        ),
        Expanded(
          child: _buildActionButton(
            title: 'Chat',
            icon: Symbols.chat,
            onTap: () => model.createChat(),
            useTitle: true
          ),
        )
      ],
    );
  }


  
  Widget _buildEditModeMenu() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => model.setEditMode(false),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('222222'),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Exit Edit Mode',
                //overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  Widget _buildNotification() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor.fromHex('222222'),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(model.notificationParams!.title,
                  //overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              if (model.notificationParams!.actionLabel != null)
              GestureDetector(
                onTap: () => model.notificationParams?.action?.call(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(model.notificationParams!.actionLabel!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    
                      color: Colors.amber,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightActions(Highlight highlight) {

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildActionButton(
              title: 'Related', 
              icon: Symbols.join_right_rounded, 
              onTap: () {
                model.selectedText = highlight.text;
                model.searchSelectedText();
                model.selectedText = null;
              }
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Favorite', 
              icon: Symbols.favorite, 
              onLongPress: () {
                highlight.favorites = 0;
                model.data.saveResource(model.currentTab.model.resource);
              },
              onTap: () {
                highlight.favorites += 1;
                model.data.saveResource(model.currentTab.model.resource);
              },
              isFilled: highlight.favorites > 0
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Like', 
              icon: Symbols.thumb_up_rounded, 
              onLongPress: () {
                highlight.likes = 0;
                model.data.saveResource(model.currentTab.model.resource);
              },
              onTap: () {
                highlight.likes += 1;
                model.data.saveResource(model.currentTab.model.resource);
              },
              isFilled: highlight.likes > 0
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Dislike', 
              icon: Symbols.thumb_down_rounded, 
              onLongPress: () {
                highlight.dislikes = 0;
                model.data.saveResource(model.currentTab.model.resource);
              },
              onTap: () {
                highlight.dislikes += 1;
                model.data.saveResource(model.currentTab.model.resource);
              },
              isFilled: highlight.dislikes > 0,
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Funny', 
              icon: Symbols.sentiment_excited_rounded, 
              onLongPress: () {
                highlight.laughs = 0;
                model.data.saveResource(model.currentTab.model.resource);
              },
              onTap: () {
                highlight.laughs += 1;
                model.data.saveResource(model.currentTab.model.resource);
              },
              isFilled: highlight.laughs > 0
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Chat', 
              icon: Symbols.comment, 
              onTap: () => model.createChat(),
              isFilled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title, 
    required IconData icon, 
    required Function() onTap,
    Function()? onLongPress,
    String? workspaceColor,
    bool? useTitle,
    bool isFilled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: () {
          try {
            onLongPress?.call();
          } catch (e) {
            model.setShowCreateOptions(false);
          }
          //model.setShowCreateOptions(false);
          HapticFeedback.mediumImpact();
        },
        onTap: () {

          try {
            onTap();
          } catch (e) {
            model.setShowCreateOptions(false);
          }
          model.setShowCreateOptions(false);
          HapticFeedback.mediumImpact();
          
          
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(icon, size: 25, color: Colors.black, fill: isFilled ? 1 : 0,),
                if (useTitle == true)
                Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

