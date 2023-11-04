import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';
import 'package:stashmobile/app/web/tab_label.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class VeritcalTabs extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const VeritcalTabs({Key? key, required this.workspaceModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    workspaceModel.tabPageController = PageController(initialPage: workspaceModel.workspace.activeTabIndex!);
    return Column(
        children: [
          //Icon(Icons.arrow_drop_up),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: [
                ...workspaceModel.tabs.map((tab) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    child: OpenTabLabel(
                      key: Key(tab.model.resource.id!),
                      isFirstListItem: true,
                      isLastListItem: true,
                      model: workspaceModel, 
                      resource: tab.model.resource, 
                      onTap: () {
                        Navigator.push(context, 
                          PageTransition<dynamic>(
                            type: PageTransitionType.bottomToTop,
                            curve: Curves.easeInExpo,
                            child: TabEditModal(
                              tab: tab.model.resource,
                              workspaceModel: workspaceModel,
                            ),
                            fullscreenDialog: true,
                          )
                        );
                        
                        
                      }
                    ),
                  );
                }).toList(),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    child: OpenTabLabel(
                      isFirstListItem: true,
                      isLastListItem: true,
                      model: workspaceModel, 
                      resource: Resource(url: 'https://google.com', title: 'New Tab'), 
                      onTap: () => null
                    ),
                  ),
              ],
              onPageChanged: (index) {
                workspaceModel.onPageChanged(index);
              },
              controller: workspaceModel.tabPageController,
            ),
          ),
          //Icon(Icons.arrow_drop_down),
        ],
      );
  }
}

