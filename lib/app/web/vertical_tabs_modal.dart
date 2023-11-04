import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';
import 'package:stashmobile/app/web/tab_label.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class VeritcalTabsModal extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const VeritcalTabsModal({Key? key, required this.workspaceModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: HexColor.fromHex('111111'),
        padding: EdgeInsets.symmetric(vertical: 10),
        height: MediaQuery.of(context).size.height * .5,
        child: Column(
            children: [
              //Icon(Icons.arrow_drop_up),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    ...workspaceModel.tabs.map((tab) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                        child: OpenTabLabel(
                          key: Key(tab.model.resource.id!),
                          isFirstListItem: true,
                          isLastListItem: true,
                          model: workspaceModel, 
                          resource: tab.model.resource, 
                          isLastActiveTab: workspaceModel.currentTab.model.resource.id == tab.model.resource.id,
                          onTap: () {
                            workspaceModel.tabPageController?.jumpToPage(workspaceModel.tabs.indexOf(tab));
                            Navigator.of(context).pop();
                            
                            
                          }
                        ),
                      );
                    }).toList(),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
                        child: _buildCreateNewTab(context),
                      ),
                  ],
                ),
              ),
              //Icon(Icons.arrow_drop_down),
            ],
          ),
      ),
    );
  }

  Widget _buildCreateNewTab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        workspaceModel.createNewTab();
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.green
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:5.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text('Create new tab',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Icon(Symbols.add_box_rounded, weight: 600,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

