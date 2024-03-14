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
      color: Colors.black,
      child: CustomScrollView(
        slivers: [

          if (backItems.isNotEmpty)
          SliverAppBar(
            title: SectionHeader(title: 'Back'),
            backgroundColor: HexColor.fromHex('111111'),
            pinned: true,
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            leading: null,
          ),
          
          SliverList.builder(
            itemCount: tabModel.backItems.length,
            itemBuilder: (context, index) {
              final resource = tabModel.backItems[index];
              return ResourceListItem(
                model: tabModel.workspaceModel, 
                resource: resource, 
                onTap: () => tabModel.goTo(resource),
              );
            }
          ),
          SliverAppBar(
            title: SectionHeader(title: 'Current Location'),
            backgroundColor: HexColor.fromHex('111111'),
            pinned: true, 
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            leading: null,
          ),

          SliverToBoxAdapter(
            child: Padding(
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
          ),
          if (forwardItems.isNotEmpty)
          SliverAppBar(
            title: SectionHeader(title: 'Forward'),
            backgroundColor: HexColor.fromHex('111111'),
            pinned: true, 
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            leading: null,
          ),
                    
          SliverList.builder(
            itemCount: forwardItems.length,
            itemBuilder: (context, index) {
              final resource = forwardItems[index];
              return ResourceListItem(
                model: tabModel.workspaceModel, 
                resource: resource, 
                onTap: () => tabModel.goTo(resource),
              );
            }
          ),
          if (queueItems.isNotEmpty)
          SliverAppBar(
            title: SectionHeader(title: 'Up Next'),
            backgroundColor: HexColor.fromHex('111111'),
            pinned: true, 
            automaticallyImplyLeading: false,
            leadingWidth: 0,
            leading: null,
          ),
          SliverList.builder(
            itemCount: queueItems.length,
            itemBuilder: (context, index) {
              final resource = queueItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: index == 0,
                  isLastListItem: index == queueItems.length - 1,
                  model: tabModel.workspaceModel, 
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                ),
              );
            }
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
             child: ColoredBox(
               color: headerColor,
               child: ListTile(
                 textColor: titleColor,
                 title: Text(title),
               ),
           ),
           SliverList(
             delegate: SliverChildListDelegate.fixed(items),
           ),
         ],
       );
}