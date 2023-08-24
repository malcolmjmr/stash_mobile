/*

  Header
  Resource Contaienr
  Slide up panel?

*/


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ionicons/ionicons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';
import 'package:stashmobile/app/web/tab_label.dart';
import 'package:stashmobile/app/web/tab_preview.dart';
import 'package:stashmobile/app/workspace/folder_list_item.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/app/workspace/tab_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';
//import 'package:material_symbols_icons/symbols.dart';

import '../../models/resource.dart';

class WorkspaceView extends StatefulWidget {

  final WorkspaceViewParams? params;
  final bool  showWebView;
  WorkspaceView({this.params, this.showWebView = false});

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {

  late WorkspaceViewModel model; 


  bool isLoaded = false;
  bool showTabs = true;
  bool showFolders = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = WorkspaceViewModel(
      context: context, 
      params: widget.params,
      setState: setState,
      onLoaded: (workspace) {
        setState(() {
          isLoaded = true;
        });
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
                index: model.showWebView ? 1 : 0,
                children: [
                  _buildWorkspaceView(),
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
              index: model.workspace.activeTabIndex,
              children: model.tabs
            )
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.black
            ),
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: true 
              ? _buildHorizontalTabs()
              : _buildVerticalTabs(),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalTabs() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: model.tabs.length,
      itemBuilder: (context, index) {
        final tab = model.tabs[index];
        return GestureDetector(
          onTap: () => model.onPageChanged(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
            child: Container(
              height: 35,
              width: 50,
              decoration: BoxDecoration(
                color: index == model.workspace.activeTabIndex ? HexColor.fromHex('444444') : HexColor.fromHex('222222'),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: tab.model.resource.favIconUrl != null 
                  ? Image.network(tab.model.resource.favIconUrl ?? '',
                    //loadingBuilder: (context, child, loadingProgress) => Icon(Icons.language, size: 30,),
                    errorBuilder: (context, child, loadingProgress) => Icon(Icons.public, size: 35,),
                  )
                  : Icon(Icons.public, size: 35,),
              )
              ),
          ),
        );
      }
    );
  }

  Widget _buildVerticalTabs() {
    model.tabPageController = PageController(initialPage: model.workspace.activeTabIndex!);
    return Column(
        children: [
          //Icon(Icons.arrow_drop_up),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              children: [
                ...model.tabs.map((tab) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    child: OpenTabLabel(
                      key: Key(tab.model.resource.id!),
                      isFirstListItem: true,
                      isLastListItem: true,
                      model: model, 
                      resource: tab.model.resource, 
                      onTap: () {
                        Navigator.push(context, 
                          PageTransition<dynamic>(
                            type: PageTransitionType.bottomToTop,
                            curve: Curves.easeInExpo,
                            child: TabEditModal(
                              tab: tab.model.resource,
                              workspaceModel: model,
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
                      model: model, 
                      resource: Resource(url: 'https://google.com', title: 'New Tab'), 
                      onTap: () => null
                    ),
                  ),
              ],
              onPageChanged: (index) {
                model.onPageChanged(index);
              },
              controller: model.tabPageController,
            ),
          ),
          //Icon(Icons.arrow_drop_down),
        ],
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
                model.showWebView = false;
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
                    child: Text(model.workspace.title ?? 'Tabs (${model.tabs.length})',
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
          GestureDetector(
            onTap: () => showMenu(
              context: context, 
              position: RelativeRect.fromLTRB(10, 50, 5, 0), 

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
              items: [
                PopupMenuItem(
                  child: Container(height: 30, width: 200, child: Text('Reload')),
                  padding: EdgeInsets.zero,
                ),
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  child: Text('Show Tab Icons')
                )
              ]),
            child: Icon(Icons.more_horiz, 
              color: workspaceColor
            ),
          )
        ],
      ),
    );
  }


  Widget _buildWorkspaceView() {
    return Stack(
      children: [
        _buildScrollView(),
        Positioned(
          height: 50,
          width: MediaQuery.of(context).size.width,
          bottom: 0,
          left: 0,
          child: _buildFooter()
        )
      ],
    );
  }

  Widget _buildScrollView() {
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
        SliverAppBar(
          title: _buildHeader(),
          automaticallyImplyLeading: false,
          pinned: true,
          leadingWidth: 0,
          leading: null,
          backgroundColor: Colors.black,
        ),
        if (model.workspace.title != null)
        SliverToBoxAdapter(
          child: _buildExpandedHeader(),
        ),

        if (model.folders.isNotEmpty)
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10),
            child: SectionHeader(
              title: 'Spaces',
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
                onTap: () => Navigator.pushNamed(context, AppRoutes.workspace, 
                  arguments: WorkspaceViewParams(
                    workspaceId: folder.id,
                    parentId: model.workspace.id, 
                  )
                ),
              ),
            );
          })
        ),

        if (model.showFolders) 
        SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),

        if (model.tabs.isNotEmpty && model.workspace.title != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SectionHeader(
              title: 'Tabs',
              actions: [
                if (model.showTabs && model.tabs.isNotEmpty)
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
        if (model.workspace.title != null && model.showTabs && model.tabs.length > 0)
        SliverList.builder(
          itemCount: model.tabs.length,
          itemBuilder: ((context, index) {
            final tab = model.tabs[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: TabListItem(
                key: Key(tab.model.resource.id!),
                isFirstListItem: index == 0,
                isLastListItem: index == model.tabs.length - 1,
                resource: tab.model.resource,
                model: model,
                onTap: () {
                  model.openTab(tab.model.resource);
                }
              ),
            );
          })
        ),

        if (model.workspace.title == null) 
        SliverToBoxAdapter(
          
          child: Center(
            child: Wrap(
              runAlignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: model.tabs.map((tab) => 
                TabPreview(
                  tab: tab.model.resource, 
                  onTap: () => model.openTab(tab.model.resource),
                  onClose: () => model.closeTab(tab.model.resource),
                )
              ).toList(),
            ),
          ),
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
              child: ResourceListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.queue.length - 1,
                resource: resource,
                model: model,
                onTap: () {
                  model.openTab(resource);
                }
              ),
            );
          })
        ),

        if (model.showQueue && model.queue.isNotEmpty)
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
          ),
        ),
        
        if (model.resources.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 5),
            child: SectionHeader(
              title: 'Resources',
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

  Widget _buildExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        //border: Border(bottom: BorderSide(color: HexColor.fromHex(model.workspaceHexColor))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBackButton(),
            //_buildTitle(context, model),
            model.workspace.title == null 
            ? _buildSaveButton()
            : _buildMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    final text = model.parentWorkspace != null ? model.parentWorkspace!.title! : 'Stash';
    final color = model.parentWorkspace != null ? HexColor.fromHex(colorMap[model.parentWorkspace?.color ?? 'grey']!) : null;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios, 
            weight: 100, 
            color: color
          ),
          Material(
            type: MaterialType.transparency,
            child: Hero(
              tag: text,
              child: Text(text, 
                style: TextStyle(
                  fontSize: 18,
                  color: color
                ),
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context, 
          builder: (context) => CreateWorkspaceModal(
            initialTitle: model.tabs[0].model.resource.title,
            onDone: (workspace) {
              model.saveSpace(workspace);
              Navigator.pop(context);
              context.read(homeViewProvider).refreshWorkspaces();
            }
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.create_new_folder_outlined, color: Colors.white,),
        
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

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () => null,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.more_vert_outlined, color: Colors.white,),
      ),
    );
  }

  // Widget _buildResourceContainer(BuildContext context, WorkspaceViewModel model) {
  //   return Expanded(
  //     child: Container(
        
  //       child: ListView.builder(
  //         itemCount: model.visibleResources.length,
  //         itemBuilder: ((context, index) {
  //           final resource = model.visibleResources[index];
  //           return TabListItem(
  //             key: Key(resource.id ?? resource.toString()),
  //             resource: resource,
  //             model: model,
  //             onTap: () => model.openTab(resource)
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFooter() {

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
          model.workspace.title == null 
          ?  FooterIcon(
              onTap: () => model.clearTabs(),
              icon: Icons.clear_all,
              color: color, 
              size: 30,
            )
          : Container(
            width: 30,
          ),
          _buildResourceCounts(context, model),
          FooterIcon(
            onTap: () {
               model.createNewTab(context);
            },
            icon: Icons.add_box_outlined, 
            color: color, 
            size: 30
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCounts(BuildContext context, WorkspaceViewModel model) {
    final tabCount = model.tabs.length;
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
        child: Icon(icon, size: size, color: color, weight: 100,),
      ),
    );
  }
}



