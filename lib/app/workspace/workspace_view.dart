/*

  Header
  Resource Contaienr
  Slide up panel?

*/


import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ionicons/ionicons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/common_widgets/drop_down_menu.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart' hide SectionHeader;
import 'package:stashmobile/app/modals/move_tabs/move_tabs_modal.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/app/web/find_in_page.dart';
import 'package:stashmobile/app/web/horizontal_tabs.dart';
import 'package:stashmobile/app/web/tab_actions.dart';
import 'package:stashmobile/app/web/tab_bottom_bar.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';
import 'package:stashmobile/app/web/tab_label.dart';
import 'package:stashmobile/app/web/tab_menu.dart';
import 'package:stashmobile/app/web/tab_preview.dart';
import 'package:stashmobile/app/web/text_selection_menu.dart';
import 'package:stashmobile/app/web/vertical_tabs.dart';
import 'package:stashmobile/app/workspace/space_list_item.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/app/workspace/tab_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_menu.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
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
    );
  }


  @override
  Widget build(BuildContext context) {
    print('building workspace view');
    return SafeArea(
      child: !model.isLoading
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              child: IndexedStack(
                index: model.workspace.showWebView ? 1 : 0,
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
      body: Stack(
        children: [
          Column(
            children: [
              _buildWebViewHeader(),
              Container(
                height: MediaQuery.of(context).size.height - 160,
                child: IndexedStack(
                  index: model.workspace.activeTabIndex,
                  children: model.tabs
                )
              ),
              TabBottomBar(model: model),
            ],
          ),
          if (model.showFindInPage)
          FindInPage(model: model)
        ],
      ),
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
            onTap: () => model.goBackToWorkspaceView(),
            child: Row(
              children: [
                // Icon(Icons.arrow_back_ios,
                //   color: workspaceColor,
                // ),
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
          Expanded(child: Container(),),
          if (model.workspace.isIncognito == true)
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: _buildIncognitoIcon(),
              ),

          GestureDetector(
            onTap: () => showCupertinoModalBottomSheet(
              context: context, 
              builder: (context) {
                return TabMenu(
                  resource: model.currentTab.model.resource,
                  workspaceModel: model,
                );
              }
            ),
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

        SliverToBoxAdapter(
          child: SizedBox(height: 10),
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
                  child: Icon(Symbols.tab_close,),
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
                isLastActiveTab: model.workspace.activeTabIndex == index,
                resource: tab.model.resource,
                model: model,
                onTap: () {
                  //print(tab.model.resource);
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
                  showSelectionToggle: model.selectedResources.length > 0,
                  isSelected: model.selectedResources.contains(tab.model.resource.id),
                  toggleSelection: () => model.toggleResourceSelection(tab.model.resource),
                  open: () => model.openTab(tab.model.resource),
                  close: () => model.closeTab(tab.model.resource),
                )
              ).toList(),
            ),
          ),
        ),



        // if (model.queue.length > 0)
        //   SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
        //     child: SectionHeader(
        //       title: 'Queue',
        //       isCollapsed: model.showQueue,
        //       onToggleCollapse: () => model.toggleShowQueue(),
        //     ),
        //   ),
        // ),
        // if (model.showQueue && model.queue.isNotEmpty)
        // SliverList.builder(
        //   itemCount: model.queue.length,
        //   itemBuilder: ((context, index) {
        //     final resource = model.queue[index];
        //     return Padding(
        //       padding: EdgeInsets.only(
        //         left: 15.0, 
        //         right: 15, 
        //       ),
        //       child: ResourceListItem(
        //         isFirstListItem: index == 0,
        //         isLastListItem: index == model.queue.length - 1,
        //         resource: resource,
        //         model: model,
        //         onTap: () {
        //           model.openTab(resource);
        //         }
        //       ),
        //     );
        //   })
        // ),

        // if (model.showQueue && model.queue.isNotEmpty)
        //   SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 5),
        //   ),
        // ),
        
        if (model.visibleResources.isNotEmpty || model.selectedTags.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 15.0, right: 15, bottom: 5),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildListOptions(),
              ),
            ),
          ),
        ),

        // if (model.visibleTags.isNotEmpty) 
        // SliverToBoxAdapter(
        //   child: _buildTags(),
        // ),

        // if (model.showDomains)
        // SliverToBoxAdapter(
        //   child: _buildDomains(),
        // )
        // else if (model.showTags)
        // SliverToBoxAdapter(
        //   child: _buildTags(),
        // )
        if (model.visibleResources.isNotEmpty)
        SliverList.builder(
          itemCount: model.visibleResources.length,
          itemBuilder: ((context, index) {
            final resource = model.visibleResources[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: ResourceListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.visibleResources.length - 1,
                resource: resource,
                model: model,
                onTap: () => model.openResource(context, resource),
                showHighlights: model.resourceView == ResourceView.highlights,
                showImages: model.resourceView == ResourceView.images,
                
              ),
            );
          })
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 70),
        )
    
      ],
    );

  }


  List<Widget> _buildListOptions() {
  
    return [
      if (model.hasSavedResources)
      _buildListOption(text: 'Recent'),
      if (model.hasFavorites)
      _buildListOption(text: 'Favorites', view: ResourceView.important),
      if (model.hasHighlights)
      _buildListOption(text: 'Highlights', view: ResourceView.highlights),
      if (model.hasQueue)
      _buildListOption(text: 'To Visit', view: ResourceView.queue),
      if (model.hasImages)
      _buildListOption(text: 'Images', view: ResourceView.images)
    ];
  }

  Widget _buildListOption({ResourceView? view, required String text}) {
    final isSelected = model.resourceView == view;
    return Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () => model.setResourceView(view),
            child: Opacity(
              opacity: isSelected ? 1 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!): HexColor.fromHex('444444'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8.0),
                  child: Text(text, 
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  // Widget _buildDomains() {
  //   return SectionContainer(
  //     child: Wrap(
  //       children: model.domains.map((domain) {
  //         return Container(
  //           child: Image.network(domain.),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          color: HexColor.fromHex('222222')
        ),
        //width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: model.visibleTags.length,
            itemBuilder: (context, index) {
              final tag = model.visibleTags[index];
              return Padding(
                padding: EdgeInsets.only(right: 10.0, left: index == 0 ? 10 : 0),
                child: TagChip(
                  key: Key(tag.name),
                  tag: tag,
                  isSelected: model.selectedTags.firstWhereOrNull((t) => t.name == tag.name) != null,
                  onTap: () => model.toggleTagSelection(tag),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader() {
    final title = model.workspace.title ?? 'Untitled';
    final textWidget = Text(title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: HexColor.fromHex(model.workspaceHexColor),
        fontWeight: FontWeight.bold, 
        fontSize: 30,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 5, right: 5),
              child: Container(

                child: title.length < 15 
                  ? FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Material(
                      type: MaterialType.transparency,
                      child: textWidget,
                    )
                  )
                  : textWidget
              ),
            ),
            SearchField(
              showPlaceholder: true,
              onTap: () {
                context.read(searchViewProvider).initBeforeNavigation();
                Navigator.pushNamed(context, AppRoutes.search);
              }
            )
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
        child: model.selectedResources.isNotEmpty
          ? _buildSelectionHeader()
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBackButton(),
              //_buildTitle(context, model),
              model.workspace.title == null 
              ? SaveSpaceButton(model: model,)
              : _buildMoreButton(),
            ],
          ),
      ),
    );
  }


  Widget _buildIncognitoIcon() {
    return Icon(
      Icons.visibility_off,

      color: HexColor.fromHex('444444'),
    );
  }



  Widget _buildSelectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${model.selectedResources.length} Selected', 
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () => model.cancelTabSelection(),
          child: Text('Cancel',
          
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7)
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBackButton() {
    final text = model.parentWorkspace != null ? model.parentWorkspace!.title! : 'Back';
    final color = model.parentWorkspace != null ? HexColor.fromHex(colorMap[model.parentWorkspace?.color ?? 'grey']!) : null;
    return GestureDetector(
      onTap: () {
         Navigator.pop(context);
         context.read(homeViewProvider).refreshData();
      },
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


  Widget _buildMoreButton() {

    final color = HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          PageTransition<dynamic>(
            type: PageTransitionType.rightToLeft,
            alignment: Alignment.topCenter,
            curve: Curves.easeInExpo,
            child: WorkspaceMenu(),

            fullscreenDialog: true,
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(Icons.more_horiz_outlined, color: color, size: 20,)
        ),
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

    
    return Container(
      height: 50,
      //padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        //border: Border(top: BorderSide(color: HexColor.fromHex(model.workspaceHexColor), width: 1)),
        color: Colors.black, //HexColor.fromHex(model.workspaceHexColor)
      ),
      child: model.selectedResources.isNotEmpty
        ? _buildSelectionFooter()
        : _buildDefaultFooter()
    );
  }

  Widget _buildDefaultFooter() {
    final color = HexColor.fromHex(model.workspaceHexColor);
    return Container(
       decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: HexColor.fromHex('333333'), 
            width: 1
          )
        )
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                  onTap: () => model.clearTabs(createNewTab: true),
                  icon: Symbols.tab_close,
                  color: color, 
                  size: 30,
                )
              : FooterIcon(
                onTap: () {
                  // showCupertinoModalBottomSheet(
                  //   context: context, 
                  //   builder: (context) => CreateWorkspaceModal(
                  //     onDone: (workspace) => model.createNewFolder(context, workspace.title!))
                  //   );
                },
                icon: Symbols.filter_list_alt_rounded, 
                color: color, 
                size: 30
              ),
              _buildResourceCounts(context, model),
              FooterIcon(
                onTap: model.createNewTab,
                icon: Symbols.add_box, 
                color: color, 
                size: 30
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildSelectionFooter() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            GestureDetector(
              onTap: () => showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) {
                  return MoveToSpaceModal(
                    workspaceViewModel: model,
                    onSpaceSelected: (workspace) => null,
                  );
                }
              ),
              child: Text('Move',
                style: TextStyle(
                  fontSize: 20
                ),
              )
            ),
            GestureDetector(
              onTap: () => showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) {
                  return EditBookmarkModal(workspaceViewModel: model);
                }
              ),
              child: Text('Save',
                style: TextStyle(
                  fontSize: 20
                ),
              )
            ),
            GestureDetector(
              onTap: () => model.closeSelectedTabs(),
              child: Text('Close', 
                style: TextStyle(
                  fontSize: 20
                ),
              )
            ),
        ],
      );
  }

  Widget _buildResourceCounts(BuildContext context, WorkspaceViewModel model) {
    final tabCount = model.tabs.length;
    return tabCount > 0 
    ? Row(
      children: [
        Text('${tabCount} Tab${tabCount > 1 ? 's' : ''}')
      ]
    )
    : Container();
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
        child: Icon(icon, size: size, color: color, weight: 300,),
      ),
    );
  }
}


class SaveSpaceButton extends StatelessWidget {
  final WorkspaceViewModel model;
  const SaveSpaceButton({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    return GestureDetector(
      onTap: () {
        showCupertinoModalBottomSheet(
          context: context, 
          builder: (context) => CreateWorkspaceModal(
            initialTitle: model.tabs[0].model.resource.title,
            //initialColor: spaceColor,
            onDone: (workspace) {
              model.saveSpace(workspace);
              Navigator.pop(context);
              context.read(homeViewProvider).refreshData();
            }
          )
        );
      },
      child: Padding(
        padding: EdgeInsets.all(0.0),
        child: Icon(Symbols.create_new_folder, 
          color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!), 
          weight: 300, 
          size: 30,
          fill: 1,
        ),
      ),
    );
  }
}



