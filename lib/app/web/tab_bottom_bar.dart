import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/web/horizontal_tabs.dart';
import 'package:stashmobile/app/web/tab_actions.dart';
import 'package:stashmobile/app/web/text_selection_menu.dart';
import 'package:stashmobile/app/web/vertical_tabs.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tab_commands.dart';

class TabBottomBar extends StatelessWidget {
  const TabBottomBar({Key? key, required this.model}) : super(key: key);

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {

    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black
      ),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: _buildTopSection(context)
          ),
          Container(
            height: 40,
            child: TabActions(workspaceModel: model)
          ),
        ],
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

  Widget _buildBottomSection() {
    return  Container(
      height: 40,
      child: TabActions(workspaceModel: model)
    );
  }

  

  Widget _buildQuickActions(BuildContext context) {

    List<TabCommand> quickActions = [
    TabCommand(
      icon: Symbols.arrow_left_alt_rounded, 
      name: 'Back', 
      onTap: () {
        model.currentTab.model.controller.goBack();
      },
    ),
    TabCommand(
      icon: Symbols.arrow_right_alt_rounded, 
      name: 'Forward', 
      onTap: () => model.goForward(),
    ),
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
            onTap: () => null,
            useTitle: true
          ),
        ),
        Expanded(
          child: _buildActionButton(
            title: 'Chat',
            icon: Symbols.chat,
            onTap: () => null,
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
              onTap: () {
                //update highlight
              }
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Like', 
              icon: Symbols.thumb_up_rounded, 
              onTap: () {
                //update highlight
              }
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Dislike', 
              icon: Symbols.thumb_down_rounded, 
              onTap: () {
                //update highlight
              }
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Funny', 
              icon: Symbols.sentiment_excited_rounded, 
              onTap: () {
                //update highlight
              }
            ),
          ),
          Expanded(
            child: _buildActionButton(
              title: 'Note', 
              icon: Symbols.comment, 
              onTap: () {
                //update highlight
              }
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
    bool? useTitle
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
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
            color: HexColor.fromHex('222222')
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(icon, size: 25,),
                if (useTitle == true)
                Text(title,
                  style: TextStyle(
                    fontSize: 14,
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

