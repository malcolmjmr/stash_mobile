import 'package:flutter/material.dart';
import 'package:stashmobile/app/web/horizontal_tabs.dart';
import 'package:stashmobile/app/web/tab_actions.dart';
import 'package:stashmobile/app/web/text_selection_menu.dart';
import 'package:stashmobile/app/web/vertical_tabs.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class TabBottomBar extends StatelessWidget {
  const TabBottomBar({Key? key, required this.model}) : super(key: key);

  final WorkspaceViewModel model;

  /*

    Top

  */

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
                        child: _buildTopSection()
                      ),
                      Container(
                        height: 40,
                        child: TabActions(workspaceModel: model)
                      ),
                    ],
                  ),
          );
  }

  Widget _buildTopSection() {

    /*
      Todo:
      model.showCreateOptions

    */
    if (model.isInEditMode) {
      return _buildEditModeMenu();
    } else if (model.notificationIsVisible) {
      return _buildNotification();
    } else if (model.showTextSelectionMenu) {
      //Might want this to take up the full bottom bar
      return TextSelectionMenu(workspaceModel: model);
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


  
}