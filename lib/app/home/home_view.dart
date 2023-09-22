import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/freeze_container.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_modal.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/routing/app_router.dart';
import '../common_widgets/section_header.dart';
import 'home_view_model.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(homeViewProvider);
  
    return Scaffold(
      backgroundColor: Colors.black,
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
                  if (model.recentSpaces.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Recent',
                      trailing: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                        child: Text('Show More',
                          style: TextStyle(
                            fontSize: 14,
                            //fontWeight: FontWeight.w300,
                          ),
                        ),

                      ),
                    )
                  ),
                  SliverList.builder(
                    itemCount: model.recentSpaces.length,
                    itemBuilder: (context, index) {
                      final workspace = model.recentSpaces[index];
                      return WorkspaceListItem(
                        key: Key(workspace.id),
                        isFirstListItem: index == 0,
                        isLastListItem: index == model.recentSpaces.length - 1,
                        workspace: workspace,
                        togglePin: (context) => model.toggleWorkspacePinned(workspace),
                        onTap: () => model.openWorkspace(context, workspace),
                        onDelete: () => model.deleteWorkspace(context, workspace),
                      );
                    }
                  ),
                  if (model.recentSpaces.isNotEmpty) 
                  SliverPadding(padding: EdgeInsets.only(bottom: 10)),
                  if (model.favorites.length > 0)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Favorites',
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
                  // SliverToBoxAdapter(
                  //   child: SectionHeader(
                  //     title: 'All Spaces',
                  //     isCollapsed: model.showAllSpaces,
                  //     onToggleCollapse: () => model.setShowAllSpaces(!model.showAllSpaces),
                  //   )
                  // ),
                  // if (model.showAllSpaces)
                  // SliverList.builder(
                  //   itemCount: model.workspaces.length,
                  //   itemBuilder: (context, index) {
                  //     final workspace = model.workspaces[index];
                  //     return WorkspaceListItem(
                  //       key: Key(workspace.id),
                  //       isFirstListItem: index == 0,
                  //       isLastListItem: index == model.workspaces.length - 1,
                  //       workspace: workspace,
                  //       togglePin: (context) => model.toggleWorkspacePinned(workspace),
                  //       onTap: () => model.openWorkspace(context, workspace),
                  //       onDelete: () => model.deleteWorkspace(context, workspace),
                  //     );
                  //   }
                  // ),

                  SliverToBoxAdapter(child: SizedBox(height: 100),)
                ]
              ),
            ),
            Positioned(
              bottom: 0, 
              left: 0, 
              height: 45, 
              width: MediaQuery.of(context).size.width, 
              child: Footer(model: model)
            ),
          ],
        ),
    );
  }

  Widget _buildTopSection(BuildContext context, HomeViewModel model) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: model.topDomains.length + 1,
        itemBuilder: (context, index) {

          if (index == 0) {
            return SizedBox(width: 10,);
          } else {
            final domain = model.topDomains[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: DomainIcon(
                domain: domain,
                onTap: () => model.createNewTab(context, url: domain.url),
              ),
            );
          }
          
        }
      ),
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
                Material(
                  type: MaterialType.transparency,
                  child: Hero(
                    tag: 'Stash',
                    child: Text('Stash', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                      ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SearchField(
              onTap: () {
                context.read(searchViewProvider).load();
                Navigator.pushNamed(context, AppRoutes.search);
              }, 
              showPlaceholder: true,
            ),
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
    return FreezeContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CreateFolderButton(onTap: () => {
              showCupertinoModalBottomSheet(
                context: context, 
                builder: (context) => CreateWorkspaceModal(
                  onDone: (workspace) => model.createNewWorkspace(context, workspace))
                )
            }),
            CreateTabButton(
              onDoubleTap: () => Navigator.pushNamed(context, AppRoutes.createNewTab),
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
        child: Icon(Symbols.create_new_folder, size: 35.0, weight: 300, color: Colors.amber),
      ),
    );
  }
}

class CreateTabButton extends StatelessWidget {
  const CreateTabButton({Key? key, required this.onTap, required this.onDoubleTap}) : super(key: key);
  
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Padding(
        padding: EdgeInsets.all(5), 
        child: Icon(Symbols.add_box, size: 32.0, weight: 300.0, color: Colors.amber,),
      ),
    );
  }
}

