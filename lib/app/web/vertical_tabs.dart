import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/read_aloud/player_view.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';
import 'package:stashmobile/app/web/tab_label.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';

class VertcalTabs extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const VertcalTabs({Key? key, required this.workspaceModel}) : super(key: key);

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
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: OpenTabLabel(
                      key: Key(tab.model.resource.id!),
                      isFirstListItem: true,
                      isLastListItem: true,
                      model: workspaceModel, 
                      resource: tab.model.resource, 

                      onTap: () {

                        //if (tab.model.resource.url == null) return; // Let user edit name or enter query
                        
                        Navigator.push(context, 
                          PageTransition<dynamic>(
                            type: PageTransitionType.bottomToTop,
                            curve: Curves.easeInExpo,
                            child: context.read(readAloudProvider).isPlaying
                              ? PlayerView()
                              : TabEditModal(
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
                if (!workspaceModel.tabs.any((tab) => tab.model.viewType == null))
                _buildEndingNewTab(context)
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

  Widget _buildEndingNewTab(BuildContext context) {

    final newTabResource = Resource(title: 'New Tab');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: OpenTabLabel(
        isFirstListItem: true,
        isLastListItem: true,
        model: workspaceModel, 
        resource: newTabResource, 
        onTap: () {

          Navigator.push(context, 
            PageTransition<dynamic>(
              type: PageTransitionType.bottomToTop,
              curve: Curves.easeInExpo,
              child: context.read(readAloudProvider).isPlaying
                ? PlayerView()
                : TabEditModal(
                  tab: newTabResource,
                  workspaceModel: workspaceModel,
                ),
              fullscreenDialog: true,
            )
          );
        }
      ),
    );
  }
}

