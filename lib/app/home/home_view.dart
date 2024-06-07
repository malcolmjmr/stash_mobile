import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
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
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/constants/color_map.dart';
import 'package:stashmobile/extensions/color.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/models/workspace.dart';
import 'package:stashmobile/routing/app_router.dart';
import '../common_widgets/section_header.dart';
import 'home_view_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(homeViewProvider);
    final windows = watch(windowsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: model.isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : Stack(
          fit: StackFit.expand,
          children: [
            CustomScrollView(
              scrollBehavior: CupertinoScrollBehavior(),
              //controller: ScrollController().,
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(child: Header(model: model)),
                if (windows.workspaces.length > 1)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Open',
                    trailing: GestureDetector(
                      onTap: () => windows.closeAll(),
                      child: Text('Close All',
                        style: TextStyle(
                          fontSize: 14,
                          //fontWeight: FontWeight.w300,
                        ),
                      ),
            
                    ),
                  )
                ),
                if (windows.workspaces.length > 1)
                SliverList.builder(
                  itemCount: windows.workspaces.length - 1,
                  itemBuilder: (context, index) {
                    final workspaceModel = windows.workspaces[index].model;
                    if (workspaceModel.workspaceIsSet) {
                       final workspace = workspaceModel.workspace;
                       return WorkspaceListItem(
                        key: Key(workspace.id + workspace.updated.toString()),
                        isFirstListItem: index == 0,
                        isLastListItem: index == windows.workspaces.length - 2,
                        workspace: workspace,
                        togglePin: (context) => model.toggleWorkspacePinned(workspace),
                        onTap: () => model.openWorkspace(context, workspace),
                        onDelete: () => model.deleteWorkspace(context, workspace),
                      );
                    } else {
                      return Container();
                    }
                   
                  }
                ),
                if (windows.workspaces.length > 1)
                SliverPadding(padding: EdgeInsets.only(bottom: 15)),
            
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
                // SliverPadding(padding: EdgeInsets.only(bottom: 10)),
                // if (model.tags.isNotEmpty)
                // SliverToBoxAdapter(
                //   child: SectionHeader(
                //     title: 'Tags',
                //     isCollapsed: model.showTags,
                //     onToggleCollapse: () => model.toggleShowTags(),
                //   )
                // ),
                // if (model.showTags && model.tags.isNotEmpty)
                // SliverToBoxAdapter(
                //   child: _buildTags(context, model),
                // ),
            
                SliverPadding(padding: EdgeInsets.only(bottom: 10)),
                if (model.highlightedResources.isNotEmpty)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Reflect',
                    actions: [
                      if (model.hasFavorites)
                      GestureDetector(
                        onTap: () => model.setVisibleHighlights(HighlightType.favorite),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(Symbols.favorite_rounded, 
                            size: 23, 
                            weight: 500,
                            fill: model.visibleHighlightType == HighlightType.favorite ? 1 : 0,
                          ),
                        ),
                      ),
                      if (model.hasLikes)
                      GestureDetector(
                        onTap: () => model.setVisibleHighlights(HighlightType.like),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(Symbols.thumb_up_rounded, 
                            size: 23, 
                            weight: 500,
                            fill: model.visibleHighlightType == HighlightType.like ? 1 : 0,
                          ),
                        ),
                      ),
                      if (model.hasDislikes)
                      GestureDetector(
                        onTap: () => model.setVisibleHighlights(HighlightType.dislike),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(Symbols.thumb_down_rounded, 
                            size: 23, 
                            weight: 500,
                            fill: model.visibleHighlightType == HighlightType.dislike ? 1 : 0,
                          ),
                        ),
                      ),
                      if (model.hasQuestions)
                      GestureDetector(
                        onTap: () => model.setVisibleHighlights(HighlightType.question),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: model.visibleHighlightType == HighlightType.question ? Colors.white : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Icon(Symbols.question_mark_rounded, 
                              size: 20, 
                              weight: 500,
                              color: model.visibleHighlightType == HighlightType.question ? Colors.black : null,
                              //fill: model.visibleHighlightType == HighlightType.question ? 1 : 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                    trailing: GestureDetector(
                      onTap: () => model.shuffleHighlights(),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(Symbols.refresh, 
                          size: 23, 
                          weight: 500,
                        ),
                      ),
                    ),
                  )
                ),
                if (model.highlightedResources.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildHighlights(context, model),
                ),

                if (model.journeys.isNotEmpty)
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Explore',
                    actions: [
                      
                    ],
                    trailing: GestureDetector(
                      onTap: () => model.getJourneys(override: true),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(Symbols.refresh, 
                          size: 23, 
                          weight: 500,
                        ),
                      ),
                    ),
                  )
                ),
                if (model.journeys.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildJourneys(context, model),
                ),
                
                SliverToBoxAdapter(child: SizedBox(height: 100),)
              ]
            ),
            Positioned(
              bottom: 0, 
              left: 0, 
              height: 50, 
              width: MediaQuery.of(context).size.width, 
              child: Footer(model: model)
            ),
          ],
        ),
    );
  }

 

  Widget _buildTags(BuildContext context, HomeViewModel model) {
    model.tags.shuffle();
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
            children: model.tags.sublist(0, 20).map(
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

  Widget _buildJourneys(BuildContext context, HomeViewModel model) {
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(8),
        //color: HexColor.fromHex('222222')
      ),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: model.journeys.length,
            itemBuilder: (context, index) {
              final journey = model.journeys[index];
              return _buildJourneyCard(context, model, journey);
            },
          )
        ),
    );
  }

  Widget _buildJourneyCard(BuildContext context, HomeViewModel model, HomeJourney journey,) {
    final _random = new Random();
    return GestureDetector(
      onTap: () => model.openJourney(context, journey),
      onLongPress: () => model.openJourney(context, journey, searchHighlight: true),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
        
          width: MediaQuery.of(context).size.width * .6,
          decoration: BoxDecoration(
            color: HexColor.fromHex(colorMap.values.toList()[_random.nextInt(colorMap.length - 1)]),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Text(journey.title,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: ()  {
                    final resource = model.data.resources
                        .firstWhere((r) => r.id == journey.resourceId);
                    model.expandHighlight(context, 
                      resource: resource, 
                      highlightId: journey.highlightId
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      //color: HexColor.fromHex('666666'),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Symbols.expand_content_rounded,
                        color: Colors.black,
                        size: 25,
                        fill: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => model.openJourney(context, journey, play: true),
                  onLongPress: () => model.openJourney(context, journey, play: true, searchHighlight: true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor.fromHex('666666'),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Symbols.play_arrow,
                        color: Colors.black,
                        size: 25,
                        fill: 1,
                      ),
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

  Widget _buildHighlights(BuildContext context, HomeViewModel model) {
    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(8),
        //color: HexColor.fromHex('222222')
      ),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: model.highlightedResources.length,
            itemBuilder: (context, index) {
              final resource = model.highlightedResources[index];
              return Center(child: ResourceWithHighlights(resource: resource, key: Key(resource.id!)));
            },
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

    final dot = Expanded(
      child: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100)
              ),
              height: 3,
              width: 3,
            ),
          ),
        ),
      ),
    );


    return  Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  type: MaterialType.transparency,
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
                
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0, right: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(100)
                      ),
                      height: 25,
                      width: 25,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Row(
                          children: [
                            dot,
                            dot, 
                            dot,
                          ],
                        )
                      ),
                    ),
                  ),
                ),
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


class ResourceWithHighlights extends StatefulWidget {

  final Resource resource;
  //final String highlightId;
  const ResourceWithHighlights({Key? key, 
    required this.resource,
    // required this.highlightId,
    this.isSelected = false, 
    this.isExpanded = false,
    this.highlightId,
  }) : super(key: key);

  final bool isSelected;
  final bool isExpanded;
  final String? highlightId;
  

  @override
  State<ResourceWithHighlights> createState() => _ResourceWithHighlightsState();
}

class _ResourceWithHighlightsState extends State<ResourceWithHighlights> {

  int highlightIndex = 0;
  
  late Highlight highlight;
  late HomeViewModel homeViewModel;
  late Workspace? workspace;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    homeViewModel = context.read(homeViewProvider);
    highlightIndex = widget.resource.highlights.indexWhere((h) {
      if (widget.highlightId != null) return h.id == widget.highlightId;
      if (homeViewModel.visibleHighlightType == HighlightType.favorite && h.favorites > 0) {
        return true;
      } else if (homeViewModel.visibleHighlightType == HighlightType.like && h.likes > 0) {
        return true;
      } else if (homeViewModel.visibleHighlightType == HighlightType.dislike && h.dislikes > 0) {
        return true;
      } else if (homeViewModel.visibleHighlightType == HighlightType.question && h.hasQuestion) {
        return true;
      } else {
        return false;
      }
    });

    highlight = widget.resource.highlights[highlightIndex];

    workspace = homeViewModel.data.workspaces.firstWhereOrNull((w) => widget.resource.contexts.contains(w.id));
  }


  @override
  Widget build(BuildContext context) {

    /*
      selected
    */
  final highlight =  widget.resource.highlights[highlightIndex];
  
    return !widget.isExpanded 
      ? Column(
        children: [
          GestureDetector(
            onTap: () => homeViewModel.expandHighlight(context, resource: widget.resource, highlightId: highlight.id!),
            onDoubleTap: () => homeViewModel.openResource(context, widget.resource),
            onLongPress: () => homeViewModel.createJourneyFromHighlight(context, resource: widget.resource, highlightId: highlight.id!),
            child: _buildCard(highlight: highlight, workspace: workspace)
          ),
          Expanded(
            child: Container(),
          ),
        ],
      )
      : _buildCard(highlight: highlight, workspace: workspace);
  }

  Widget _buildCard({Workspace? workspace, required Highlight highlight}) {
    return Hero(
        tag: highlight.text,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: widget.isExpanded 
              ? const EdgeInsets.all(0)
              : const EdgeInsets.only(left: 5.0, right: 10),
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              decoration: BoxDecoration(
                color: HexColor.fromHex(colorMap[workspace?.color] ?? '222222'),
                borderRadius: BorderRadius.circular(8),
                border: widget.isExpanded
                  ? Border.all(color: Colors.black, width: 2)
                  : null
              ),
              
              child: widget.isExpanded 
                ? Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                      ),
                      child: Column(
                        children: [
                          _buildTitle(),
                          _buildTags(),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView(
                          children: [
                            _buildHighlight(),
                          ],
                        ),
                      ),
                    ),

                    _buildHighlightLabelOptions(highlight),
                    
                  ],
                )
                : _buildHighlight(),
            ),
          ),
        ),
      );
  }

    Widget _buildHighlightLabelOptions(Highlight highlight) {

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 2))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildLabelButton(
              title: 'Favorite', 
              icon: Symbols.favorite, 
              onLongPress: () {
                setState(() {
                  highlight.favorites = 0;
                  homeViewModel.data.saveResource(widget.resource);
                });
                
              },
              onTap: () {
                setState(() {
                  highlight.favorites += 1;
                  homeViewModel.data.saveResource(widget.resource);
                });
              },
              isFilled: highlight.favorites > 0
            ),
          ),
          Expanded(
            child: _buildLabelButton(
              title: 'Like', 
              icon: Symbols.thumb_up_rounded, 
              onLongPress: () {
                setState(() {
                  highlight.likes = 0;
                  homeViewModel.data.saveResource(widget.resource);
                });
              },
              onTap: () {
                setState(() {
                  highlight.likes += 1;
                  homeViewModel.data.saveResource(widget.resource);
                });
              },
              isFilled: highlight.likes > 0
            ),
          ),
          Expanded(
            child: _buildLabelButton(
              title: 'Dislike', 
              icon: Symbols.thumb_down_rounded, 
              onLongPress: () {
                setState(() {
                  highlight.dislikes = 0;
                  homeViewModel.data.saveResource(widget.resource);
                });
                
              },
              onTap: () {
                setState(() {
                  highlight.dislikes += 1;
                  homeViewModel.data.saveResource(widget.resource);
                });
                
              },
              isFilled: highlight.dislikes > 0,
            ),
          ),
          Expanded(
            child: _buildLabelButton(
              title: 'Funny', 
              icon: Symbols.sentiment_excited_rounded, 
              onLongPress: () {
                setState(() {
                  highlight.laughs = 0;
                  homeViewModel.data.saveResource(widget.resource);
                });
                
              },
              onTap: () {
                setState(() {
                  highlight.laughs += 1;
                  homeViewModel.data.saveResource(widget.resource);
                });
              },
              isFilled: highlight.laughs > 0
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelButton({
    required String title, 
    required IconData icon, 
    required Function() onTap,
    Function()? onLongPress,
    String? workspaceColor,
    bool? useTitle,
    bool isFilled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: HexColor.fromHex(colorMap[workspace?.color ?? 'grey']!)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(icon, size: 25, color: Colors.black, fill: isFilled ? 1 : 0,),
                if (useTitle == true)
                Text(title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlight() {
    final highlight = widget.resource.highlights[highlightIndex];
    return GestureDetector(
      // onTap: () => homeViewModel.openResource(context, widget.resource, 
      //   highlightId: highlight.id,
      // ), 
      onDoubleTap: () => null, // searchRelated 
      onLongPress: () => null , // openNote
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Container(
          //height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(8),
            //color: HexColor.fromHex('hexString')
          ),
          child: Padding(
            padding: widget.isExpanded ? const EdgeInsets.only(top: 3) : const EdgeInsets.all(8),
            child: Container(
              child: Text(highlight.text,
                maxLines: widget.isExpanded ? null : 10,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: widget.isExpanded ? 20 : 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return GestureDetector(
      onTap: () => homeViewModel.openResource(context, widget.resource),
      child: Container(
       
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Container(
            height: 30,
            child: Row(
              children: [
                if (widget.resource.favIconUrl != null) 
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: widget.resource.favIconUrl != null
                    ? FavIcon(resource: widget.resource, size: 24,)
                    : SizedBox.shrink(),
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [Center(
                      child: Text(widget.resource.title ?? 'Untitled',
                        style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),]
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );

  }


  Widget _buildTags() {
    final highlightText = highlight.text.toLowerCase();
    final highlightTags = widget.resource.tags
      .where((tagName) => highlightText.contains(tagName.substring(0, min(4, tagName.length))) );
    final otherTags = widget.resource.tags
      .where((tagName) => !highlightText.contains(tagName.substring(0, min(4, tagName.length))) );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 30,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(width: 10,),
            ...highlightTags.map((tagName) => _buildTag(tagName)),
            ...otherTags.map((tagName) => Opacity(opacity: 0.7, child: _buildTag(tagName)))
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tagName, {bool isSelected = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: TagChip(
          isSelected: isSelected,
          fontColor: Colors.black,
          backgroundColor: HexColor.fromHex(colorMap['grey']!),
          tag: Tag(name: tagName),
          onTap: () => null,
        ),
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
            color: HexColor.fromHex('333333'), 
            width: 1
          )
        )
      ),
      child: PageView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Expanded(child: Container(),),
                // CreateButton(
                //   icon: Symbols.forum_rounded,
                //   size: 28,
                //   onTap: () => null, 
                //   onDoubleTap: () => null
                // ),
                CreateButton(
                  icon: Symbols.create_new_folder_rounded,
                  fill: 1,
                  size: 36,
                  //padding: EdgeInsets.symmetric(horizontal: 50),
                  onDoubleTap: () => null,
                  onTap:() =>  model.showCreateWorkspaceModal(context),
                ),
                CreateButton(
                  icon: Symbols.add_box_rounded,
                  fill: 1,
                  size: 36,
                  //padding: EdgeInsets.symmetric(horizontal: 50),
                  onDoubleTap: () => Navigator.pushNamed(context, AppRoutes.createNewTab),
                  onTap:() =>  model.createWindow(context),
                ),
                // CreateButton(
                //   icon: Symbols.edit_document,
                //   size: 26,
                //   onTap: () => null, 
                //   onDoubleTap: () => null, 
                // ),
                //Expanded(child: Container(),),
                //CreateButton(onTap: () => null, onDoubleTap: () => null, icon: Symbols.edit_square, padding: EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 10),),

              ],
            ),
          ),
          Expanded(child: _buildCreateOptions(context, model)),
        ],
      ),
    );
  }

  Widget _buildCounts(BuildContext context, HomeViewModel model) {
    final color = HexColor.fromHex('999999');
    final textStyle = TextStyle(
      fontSize: 14,
      color: color
    );

    var f = NumberFormat("###,###", "en_US");
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text(f.format(model.workspaceCount) + ' Spaces',
          //   style: textStyle,
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Container(
          //     height: 5,
          //     width: 5,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(100),
          //       color: color,
          //     ),
          //   ),
          // ),
          // Text(
          //   f.format(model.tabCount) + ' Tabs',
          //   style: textStyle,
          // )
        ],
      ),
    );
  }

   Widget _buildCreateOptions(BuildContext context, HomeViewModel model) {
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
                  onTap: () => model.createWindow(context, domain: domain),
                  onLongPress: () => model.createWindow(context, domain: domain, isIncognito: true),
                ),
              ),
            );
          }
          
        }
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
        child: Icon(Symbols.create_new_folder, size: 35.0, weight: 300, color: HexColor.fromHex('999999'),),
      ),
    );
  }
}

class CreateButton extends StatelessWidget {
  const CreateButton({
    Key? key, 
    required this.onTap, 
    required this.onDoubleTap, 
    required this.icon, 
    this.padding = const EdgeInsets.all(5),
    this.size = 32,
    this.fill = 0,
  }) : super(key: key);
  
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final IconData icon;
  final EdgeInsets padding;
  final double size;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Padding(
        padding: padding, 
        child: Icon(icon, 
          size: size, 
          weight: 400.0, 
          color: HexColor.fromHex(colorMap['grey']!),
          fill: fill,
          //color: HexColor.fromHex('999999')
        ),
      ),
    );
  }
}

