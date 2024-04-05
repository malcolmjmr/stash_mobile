import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stashmobile/app/common_widgets/play_button.dart';
import 'package:stashmobile/app/common_widgets/resource_list_item.dart';import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/providers/read_aloud.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

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

          SliverAppBar(
            title: _buildHeader(),
            automaticallyImplyLeading: false,
            pinned: true,
            leadingWidth: 0,
            leading: null,
            toolbarHeight: 60,
            titleSpacing: 0,
            backgroundColor: Colors.black,
            shadowColor: Colors.black,
            //foregroundColor: Colors.black,
            surfaceTintColor: Colors.black,
          ),
          

          if (backItems.isNotEmpty)
          Section(
            title: 'Back', 
            items: backItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == backItems[0],
                  isLastListItem: resource == backItems[backItems.length - 1],
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                ),
              );
            }).toList()
          ),

          SliverPadding(padding: EdgeInsets.only(bottom: 15)),
     
          Section(
            title: 'Current Location', 
            actions: [
              PlayButton(tabModel: tabModel,),
            ],
            items: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
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
          SliverPadding(padding: EdgeInsets.only(bottom: 15)),

          if (forwardItems.isNotEmpty)
          Section(
            title: 'Forward', 
            items: forwardItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == forwardItems[0],
                  isLastListItem: resource == forwardItems[forwardItems.length - 1],
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                  onRemove: tabModel.removeItem,
                ),
              );
            }).toList()
          ),

          if (queueItems.isNotEmpty || (forwardItems.isEmpty && tabModel.canGoForward))
          SliverPadding(padding: EdgeInsets.only(bottom: 15)),


          if (queueItems.isNotEmpty || (forwardItems.isEmpty && tabModel.canGoForward))
          Section(
            title: 'Up Next', 
             actions: [
              if (tabModel.canGoForward)
              ...[
                // GestureDetector(
                //   onTap: () => null,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 3, bottom: 3, left: 10.0, right: 3),
                //     child: Icon(Symbols.style_rounded, size: 24, fill: 0, weight: 600,),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () => null,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 3, bottom: 3, left: 30.0, right: 3),
                //     child: Icon(Symbols.forum_rounded, size: 22, fill: 0, weight: 600,),
                //   ),
                // ),
                // GestureDetector(
                //   onTap: () => null,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 3, bottom: 3, left: 30.0, right: 3),
                //     child: Icon(Symbols.search_rounded, size: 24, fill: 1, weight: 600,),
                //   ),
                // ),
                GestureDetector(
                  onTap: () => tabModel.getRelatedContent(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3, bottom: 3, left: 30.0, right: 3),
                    child: Icon(Symbols.shuffle, size: 24, fill: 1, weight: 600,),
                  ),
                )
              ]
              
            ],
            items: queueItems.map((resource) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ResourceListItem(
                  isFirstListItem: resource == queueItems[0],
                  isLastListItem: resource == queueItems[queueItems.length - 1],
                  resource: resource, 
                  onTap: () => tabModel.goTo(resource),
                  onAddToQueue: tabModel.addItemToQueue,
                  onRemove: tabModel.removeItem,
                ),
              );
            }).toList()
          ),

        ],
      ),
    );
  }

  _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: HexColor.fromHex('3333333')))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 0.0, bottom: 0),
              child: Icon(Symbols.fork_left, size: 35, fill: 1, weight: 600,),
            ),
        
            Text('Journey',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),

            Expanded(child: Container(),),
            GestureDetector(
              onTap: () => tabModel.toggleShowJourney(),
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor.fromHex('2222222'),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Symbols.close_small_rounded, size: 28, weight: 600,),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Section extends MultiSliver {
  Section({
    Key? key,
    required String title,
    List<Widget>? actions,
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
                 padding: const EdgeInsets.only(left: 15, right: 15.0),
                 child: SectionHeader(
                  title: title, 
                  trailing: actions != null 
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: actions,
                    )
                    : null,
                 ),
               ),
             )
           ),
           SliverList(
             delegate: SliverChildListDelegate.fixed(items),
           ),
         ],
       );
}

class ResourceListItem extends StatelessWidget {
  const ResourceListItem({Key? key, 
    
    required this.resource, 
    required this.onTap,

    this.workspace,
    this.isFirstListItem = false,
    this.isLastListItem = false,
    this.isLastActiveTab = false,
    this.view = ResourceViewType.singleLine,
    this.onAddToQueue,
    this.onRemove,
  }) : super(key: key);


  final Resource resource;
  final Workspace? workspace;
  final VoidCallback onTap;
 
  final bool isLastListItem;
  final bool isFirstListItem;
  final bool isLastActiveTab;

  final ResourceViewType  view;
  final Function(Resource)? onAddToQueue;
  final Function(Resource)? onRemove;


  @override
  Widget build(BuildContext context) {

    List<SlidableAction> leftActions = [];
    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      isHighlighted: isLastActiveTab,
      onTap: onTap,
      child: Slidable(
        startActionPane: onAddToQueue == null
         ? null 
         : ActionPane(
  
          motion: const StretchMotion(),
          children: [
            /*
              open in new tab
            */
            
            SlidableAction(
              icon: Symbols.add_circle_rounded,
              backgroundColor: Colors.transparent,
              onPressed: (context) {
                onAddToQueue?.call(resource);
              }
            )
          ],
        ),
        endActionPane: onRemove == null 
        ? null
        : ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              icon: Symbols.add_circle_rounded,
              backgroundColor: Colors.redAccent,
              onPressed: (context) {
                onRemove?.call(resource);
              }
            )
          ],    
        ),
        key: Key(resource.toString()),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildTitle(),
              _buildDescription(),
            ],
          )
        ),
      ),
    );
  }



  Widget _buildTitle() { 
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Container(
            height: 35,
            width: 35,
            child: resource.favIconUrl != null 
              ? Image.network(resource.favIconUrl ?? '',
                //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
              )
              : Icon(Icons.public, size: 35,)
            ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.title ?? resource.url ?? '', 
                maxLines: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 16,  
                  overflow: TextOverflow.ellipsis
                ),
              ),
              if (resource.url != null)
              Row(
                children: [
                  Text(Uri.parse(resource.url!).host.replaceAll('www.', '') ?? '', 
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                      fontSize: 14,  
                      overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return resource.summary != null 
      ? Container(
        child: Text(resource.summary!,
          style: TextStyle(

          ),
        ),
      )
      : Container();
  }

  Widget _buildWorkspaceInfo() {
    return workspace == null ? Container() : Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 40, top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
      
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(Icons.folder, 
                color: HexColor.fromHex(colorMap[workspace!.color ?? 'grey']!),
              )
            ),
            Expanded(
              child: Text(workspace!.title ?? '', 
                maxLines: 1,
                style: TextStyle(
                  // color: isLastActiveTab ? Colors.amber : Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 16,  
                  overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

