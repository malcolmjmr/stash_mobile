import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';

class HorizontalTabs extends StatelessWidget {

  final WorkspaceViewModel workspaceModel;
  const HorizontalTabs({Key? key, required this.workspaceModel}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: workspaceModel.tabs.length,
      itemBuilder: (context, index) {
        final tab = workspaceModel.tabs[index];
        return GestureDetector(
          onTap: () => workspaceModel.onPageChanged(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                 height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: index == workspaceModel.workspace.activeTabIndex ? HexColor.fromHex('444444') : HexColor.fromHex('222222'),
                      
                  ),
                child: Slidable(
                  key: Key(tab.model.resource.id!),
                  direction: Axis.vertical,
                  startActionPane: ActionPane(
                    motion: StretchMotion(),
                    extentRatio: 0.5,
                    openThreshold: .1,
                    dragDismissible: true,
                    dismissible: DismissiblePane(onDismissed: () => workspaceModel.closeTab(tab.model.resource)),
                    children: [
                      SlidableAction(
                        icon: Icons.close,
                        backgroundColor: Colors.redAccent,
                        onPressed: (context) => null
                      )
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: StretchMotion(),
                    extentRatio: 0.5,
                    openThreshold: .1,
                    dragDismissible: true,
                    dismissible: DismissiblePane(onDismissed: () => workspaceModel.saveResource(tab.model.resource)),
                    children: [
                      SlidableAction(
                        icon: tab.model.resource.contexts.length == 0 ? Icons.bookmark_add : Icons.bookmark_remove ,
                        backgroundColor: Colors.green,
                        onPressed: (context) => null
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: tab.model.resource.favIconUrl != null 
                      ? Image.network(tab.model.resource.favIconUrl ?? '',
                        //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                        errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
                      )
                      : Icon(Icons.public, size: 35,),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}