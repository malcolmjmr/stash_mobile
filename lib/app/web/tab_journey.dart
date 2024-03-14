import 'package:flutter/material.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TabJourney extends StatelessWidget {
  const TabJourney({Key? key, required this.tabModel}) : super(key: key);

  final TabViewModel tabModel;

  

  @override
  Widget build(BuildContext context) {
    final backItems = tabModel.backItems;
    final queueItems = tabModel.queueItems;
    final forwardItems = tabModel.forwardItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: HexColor.fromHex('333333')))
      ),
      
      child: CustomScrollView(
        slivers: [

          if (backItems.isNotEmpty)
          Section(
            title: 'Back', 
            items: backItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == backItems[0],
                  isLastListItem: resource == backItems[backItems.length - 1],
                  model: tabModel.workspaceModel, 
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                ),
              );
            }).toList()
          ),
     
          Section(
            title: 'Current Location', 
            items: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  model: tabModel.workspaceModel,
                  resource: tabModel.resource,
                  isFirstListItem: true,
                  isLastListItem: true,
                  isLastActiveTab: true,
                  onTap: () => tabModel.goTo(tabModel.resource),
                ),
              ),
            ]
          ),

          if (forwardItems.isNotEmpty)
          Section(
            title: 'Forward', 
            items: forwardItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == forwardItems[0],
                  isLastListItem: resource == forwardItems[forwardItems.length - 1],
                  model: tabModel.workspaceModel, 
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                ),
              );
            }).toList()
          ),
          if (queueItems.isNotEmpty)
          Section(
            title: 'Up Next', 
            items: queueItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == queueItems[0],
                  isLastListItem: resource == queueItems[queueItems.length - 1],
                  model: tabModel.workspaceModel, 
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                ),
              );
            }).toList()
          ),

        ],
      ),
    );
  }

  _buildHeader({required String title}) {
    return Container(
      child: Text(title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Section extends MultiSliver {
  Section({
    Key? key,
    required String title,
    Color headerColor = Colors.white,
    Color titleColor = Colors.black,
    required List<Widget> items,
  }) : super(
         key: key,
         pushPinnedChildren: true,
         children: [
           SliverPinnedHeader(
             child: Container(
              color: Colors.black,
               child: Padding(
                 padding: const EdgeInsets.only(left: 15, right: 15.0, top: 10),
                 child: SectionHeader(title: title),
               ),
             )
           ),
           SliverList(
             delegate: SliverChildListDelegate.fixed(items),
           ),
         ],
       );
}