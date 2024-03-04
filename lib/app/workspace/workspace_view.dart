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
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:ionicons/ionicons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/common_widgets/drop_down_menu.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/home_icon.dart';
import 'package:stashmobile/app/common_widgets/modal_container.dart';
import 'package:stashmobile/app/common_widgets/new_folder_dialog.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_header.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
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
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/space_list_item.dart';
import 'package:stashmobile/app/workspace/resource_list_item.dart';
import 'package:stashmobile/app/workspace/tab_list_item.dart';
import 'package:stashmobile/app/workspace/workspace_menu.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';
//import 'package:material_symbols_icons/symbols.dart';

import '../../models/resource.dart';

class WorkspaceView extends StatefulWidget {

  //final WorkspaceViewParams? params;
  final bool  showWebView;
  WorkspaceView({Key? key, required this.model, this.showWebView = false, }) : super(key: UniqueKey());
  final WorkspaceViewModel model; 

  @override
  State<WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> with AutomaticKeepAliveClientMixin {

  late WorkspaceViewModel model; 


  bool showTabs = true;
  bool showFolders = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    model = widget.model;
    model.init(
      context,
      setState,
    );
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: !model.isLoading
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(vertical: BorderSide(color: HexColor.fromHex('222222'), width: .5))
              ),
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
            //mainAxisAlignment: model.showToolbar ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.end,
            children: [
              KeyboardVisibilityBuilder(
                builder: (context, isVisible) => isVisible 
                  ? Container()
                  : WorkspaceHeader(model: model)
              ),

              Expanded(
                
                child: Container(
                  //height: MediaQuery.of(context).size.height - (model.showToolbar ?  160 : 0),
                  child: IndexedStack(
                    index: model.workspace.activeTabIndex,
                    children: model.tabs
                  )
                ),
              ),
              KeyboardVisibilityBuilder(
                builder: (context, isVisible) {
                  return isVisible ? Container() : TabBottomBar(model: model);
                }
              )
                

            ],
          ),
          if (model.showFindInPage)
          FindInPage(model: model),

        ],
      ),
    );
  }


  Widget _buildWorkspaceView() {
    return Stack(
      children: [
        _buildScrollView(),
        Positioned(
          height: 51,
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
      controller: model.scrollController,
      slivers: [

        SliverAppBar(
          title: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: model.showCollapsedHeader || model.workspace.title == null
                ? Border(
                    bottom:  BorderSide(color: HexColor.fromHex('333333'))  
                )
                :  null
            ),
            child: WorkspaceHeader(model: model),
          ),
          automaticallyImplyLeading: false,
          pinned: true,
          leadingWidth: 0,
          leading: null,
          backgroundColor: Colors.black,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          expandedHeight: 0,
          toolbarHeight: 52,
          forceMaterialTransparency: true,
          titleSpacing: 0,
        ),

        if (model.workspace.title != null)
        SliverAppBar(
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SearchField(
              showPlaceholder: true,
              onTap: () {
                context.read(searchViewProvider).initBeforeNavigation();
                Navigator.pushNamed(context, AppRoutes.search);
              }
            ),
          ),
          automaticallyImplyLeading: false,
          floating: true,
          leadingWidth: 0,
          leading: null,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          expandedHeight: 0,
          toolbarHeight: 50,
          forceMaterialTransparency: true,
        ),


        // if (model.workspace.title != null)
        // SliverToBoxAdapter(
        //   child: _buildExpandedHeader(),
        // ),


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
          
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Wrap(
                runAlignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...model.tabs.map((tab) =>  
                    TabPreview(
                      tab: tab.model.resource, 
                      showSelectionToggle: model.selectedResources.length > 0,
                      isSelected: model.selectedResources.contains(tab.model.resource.id),
                      toggleSelection: () => model.toggleResourceSelection(tab.model.resource),
                      open: () => model.openTab(tab.model.resource),
                      close: () => model.closeTab(tab.model.resource),
                    )
                  ).toList(),
                  Container()
                ]
              ),
            ),
          ),
        ),

        
        if (model.visibleResources.isNotEmpty || model.selectedTags.isNotEmpty)
         SliverAppBar(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: HexColor.fromHex('222222'))),
                color: Colors.black,
              ),
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _buildListOptions(),
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          pinned: true,
          leadingWidth: 0,
          leading: null,
          backgroundColor: Colors.black,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          expandedHeight: 0,
          toolbarHeight: 60,
          forceMaterialTransparency: true,
          titleSpacing: 0,
        ),

        if (model.resourceView == ResourceView.tagged) 
        SliverToBoxAdapter(
          child: _buildTags(),
        ),

        if (model.visibleResources.isNotEmpty && model.resourceView != ResourceView.folders)
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

        if (model.resourceView == ResourceView.tagged)
        SliverToBoxAdapter(
          child: _buildSearchRelatedContentButton()
        ),
        
        if (model.resourceView == ResourceView.folders) 
        SliverList.builder(
          itemCount: model.folders.length,
          itemBuilder: ((context, index) {
            final folder = model.folders[index];
            return Padding(
              padding: EdgeInsets.only(
                left: 15.0, 
                right: 15, 
              ),
              child: WorkspaceListItem(
                isFirstListItem: index == 0,
                isLastListItem: index == model.folders.length - 1,
                workspace: folder,
                onTap: () {
                  context.read(windowsProvider).openWorkspace(folder);
                },
              )
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
      Padding(padding: EdgeInsets.only(left: 15)),
      if (model.hasSavedResources)
      _buildListOption(
        icon: Symbols.history,
        text: 'History',
        view: ResourceView.history,
      ),
      if (model.hasFavorites)
      _buildListOption(
        icon: Symbols.favorite,
        text: 'Favorites', 
        view: ResourceView.favorites
      ),
      if (model.folders.isNotEmpty)
      _buildListOption(
        icon: Symbols.folder_rounded,
        text: 'Folders', 
        view: ResourceView.folders,
      ),
      if (model.folders.isNotEmpty)
      _buildListOption(
        icon: Symbols.sell,
        text: 'Tagged', 
        view: ResourceView.tagged,
      ),
      if (model.hasQueue)
      _buildListOption(
        icon: Symbols.inbox,
        text: 'To Visit', 
        view: ResourceView.queue
      ),
    ];
  }

  Widget _buildSearchRelatedContentButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 10, right: 15),
      child: GestureDetector(
        onTap: model.openRelatedContent,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            //color: HexColor.fromHex('333333'),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8)
            )
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(right: 8.0),
                //   child: Icon(Symbols.travel_explore_rounded, size: 30,),
                // ),
                Text('Click for related content',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500
                    
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListOption({ResourceView? view, required String text, IconData? icon}) {
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
                  child: Row(
                    children: [
                      if (icon != null) Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(icon,
                          color: isSelected ? Colors.black : Colors.white,
                          fill: isSelected ? 1 : 0,
                        ),
                      ),
                      Text(text, 
                        style: TextStyle(
                          fontSize: 18,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(8),
          color: HexColor.fromHex('111111'),
          border: Border(
            top: BorderSide(color: HexColor.fromHex('222222')),
            bottom: BorderSide(color: HexColor.fromHex('222222')),
          )
        ),
        //width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              ...model.visibleTags.map((tag) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: TagChip(
                    key: Key(tag.name),
                    tag: tag,
                    selectionColor: HexColor.fromHex(model.workspaceHexColor),
                    isSelected: model.selectedTags.firstWhereOrNull((t) => t.name == tag.name) != null,
                    onTap: () => model.toggleTagSelection(tag),
                  ),
                );
              }).toList(),
              _buildGenerateTagsButton(),
            ]
          ),
        ),
      ),
    );
  }
  
  Widget _buildGenerateTagsButton() {
    return GestureDetector(
      onTap: () => model.generateTerms(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex('333333'),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
            child: Icon(
              Symbols.more_horiz_rounded,
              fill: 1,
              weight: 700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {

    
    return Container(
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
    
    return Container(
       decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: HexColor.fromHex('222222'), 
            width: 1
          )
        )
      ),
      child: model.workspace.title == null 
        ? _buildWindowBottomBar()
        : _buildWorkspaceBottomBar(),
    );
  }

  Widget _buildWindowBottomBar() {
    final color = HexColor.fromHex(model.workspaceHexColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FooterIcon(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            onTap: () => model.clearTabs(),
            icon: Symbols.tab_close,
            color: color, 
            size: 30,
          )
   
        ,
        _buildResourceCounts(context, model),
        FooterIcon(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          onTap: model.createNewTab,
          icon: Symbols.add_box, 
          color: color, 
          size: 30
        ),
      ]
    );
  }

  Widget _buildWorkspaceBottomBar() {
    final color = HexColor.fromHex(model.workspaceHexColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildActiveTabButton(),
        // FooterIcon(
        //   onTap: () => showCupertinoDialog(
        //     context: context, 
        //     builder: (context) {
        //       return NewFolderDialog(
        //         onSave: (title) => model.createNewFolder(context, title),
        //       );
        //     }
        //   ),
        //   icon: Symbols.create_new_folder_rounded,
        //   color: color,
        //   size: 30,

        // ),

        FooterIcon(
          
          onTap: model.createChat,
          icon: Symbols.forum_rounded, 
          color: color, 
          size: 25
        ),

        FooterIcon(
          onTap: model.createNewTab,
          icon: Symbols.add_box, 
          color: color, 
          size: 30
        ),
        FooterIcon(
          onTap: model.createNote,
          icon: Symbols.edit_document, 
          color: color, 
          size: 25
        ),
        FooterIcon(
          padding: EdgeInsets.only(top: 5, bottom: 5, right: 20, left: 10),
          onTap: () => context.read(windowsProvider).openWorkspace(null),
          icon: Symbols.new_window, 
          color: color, 
          size: 25
        ),
      ]
    );
  }

  Widget _buildActiveTabButton() {
    final resource = model.currentTab.model.resource;
    return GestureDetector(
      onTap: () => model.openTab(resource),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 10, top: 5, bottom: 5.0),
        child: Container( 
          child: resource.favIconUrl != null && resource.favIconUrl!.isNotEmpty
            ? FavIcon(resource: resource, size: 25,)
            : Icon(Symbols.tab_rounded, 
              size: 25,
              color: HexColor.fromHex(model.workspaceHexColor),
            )
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
  const FooterIcon({Key? key,
    required this.icon, 
    this.onTap, 
    this.onDoubleTap,
    this.onLongPress,
    this.color = Colors.black, 
    this.size = 30,
    this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  }) : super(key: key);
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final Function()? onLongPress;
  final Function()? onDoubleTap;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Icon(icon, size: size, color: color, weight: 400,),
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

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({Key? key, required this.model}) : super(key: key);
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    final workspaceColor = HexColor.fromHex(model.workspaceHexColor);
    return AnimatedSize(
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 0),
      child: _buildHeader(context),

    );
  }

  Widget _buildHeader(BuildContext context) {

    return Container(
      height: model.workspace.showWebView && (!model.showToolbar || model.workspace.title == null || model.selectedHighlight != null)
        ? 0
        : null,
      decoration: BoxDecoration(
        color: Colors.black,
        // border: !model.workspace.showWebView && model.workspace.title == null 
        //   ? Border(bottom: BorderSide(color: HexColor.fromHex(model.workspaceHexColor), width: 1))
        //   : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 12.0, 
          right: 12.0, 
          top: model.workspace.showWebView ? 10 :  16, 
          bottom: 10
        ),
        child: model.selectedResources.isNotEmpty
          ? _buildSelectionHeader()
          : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildHeaderTitle(),
              model.workspace.title == null 
              ? SaveSpaceButton(model: model,)
              : _buildMoreButton(context),
            ],
          ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, 
        PageTransition<dynamic>(
          type: PageTransitionType.bottomToTop,
          curve: Curves.easeInExpo,
          child: ModalContainer(
            child: WorkspaceMenu(model: model),
          ),
          fullscreenDialog: true,
        )
      ),
      child: Icon(Icons.more_horiz, 
        color: HexColor.fromHex(model.workspaceHexColor)
      ),
    );
  }

  Widget _buildHeaderTitle() {
    final fontSize = 20.0;
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          HomeIcon(
            size: model.workspace.title != null ? 25 : 30,
            padding: EdgeInsets.only(left: 3, right: 5),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Text(model.workspace.title != null 
              ? '/'
              : '', 
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize - 2,
              ),
            ),
          ),
          
          if (model.workspace.parents.isNotEmpty) 
          _buildBreadCrumbIcon(),
          if (model.workspace.title != null)
          Text(model.workspace.title ?? 'Untitled', 
            style: TextStyle(
              color: HexColor.fromHex(colorMap[model.workspace.color ?? 'grey']!),
              fontSize: fontSize,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBreadCrumbIcon() {
    return GestureDetector(
      onTap: () {
        // show path hierarchies
        // what happens when the  
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text('../'),
      ),
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
            color: Colors.white,
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
}



