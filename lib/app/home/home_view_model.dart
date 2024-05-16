
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/home/create_workspace_modal.dart';
import 'package:stashmobile/app/home/expanded_highlight.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/providers/search.dart';
import 'package:stashmobile/app/providers/workspace.dart';
import 'package:stashmobile/app/search/search_view_model.dart';
import 'package:stashmobile/app/web/default_domains.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/routing/app_router.dart';
import 'package:stashmobile/services/llm.dart';

import '../../models/workspace.dart';


final homeViewProvider = ChangeNotifierProvider<HomeViewModel>(
  (ref) => HomeViewModel(ref.read, ref.watch(dataProvider))
);


class HomeViewModel with ChangeNotifier {

  Reader read;
  DataManager data;

  HomeViewModel(this.read, this.data) {
    data = read(dataProvider);
    load();
  }


  load() async {
    await refreshData();
  }

  refreshData() async {
    workspaces = data.workspaces
      .where((Workspace c) => c.isIncognito != true  && c.deleted == null).toList();
    workspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    tabCount = workspaces.fold(0, (total, space) => total + space.tabs.length);
    workspaceCount = workspaces.length;
    
    recentSpaces = workspaces.sublist(0, min(5, workspaces.length));
    favorites = workspaces.where((w) => w.isFavorite == true && w.contexts.isEmpty).toList();
    topDomains = defaultDomains;
    topDomains.shuffle();
    tags = data.tags.where((t) => t.valueCount > 1).toList();
    loadHighlightedResources();

    _setLoading(false);
  }

  loadHighlightedResources() {
    highlightedResources = [];
    for (final resource in data.resources) {
      for (final highlight in resource.highlights) {
        if (!hasFavorites && highlight.favorites > 0) {
          hasFavorites = true;
        } else if (!hasLikes && highlight.likes > 0) {
          hasLikes = true;
        } else if (!hasDislikes && highlight.dislikes > 0) {
          hasDislikes = true;
        } else if (!hasQuestions && highlight.hasQuestion) {
          hasQuestions = true;
        }
      }

      if (hasDislikes && hasLikes && hasFavorites) {
        break;
      }
    }
    highlightedResources.shuffle();
    setVisibleHighlights(
      hasFavorites 
        ? HighlightType.favorite
        : hasLikes
          ? HighlightType.like
            : hasDislikes
              ? HighlightType.dislike
              : hasQuestions 
                ? HighlightType.question
                : null
    );

    
      
  }

  List<Workspace> workspaces = [];
  List<Workspace> favorites = [];
  List<Workspace> recentSpaces = [];
  List<Resource> highlightedResources = [];

  int workspaceCount = 0;
  int tabCount = 0;

  List<Domain> topDomains = [];
  List<Tag> tags = [];

  int sortDomains(Domain a, Domain b) {
    final countComp = b.searchCount - a.searchCount;
    if (countComp != 0) {
      return countComp;
    } 
    final visitComp = (b.lastVisited ?? 0) - (a.lastVisited ?? 0);
    return visitComp;
  }


  bool isLoading = true;
  dynamic error;

  _setLoading(bool value){
    isLoading = value;
    notifyListeners();
  }

  String newWorkspaceTitle = '';
  String? newWorkspaceColor;

  bool showAllSpaces = true;
  setShowAllSpaces(value) {
    showAllSpaces = value;
    notifyListeners();
  }

  bool showFavoriteSpaces = true;
  toggleShowFavorites() {
    showFavoriteSpaces = !showFavoriteSpaces;
    notifyListeners();
  }

  bool showTags = true;
  toggleShowTags() {
    showTags = !showTags;
    notifyListeners();
  }


  openSearchFromTag(BuildContext context, Tag tag) {
    context.read(searchViewProvider).initBeforeNavigation(tags: [tag]);
    Navigator.pushNamed(context, AppRoutes.search);
  }

  createNewWorkspace (BuildContext buildContext,{ Workspace? workspace }) {
    //Workspace workspace = Workspace(title: newWorkspaceTitle, color: newWorkspaceColor);

    if (workspace == null) {
      workspace = Workspace();
    }
    if (workspace.title == null || workspace.title!.isEmpty) return; // need to show error screen
    data.saveWorkspace(workspace);
    read(workspaceProvider).state = workspace.id;
    read(windowsProvider).openWorkspace(workspace);
  }

  showCreateWorkspaceModal(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context, 
      builder: (context) => CreateWorkspaceModal(
        //initialTitle: tabs[0].model.resource.title,
        //initialColor: spaceColor,
        onDone: (workspace) {
          createNewWorkspace(context, workspace: workspace);
          Navigator.pop(context);
          refreshData();
        }
      )
    );
  }

  createWindow(BuildContext buildContext, {String? url, Domain? domain, bool isIncognito = false}) {

    if (domain != null) {
      final uri = Uri.parse(domain.url);
      if (!uri.hasScheme) {
        domain.url = 'https://' + domain.url;
        data.saveDomain(domain);
      }
    }

    buildContext.read(windowsProvider).openWorkspace(null, 
      resource: url != null ? Resource(url: url) : null, 
      isIncognito: isIncognito
    );

  }

  openWorkspace(BuildContext buildContext, Workspace workspace) {
    buildContext.read(workspaceProvider).state = workspace.id;
    buildContext.read(windowsProvider).openWorkspace(workspace);

  }

  toggleWorkspacePinned(Workspace workspace) async {
    workspace.isFavorite = !(workspace.isFavorite == true);
    await data.saveWorkspace(workspace);
    await refreshData();
    notifyListeners();
  }

  deleteWorkspace(BuildContext context, Workspace workspace) {
    data.deleteWorkspace(workspace);
    refreshData();
    Navigator.pop(context);
  }

  openLooseTabs(BuildContext context) {

  }

  openPublicWorkspaces(BuildContext context) {
    
  }


  shuffleHighlights() {
    highlightedResources.shuffle();
    _setLoading(false);
  }

  openResource(BuildContext context, Resource resource, { String? highlightId, String? workspaceId }) {
    /*
        check if workspace is open
        open workspace if not
        move item to workspace 
    */


    final windows = read(windowsProvider);
    WorkspaceView? workspaceView = windows.workspaces.firstWhereOrNull((w) => workspaceId == w.model.workspace.id || resource.contexts.contains(w.model.workspace.id)); 
    if (workspaceView == null) {
      final workspace = data.workspaces.firstWhereOrNull((w) => workspaceId == w.id || resource.contexts.contains(w.id));
      if (workspace != null) {
        windows.openWorkspace(workspace, resource: resource);
      } else {
        // open default workspace 
      }
      
    } else {
      workspaceView.model.openResource(context, resource, highlightId: highlightId);
    }
  }

  expandHighlight(BuildContext context, {required Resource resource, required String highlightId}) {
    Navigator.push(context, 
      PageTransition<dynamic>(
        type: PageTransitionType.fade,
        curve: Curves.easeInExpo,
        child: ExpandedHighlight(resource: resource, highlightId: highlightId)
      )
    );
  }

  createJourneyFromHighlight(BuildContext context, {required Resource resource, required String highlightId}) {
    final text = resource.highlights.firstWhere((h) => h.id == highlightId).text;
    Resource newResource = Resource(
      title: text,
      url: context.read(searchProvider).getExaSearchUrlforResource(
        prompt: 
        ''' Here's a great article related to the following excerpt: 

        ${text}
        '''
        
        
      ),
    );

    //newResource.contexts = resource.contexts;

    openResource(context, newResource, 
      workspaceId: resource.contexts.isNotEmpty 
        ? resource.contexts.first 
        : null
    );
    Navigator.pop(context);

  }

  bool hasFavorites = false;
  bool hasDislikes = false;
  bool hasLikes = false;
  bool hasQuestions = false;

  HighlightType? visibleHighlightType;
  setVisibleHighlights(HighlightType? highlightType) {
    visibleHighlightType = highlightType;
    highlightedResources = data.resources.where((r) {
      if (visibleHighlightType == HighlightType.favorite) {
        return r.highlights.any((h) => h.favorites > 0);
      }
      else if (visibleHighlightType == HighlightType.like) {
        return r.highlights.any((h) => h.likes > 0);
      } else if (visibleHighlightType == HighlightType.dislike){
        return r.highlights.any((h) => h.dislikes > 0);
      } else if (visibleHighlightType == HighlightType.question) {
        return r.highlights.any((h) => h.hasQuestion);
      } else {
        return false;
      }
    }).toList();
    highlightedResources.sort((a, b) => (b.created ?? b.updated ?? 0).compareTo(a.created ?? a.updated ?? 0));
    notifyListeners();
  }


  createNoteFromHighlight(BuildContext context, {required Resource resource, required String highlightId}) {

    Resource note = Resource(
      parentId: resource.id,
      title: 'New Reflection',
      note: Note(
        promptResourceId: resource.id,
        highlightId: highlightId
      )
    );

    //note.contexts = resource.contexts;

    openResource(context, note, workspaceId: resource.contexts.isNotEmpty ? resource.contexts.first : null);
    Navigator.pop(context);
  }

  createChatFromHighlight(BuildContext context, {required Resource resource, required String highlightId}) {

  }
  
}

enum HighlightType {
  favorite,
  like,
  dislike,
  question,
}
