import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/routing/app_router.dart';
import '../common_widgets/create_new_tab_modal.dart';
import '../common_widgets/section_header.dart';
import 'home_view_model.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(homeViewProvider);
  
    return Scaffold(
      //backgroundColor: Colors.black,
      body: model.isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverToBoxAdapter(child: Header(model: model)),
                  SliverToBoxAdapter(child: _buildTopSection(context, model)),
                  if (model.favorites.length > 0)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Pinned',
                      isCollapsed: model.showFavoriteSpaces,
                      onToggleCollapse: () => model.toggleShowFavorites(),
                    )
                  ),
                  if (model.showFavoriteSpaces && model.favorites.length > 0)
                  SliverList.builder(
                    itemCount: model.favorites.length,
                    itemBuilder: (context, index) {
                      final workspace = model.favorites[index];
                      return WorkspaceListItem(
                        key: Key(workspace.id),
                        isFirstListItem: index == 0,
                        isLastListItem: index == model.favorites.length - 1,
                        workspace: workspace,
                        togglePin: (context) => model.toggleWorkspacePinned(workspace),
                        onTap: () => model.openWorkspace(context, workspace),
                        onDelete: () => model.deleteWorkspace(context, workspace),
                      );
                    }
                  ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'All Spaces',
                      isCollapsed: model.showAllSpaces,
                      onToggleCollapse: () => model.setShowAllSpaces(!model.showAllSpaces),
                    )
                  ),
                  if (model.showAllSpaces)
                  SliverList.builder(
                    itemCount: model.workspaces.length,
                    itemBuilder: (context, index) {
                      final workspace = model.workspaces[index];
                      return WorkspaceListItem(
                        key: Key(workspace.id),
                        isFirstListItem: index == 0,
                        isLastListItem: index == model.workspaces.length - 1,
                        workspace: workspace,
                        onTap: () => model.openWorkspace(context, workspace),
                        onDelete: () => model.deleteWorkspace(context, workspace),
                      );
                    }
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 100),)
                ]
              ),
            ),
            Positioned(
              bottom: 0, 
              left: 0, 
              height: 40, 
              width: MediaQuery.of(context).size.width, 
              child: Footer(model: model)
            ),
          ],
        ),
    );
  }

  Widget _buildTopSection(BuildContext context, HomeViewModel model) {
    return Column(
      children: [
        SectionListItemContainer(
          isFirstListItem: true, 
          isLastListItem: false,
          onTap: model.openLooseTabs(context),
          child: ListItem(
            title: 'Miscellaneous',
            icon: Icon(Icons.category, 
              color: Colors.amber,
              size: 28,
            ),
          )
        ),
        SectionListItemContainer(
          isFirstListItem: false, 
          isLastListItem: true,
          onTap: () => model.openPublicWorkspaces(context),
          child: ListItem(
            title: 'Public',
            icon: Icon(Icons.public, 
              color: Colors.amber,
              size: 28,
            ),
          )
        ),
      ],
    );
  }
}




class Header extends StatelessWidget {
  const Header({Key? key, required this.model}) : super(key: key);
  final HomeViewModel model;
  
  @override
  Widget build(BuildContext context) {
    return  Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'Stash',
                  child: Text('Stash', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                    ),
                  ),
                ),
                // Text('Edit',
                //   style: TextStyle(
                //     color: Colors.blueAccent,
                //     fontSize: 20
                //   ),
                // )
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.search),
            child: SearchField()
          ),
        ],
      ),
    );

  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key, required this.model}) : super(key: key);

  final HomeViewModel model;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex('222222').withOpacity(0.9),
        border: Border(
          top: BorderSide(
            width: 0.5,
            color: HexColor.fromHex('333333'), 
            style: BorderStyle.solid, 
            )
          ),
          
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CreateFolderButton(onTap: () => {
              showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) => CreateWorkspaceModal(model: model))
            }),
            CreateTabButton(
              onLongPress: () => showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) => CreateNewTabModal()
              ),
              onTap:() =>  model.createNewTab(context)
            ),
          ],
        ),
      ),
    );
  }
}

class CreateFolderButton extends StatelessWidget {
  const CreateFolderButton({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(5), 
        child: Icon(Icons.create_new_folder_outlined, size: 28.0, weight: 10, color: Colors.amber),
      ),
    );
  }
}

class CreateTabButton extends StatelessWidget {
  const CreateTabButton({Key? key, required this.onTap, required this.onLongPress}) : super(key: key);
  
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.all(5), 
        child: Icon(Icons.add_box_outlined, size: 28.0, weight: 100.0, color: Colors.amber,),
      ),
    );
  }
}

