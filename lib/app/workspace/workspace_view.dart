/*

  Header
  Resource Contaienr
  Slide up panel?

*/


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/move_to_folder_modal.dart';
import 'package:stashmobile/app/common_widgets/new_folder_dialog.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/common_widgets/share_item_modal.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';

import '../../models/resource.dart';

class WorkspaceView extends StatefulWidget {

  final String? workspaceId;
  WorkspaceView({this.workspaceId});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {

  late WorkspaceViewModel model; 

  bool showWebView = false;
  bool isLoaded = false;
  bool showTabs = true;
  bool showFolders = true;
  int tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = WorkspaceViewModel(
      context: context, 
      workspaceId: widget.workspaceId,
      onLoaded: () => {
        setState(() {
          isLoaded = true;
        })
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoaded 
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              child: IndexedStack(
                index: showWebView ? 1 : 0,
                children: [
                  _buildWorkspaceView(context, model),
                  _buildWebview(),
                ],
              )
            )
          )
        : Center(child: CircularProgressIndicator(),)
    );
  }

  Widget _buildWebview() {
    return Scaffold(
      body: Column(
        children: [
          _buildWebViewHeader(),
          Container(
            height: MediaQuery.of(context).size.height - 130,
            child: IndexedStack(
              index: tabIndex,
              children: model.tabs
            )
          ),
          _buildWebViewNavBar(),
        ],
      ),
    );
  }

  Widget _buildWebViewNavBar() {

    model.tabPageController = PageController(initialPage: model.workspace.activeTabIndex!);
    return Container(
       decoration: BoxDecoration(
        color: Colors.black
        // border: model.app.currentWorkspace != null 
        // ? Border(
        //     top: BorderSide(
        //       color: model.workspaceColor,
        //       width: 3.0
        //     )
        //   ) 
        // : null
      ),
      height: 70,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          //Icon(Icons.arrow_drop_up),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: model.workspace.tabs.map((tab) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                  child: TabListItem(
                    isFirstListItem: true,
                    isLastListItem: true,
                    model: model, 
                    resource: tab, 
                    onTap: () => null
                  ),
                );
              }).toList(),
              onPageChanged: (index) {
                model.onPageChanged(index);
                setState(() {
                  tabIndex = model.workspace.activeTabIndex!;
                });
              },
              controller: model.tabPageController,
            ),
          ),
          //Icon(Icons.arrow_drop_down),
        ],
      )
      
      // Column(
      //   children: [
      //     _buildUrlField(context, model, webManager),
      //     _buildNavigationButtons(context, model)
      //   ],
      // ),
    );
  }

  Widget _buildWebViewHeader() {
    final workspaceColor = HexColor.fromHex(model.workspaceHexColor);
    return Container(
      height: 40, 
      width: double.infinity, 
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black
        // border: model.app.currentWorkspace != null 
        // ? Border(
        //     bottom: BorderSide(
        //       color: model.workspaceColor,
        //       width: 3.0
        //     )
        //   ) 
        // : null
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showWebView = false;
              });
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios,
                  color: workspaceColor,
                ),
                Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: model.workspace.title ?? '',
                    child: Text(model.workspace.title ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: workspaceColor,
                        fontSize: 20
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz, 
            color: workspaceColor
          )
        ],
      ),
    );
  }


  Widget _buildWorkspaceView(BuildContext context, WorkspaceViewModel model) {
    return Stack(
      children: [
        _buildScrollView(context, model),
        Positioned(
          height: 50,
          width: MediaQuery.of(context).size.width,
          bottom: 0,
          left: 0,
          child: _buildFooter(context, model)
        )
      ],
    );
  }

  Widget _buildScrollView(BuildContext context, WorkspaceViewModel model) {
    return CustomScrollView(
      //controller: ,
      slivers: [
        // SliverAppBar(
        //   titleSpacing: 0,
        //   //expandedHeight: 130,
        //   bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(130),
        //     child: _buildExpandedHeader(context, model)
        //   ),
        //   //title: _buildHeader(context, model),
        //   // flexibleSpace: FlexibleSpaceBar(
        //   //   background: Container(color: HexColor.fromHex(model.workspaceHexColor)),
        //   //   title: _buildHeader(context, model),//_buildExpandedHeader(context, model),
        //   //   expandedTitleScale: 1,
        //   // ),
        //   centerTitle: true,
        //   automaticallyImplyLeading: false, 
        //   leading: null,
        //   backgroundColor: Colors.black,
        //   stretch: true,
        //   leadingWidth: 0,
          
        //   primary: true,
          
        // ),
        SliverToBoxAdapter(
          child: _buildExpandedHeader(context, model),
        ),

        if (model.folders.isNotEmpty)
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: SectionHeader(
              title: 'Folders',
              isCollapsed: model.showFolders,
              onToggleCollapse: () => model.toggleShowFolders(),
            ),
          ),
        ),
        if (model.showFolders) 
        SliverList.builder(
          itemCount: model.folders.length,
          itemBuilder: ((context, index) {
            final folder = model.folders[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: FolderListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.folders.length - 1,
                workspace: folder,
                model: model,
                onTap: () => null
              ),
            );
          })
        ),

        if (model.showFolders) 
        SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        if (model.workspace.tabs.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SectionHeader(
              title: 'Tabs',
              actions: [
                GestureDetector(
                  onTap: () => model.clearTabs(),
                  child: Icon(Icons.clear_all,),
                ),
      

              ],
              isCollapsed: model.showTabs,
              onToggleCollapse: () => model.toggleShowTabs(),
            ),
          ),
        ),
        if (model.showTabs && model.workspace.tabs.length > 0)
        SliverList.builder(
          itemCount: model.workspace.tabs.length,
          itemBuilder: ((context, index) {
            final resource = model.workspace.tabs[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: TabListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.workspace.tabs.length - 1,
                resource: resource,
                model: model,
                onTap: () {
                  model.openTab(resource);
                  setState(() {
                    tabIndex = model.workspace.activeTabIndex!;
                    showWebView = true;
                  });
                }
              ),
            );
          })
        ),
        if (model.queue.length > 0)
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SectionHeader(
              title: 'Queue',
              isCollapsed: model.showQueue,
              onToggleCollapse: () => model.toggleShowQueue(),
            ),
          ),
        ),
        if (model.showQueue && model.queue.isNotEmpty)
        SliverList.builder(
          itemCount: model.queue.length,
          itemBuilder: ((context, index) {
            final resource = model.queue[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: TabListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.queue.length - 1,
                resource: resource,
                model: model,
                onTap: () {
                  setState(() {
                     model.openTab(resource);
                     tabIndex = model.workspace.activeTabIndex!;
                  });
                }
              ),
            );
          })
        ),
        

        
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 20, bottom: 5),
            child: SectionHeader(
              title: 'History',
            ),
          ),
        ),

        if (model.resources.isNotEmpty)
        SliverList.builder(
          itemCount: model.resources.length,
          itemBuilder: ((context, index) {
            final resource = model.resources[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: ResourceListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.resources.length - 1,
                resource: resource,
                model: model,
                onTap: () => model.openResource(context, resource),
                
              ),
            );
          })
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 50),
        )
    
      ],
    );

  }

  Widget _buildExpandedHeader(BuildContext context, WorkspaceViewModel model) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, model),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 5, right: 5),
              child: Container(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(model.workspace.title ?? 'Untitled',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: HexColor.fromHex(model.workspaceHexColor),
                        fontWeight: FontWeight.bold, 
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SearchField()
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkspaceViewModel model) {
    return Container(
      decoration: BoxDecoration(
        //border: Border(bottom: BorderSide(color: HexColor.fromHex(model.workspaceHexColor))),
        
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(context, model),
            //_buildTitle(context, model),
            _buildMoreButton(context, model),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, WorkspaceViewModel model) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(Icons.arrow_back_ios, weight: 100, color: Colors.white,),
          Text('Home')
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, WorkspaceViewModel model) {
    return Expanded(
      child: Text(model.workspace.title ?? 'Untitled',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: HexColor.fromHex(model.workspaceHexColor),
          fontSize: 20.0,
          overflow: TextOverflow.ellipsis
        ),
      )
    );
  }

  Widget _buildMoreButton(BuildContext context, WorkspaceViewModel model) {
    return GestureDetector(
      onTap: () => null,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.more_vert_outlined, color: Colors.white,),
      ),
    );
  }

  Widget _buildResourceContainer(BuildContext context, WorkspaceViewModel model) {
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: model.visibleResources.length,
          itemBuilder: ((context, index) {
            final resource = model.visibleResources[index];
            return TabListItem(
              key: Key(resource.id ?? resource.toString()),
              resource: resource,
              model: model,
              onTap: () => model.openTab(resource)
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WorkspaceViewModel model) {

    final color = HexColor.fromHex(model.workspaceHexColor);
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        //border: Border(top: BorderSide(color: HexColor.fromHex(model.workspaceHexColor), width: 1)),
        color: Colors.black, //HexColor.fromHex(model.workspaceHexColor)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // FooterIcon(icon: Icons.dynamic_feed_outlined, color: color,),
          // FooterIcon(icon: Icons.history_outlined, color: color),
          // FooterIcon(icon: Icons.folder_outlined, color: color),
          // FooterIcon(icon: Icons.inbox_outlined, color: color),
          FooterIcon(
            onTap: () => showCupertinoModalPopup(
              context: context, 
              builder: (context) {
                return NewFolderDialog(
                  onSave: (name) => model.createNewFolder(context, name),
                );
              }
            ),
            icon: Icons.create_new_folder_outlined, 
            color: color, 
            size: 30
          ),
          _buildResourceCounts(context, model),
          FooterIcon(
            onTap: () => model.createNewTab(context),
            icon: Icons.add_box_outlined, 
            color: color, 
            size: 30
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCounts(BuildContext context, WorkspaceViewModel model) {
    final tabCount = model.workspace.tabs.length;
    return Row(
      children: [
        Text('${tabCount} Tab${tabCount > 1 ? 's' : ''}')
      ]
    );
  }
}

class TabWebViewsContainer extends StatelessWidget {
  const TabWebViewsContainer({Key? key, this.tabs = const []}) : super(key: key);
  final List<Resource> tabs;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: tabs.map((tab) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Transform.scale(
                scale: .7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(tab.url!)),
                  ),
                ),
              ),
            ),
          );
        }).toList()
      ),
    );
  }
}

class FooterIcon extends StatelessWidget {
  const FooterIcon({Key? key, required this.icon, this.onTap, this.color = Colors.black, this.size = 30}) : super(key: key);
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Icon(icon, size: size, color: color,),
      ),
    );
  }
}

class TabListItem extends StatelessWidget {
  const TabListItem({Key? key, 
    required this.model, 
    required this.resource, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
    this.isLastActiveTab = false,
  }) : super(key: key);

  final WorkspaceViewModel model;
  final Resource resource;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;
  final bool isLastActiveTab;

  @override
  Widget build(BuildContext context) {
    return SectionListItemContainer(
      isFirstListItem: isFirstListItem,
      isLastListItem: isLastListItem,
      onTap: onTap,
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showCupertinoModalBottomSheet(
            context: context, 
            builder: (context) => Material(
              type: MaterialType.transparency,
              child: Container(
                height: MediaQuery.of(context).size.height * .66,
                width: MediaQuery.of(context).size.width * .66,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(resource.url!)),
                ),
              ),
            )
          );
        },
        child: Slidable(
          key: Key(resource.toString()),
          startActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.move_to_inbox_outlined,
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
                onPressed: (context) => model.stashTab(resource),
              ),
              SlidableAction(
                icon: Icons.bookmark_add_outlined,
                backgroundColor: Colors.green,
                onPressed: (context) => model.saveTab(resource),
              ),
            ],
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () => model.stashTab(resource)),
            openThreshold: 0.5,
          ),
          endActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.ios_share,
                backgroundColor: Colors.blue,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return Container();//ShareModal()
                  }
                )
              ),
              SlidableAction(
                icon: Icons.folder_outlined,
                backgroundColor: Colors.purple,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return MoveToFolderModal(resource: resource);
                  }
                )
              ),
              SlidableAction(
                icon: Icons.close,
                backgroundColor: Colors.redAccent,
                onPressed: (context) => model.removeTab(resource),
              )
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () => model.removeTab(resource)),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                      : Icon(Icons.language, size: 35,)
                    ),
                ),
                Expanded(
                  child: Text(resource.title ?? '', 
                    maxLines: 1,
                    style: TextStyle(
                      color: isLastActiveTab ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      fontSize: 16,  
                      overflow: TextOverflow.ellipsis),
                    ),
                  ),
                if (resource.isSaved == true) 
                Icon(Icons.bookmark_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ResourceListItem extends StatelessWidget {
  const ResourceListItem({Key? key, 
    required this.model, 
    required this.resource, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
  }) : super(key: key);

  final WorkspaceViewModel model;
  final Resource resource;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => print(resource.id),
      child: SectionListItemContainer(
        isFirstListItem: isFirstListItem,
        isLastListItem: isLastListItem,
        onTap: onTap,
        child: Slidable(
          key: Key(resource.toString()),
          startActionPane: ActionPane(
            children: [
              SlidableAction(
                icon: Icons.copy,
                backgroundColor: Colors.green,
                onPressed: (context) => null,
              )
            ],
            motion: const ScrollMotion(),
            // A pane can dismiss the Slidable
            openThreshold: 0.5,
          ),
          endActionPane: ActionPane(
            children: [
               SlidableAction(
                icon: Icons.ios_share_outlined,
                backgroundColor: Colors.blue,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return ShareModal();
                  }
                ),
              ),
              SlidableAction(
                icon: Icons.folder_outlined,
                backgroundColor: Colors.purple,
                onPressed: (context) => showCupertinoModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return MoveToFolderModal(resource: resource,);
                  }
                ),
              ),
              SlidableAction(
                icon: Icons.delete,
                backgroundColor: Colors.red,
                onPressed: (context) => model.deleteResource(resource),
              )
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () => model.removeTab(resource)),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                      : Icon(Icons.language, size: 35,)
                    ),
                ),
                Expanded(
                  child: Text(resource.title ?? '', 
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                      fontSize: 14,  
                      overflow: TextOverflow.ellipsis),
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


class FolderListItem extends StatelessWidget {
  const FolderListItem({Key? key, 
    required this.model, 
    required this.workspace, 
    required this.onTap,
    this.isFirstListItem = false,
    this.isLastListItem = false,
  }) : super(key: key);

  final WorkspaceViewModel model;
  final Workspace workspace;
  final VoidCallback onTap;
  final bool isLastListItem;
  final bool isFirstListItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SectionListItemContainer(
        isFirstListItem: isFirstListItem,
        isLastListItem: isLastListItem,
        child: Slidable(
          key: Key(workspace.toString()),
          startActionPane: ActionPane(
            children: [
             
            ],
            motion: const ScrollMotion(),
            // A pane can dismiss the Slidable
            openThreshold: 0.5,
          ),
          endActionPane: ActionPane(
            children: [
              
            ],
            motion: const StretchMotion(),
            // A pane can dismiss the Slidable.
            //dismissible: DismissiblePane(onDismissed: () => model.removeTab(resource)),
            openThreshold: 0.25,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    child: Icon(Icons.folder)
                  )
                ),
                Expanded(
                  child: Text(workspace.title ?? '', 
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                      fontSize: 14,  
                      overflow: TextOverflow.ellipsis),
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

