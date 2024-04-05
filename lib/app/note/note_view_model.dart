import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';

class NoteViewModel {
  
  TextEditingController textController = TextEditingController();

  BuildContext context;
  Function(Function()) setState;
  Resource resource;
  WorkspaceViewModel workspaceModel;
  TabViewModel get tabModel =>  workspaceModel.currentTab.model;

  PageController pageController = PageController(initialPage: 1);

  NoteViewModel({
    required this.context, 
    required this.setState,
    required this.resource,
    required this.workspaceModel
  }) {
    load();
  }

  load() {
    textController.addListener(textListener);
  }

  textListener() {
    // This listener will be called whenever the user changes the selection
    // or the content of the text field.
    final selection = textController.selection;
    if (selection.isValid && selection.toString().isNotEmpty) {
      print('selection');
      print(selection.toString());
      // workspaceModel.selectedText = selection.toString();
      // workspaceModel.setShowTextSelectionMenu(true);
    }
  }

  List<Resource> visibleResources = [];
  List<Tag> visibleTags = [];
  List<Tag> selectedTags = [];

  saveNote() {

    if (!resource.contexts
      .contains(workspaceModel.workspace.id)) {
        resource.contexts.add(workspaceModel.workspace.id);
        workspaceModel.allResources.add(resource);
    }

    context.read(dataProvider).saveResource(resource);
    
  }

  updateVisibleResources() {

    List<Resource> tempResources = []; ; 
    Map<String,Tag> tempTags = {}; 

    for (final resource in workspaceModel.data.resources) {
      bool matchesFilter = true;

      /*
        match against title, highlights, summary 
      */

      final tagFound =  selectedTags.isEmpty || (selectedTags.every((t) => resource.tags.contains(t.name)));
      if (tagFound && matchesFilter) {
        tempResources.add(resource);
        for (final tagName in resource.tags) {
          Tag? tag = tempTags[tagName];
          if (tag == null) {
            tag = Tag(
              name: tagName, 
              lastViewed: resource.lastVisited ?? resource.updated ?? resource.created ?? 0,
              isSelected: selectedTags.firstWhereOrNull((selectedTag) => selectedTag.name == tagName) != null
            );
          }
          tag.valueCount += 1;
          tempTags[tagName] = tag;
        }
      }
    }

    print('finished iterating through resources');

    if (tempResources.isEmpty && selectedTags.isNotEmpty) {
      selectedTags = [];
      updateVisibleResources();
      return;
    }
    tempResources.sort(sortResources);
    visibleResources = tempResources;
    List<Tag> sortedTags = tempTags.values.where((t) => t.valueCount > 1).toList();
    
    sortedTags.sort(sortTags);
    
    
    visibleTags = selectedTags.isEmpty
      ? sortedTags.sublist(0, min(20, sortedTags.length)).toList()
      : sortedTags;
  }

  int sortResources(Resource a, Resource b) {
    final lastVistComp = (b.lastVisited ?? 0).compareTo(a.lastVisited ?? 0);
    if (lastVistComp == 0) {
      return (b.created ?? 0).compareTo(a.created ?? 0);
    }

    return lastVistComp;
  }

  int sortTags(Tag a, Tag b) { 
    final selectionComp = (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0);
    if (selectionComp == 0) {

      final viewComp = b.lastViewed.compareTo(a.lastViewed);
      if (viewComp == 0) {
        final valueCountComp = b.valueCount.compareTo(a.valueCount);
        return valueCountComp;
      } else {
        return viewComp;
      }
      
    } else {
      return selectionComp;
    }
  }

  toggleTagSelection(Tag selectedTag) {
    final index = selectedTags.indexWhere((t) => t.name == selectedTag.name);
    if (index > -1) {
      selectedTags.removeAt(index);
    } else {
      selectedTags.add(selectedTag);
    }
    updateVisibleResources();
  }

  onPageChanged(int index) {
    
  }

  onTextFieldTapped() {
    FocusScope.of(context).unfocus();
    if (textController.selection.toString().isNotEmpty && workspaceModel.showTextSelectionMenu) {
      workspaceModel.selectedText = null;
      workspaceModel.setShowTextSelectionMenu(false);

    }
    
  }

}