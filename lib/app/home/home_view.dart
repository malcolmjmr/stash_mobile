import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stashmobile/app/common_widgets/domain_icon.dart';
import 'package:stashmobile/app/common_widgets/fav_icon.dart';
import 'package:stashmobile/app/common_widgets/freeze_container.dart';
import 'package:stashmobile/app/common_widgets/list_item.dart';
import 'package:stashmobile/app/common_widgets/search_field.dart';
import 'package:stashmobile/app/common_widgets/section_list_item.dart';
import 'package:stashmobile/app/common_widgets/tag.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/workspace_listitem.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_modal.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/app/web/tab_preview_modal.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/tag.dart';
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
                  SliverPadding(padding: EdgeInsets.only(bottom: 10)),
                  if (model.tags.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Tags',
                      isCollapsed: model.showTags,
                      onToggleCollapse: () => model.toggleShowTags(),
                    )
                  ),
                  if (model.showTags && model.tags.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildTags(context, model),
                  ),

                  SliverPadding(padding: EdgeInsets.only(bottom: 10)),
                  if (model.highlightedResources.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Highlights',
                    )
                  ),
                  if (model.highlightedResources.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildHighlights(context, model),
                  ),
                  
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
      color: Colors.transparent,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        
        itemCount: model.topDomains.length + 1,
        itemBuilder: (context, index) {

          if (index == 0) {
            return SizedBox(width: 10,);
          } else {
            final domain = model.topDomains[index - 1];
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: DomainIcon(
                  domain: domain,
                  onTap: () => model.createNewTab(context, domain: domain),
                ),
              ),
            );
          }
          
        }
      ),
    );
  }

  Widget _buildTags(BuildContext context, HomeViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: HexColor.fromHex('222222')
      ),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: model.tags.map(
              (tag) => TagChip(
                onTap: () => model.openSearchFromTag(context, tag),
                tag: tag, 
                //isSelected: true,
              )
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildHighlights(BuildContext context, HomeViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: HexColor.fromHex('222222')
      ),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          child: Column(
            children: [
              ...model.highlightedResources.sublist(0, min(20, model.highlightedResources.length)).map((resource) {
                final highlight = resource.highlights[Random().nextInt(resource.highlights.length)];
                return Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height:30,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: resource.tags.length,
                            
                            itemBuilder: (context, index) {
                              final tagName = resource.tags[index];
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: TagChip(
                                    tag: Tag(name: tagName),
                                    onTap: () => null,
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                      Text(highlight.text,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          showCupertinoModalBottomSheet(
                            context: context, 
                            builder: (context) => TabPreviewModal(resource: resource,)
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 30,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FavIcon(resource: resource, size: 24,),
                                ),
                                Expanded(
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [Center(
                                      child: Text(resource.title!,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),]
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Divider(thickness: 1, ),
                      ),
                    ],
                  ),
                );
              }),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: Text('Show All Highlights')),
              )
            ],
          )
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
                context.read(searchViewProvider).initBeforeNavigation();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: HexColor.fromHex('555555'), 
            width: 1
          )
        )
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
        child: Icon(Symbols.create_new_folder, size: 35.0, weight: 300, color: HexColor.fromHex('888888'),),
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
        child: Icon(Symbols.add_box, size: 32.0, weight: 300.0, color: HexColor.fromHex('888888')),
      ),
    );
  }
}

