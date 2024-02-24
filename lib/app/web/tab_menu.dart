import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/freeze_container.dart';
import 'package:stashmobile/app/modals/edit_bookmark/edit_bookmark.dart';
import 'package:stashmobile/app/modals/move_tabs/move_tabs_modal.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/routing/app_router.dart';

class TabMenu extends StatefulWidget {
  const TabMenu({Key? key, 
    required this.resource, 
    required this.workspaceModel
  }) : super(key: key);

  final Resource resource;
  final WorkspaceViewModel workspaceModel;

  @override
  State<TabMenu> createState() => _TabMenuState();
}

class _TabMenuState extends State<TabMenu> {
  /*


    top level option
    - Home
    - Search
    - Favorites 
    - tab previews
    - Reading list
    - Settings

    Reload
    Go Back 
    Go Forward
    Duplicate
    Pin? 
    

    New tab
    New incognito tab
    New space
    Move tab
    Save tab/edit bookmark

    read aloud

    find on page
    share 


    settings

  */
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height * .50,
        color: HexColor.fromHex('111111'),
        // decoration: BoxDecoration(
        //   color: Colors.black,
        // ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: CustomScrollView(
            slivers: [
              // SliverToBoxAdapter(
              //   child: _buildTabInfo(),
              // ),
              SliverPadding(padding: const EdgeInsets.only(top: 20,)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: _buildTabActions(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: _buildBookmarkActions(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: _buildAdditionalActions(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FavIcon(resource: widget.resource,)
            ),
            Expanded(
              child: Text(widget.resource.title ?? '', 
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  fontSize: 16,  
                  overflow: TextOverflow.ellipsis),
                ),
              ),
            if (widget.resource.isSaved == true) 
            Icon(Icons.bookmark_outline),
          ],
        ),
        Text(widget.resource.url!,
          style: TextStyle(
            fontSize: 16,
          ),
          maxLines: 2,
        )
      ],
    );
  }

  Widget _buildTabActions() {
    return SectionContainer(
      child: Column(
        children: [
          MenuItem(
            title: 'Reload', 
            icon: Symbols.replay,
            onTap: () {
              Navigator.of(context).pop();
              widget.workspaceModel.reloadTab(widget.resource);       
            } ,
          ),
          
          MenuItem(
            title: 'New Tab', 
            icon: Symbols.add_box,
            onTap: () => widget.workspaceModel.createNewTab(),
          ),
          MenuItem(
            title: 'New Incognito Tab', 
            icon: Symbols.visibility_off,
            onTap: () => widget.workspaceModel.createNewTab(incognito: true),
          ),
           MenuItem(
            title: 'New Space', 
            icon: Symbols.new_window,
            onTap: () => context.read(windowsProvider).openWorkspace(null),
            showBottomBorder: false,
          )
        ],
      )
    );
  }

  Widget _buildBookmarkActions() {
    return SectionContainer(
      child: Column(
        children: [
          MenuItem(
            title: 'Move Tab', 
            icon: Symbols.move_item,
            onTap: () => showCupertinoModalBottomSheet(
              context: context, 
              builder: (context) {
                return MoveToSpaceModal(
                  resource: widget.resource,
                  onSpaceSelected: (space) => widget.workspaceModel.removeTab(widget.resource), 
                  workspaceViewModel: widget.workspaceModel
                );
              }
            ),
          ),

          !widget.resource.isSaved 
          ? MenuItem(
            title: 'Save Tab', 
            icon: Symbols.star_border,
            onTap: () => widget.workspaceModel.saveTab(widget.resource),
          ) 
          : MenuItem(
            title: 'Edit Bookmark', 
            icon: Icons.star_rounded,
            onTap: () => showCupertinoModalBottomSheet(
              context: context, 
              builder: (context) {
                return EditBookmarkModal(
                  resource: widget.resource, 
                  workspaceViewModel: widget.workspaceModel,
                );
                //return MoveToFolderModal(resource: resource, onFolderSelected: (_) => null,);
              }
            ),
          ),
          MenuItem(
            title: 'Share', 
            icon: Symbols.ios_share,
            onTap: () => widget.workspaceModel.onShare(widget.resource),
          ),
          !widget.workspaceModel.activeTabHasSavedDomain
          ? MenuItem(
            title: 'Add to Favorite Domains', 
            icon: Symbols.ev_shadow_add,
            onTap: () => widget.workspaceModel.addDomain(widget.resource),
            showBottomBorder: false,
          )
          : MenuItem(
            title: 'Remove from Favorite Domains', 
            icon: Symbols.ev_shadow_minus,
            onTap: () => widget.workspaceModel.removeDomain(widget.resource),
            showBottomBorder: false,
          )
           
        ],
      )
    );
  }

  Widget _buildAdditionalActions() {
    return SectionContainer(
      child: Column(
        children: [
          MenuItem(
            title: 'Remove Elements', 
            icon: Symbols.remove_selection_rounded,
            onTap: () {
              Navigator.of(context).pop();
              widget.workspaceModel.setEditMode(true);
            },
            showBottomBorder: false,
          ),
        ],
      )
    );
  }


}

class SectionContainer extends StatelessWidget {
  final Widget child;
  const SectionContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: HexColor.fromHex('333333')
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onTap;
  final showBottomBorder;
  const MenuItem({
    Key? key,
    required this.title, 
    required this.icon,
    this.onTap,
    this.showBottomBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          border: showBottomBorder 
            ? Border(bottom: BorderSide(color: HexColor.fromHex('555555'), width: 0.5)) 
            : null
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                )
              ),
              Icon(icon)
            ],
          ),
        ),
      ),
    );
  }
}


