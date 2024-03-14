import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class EditBookmarkModel {

  BuildContext context;
  Function(Function()) setState;
  Resource? resource;
  Workspace? space;
  late DataManager  data;

  bool canEditTitle = true;

  WorkspaceViewModel workspaceModel;
  TextEditingController titleController = TextEditingController();

  EditBookmarkModel(this.context, this.setState, {
    this.resource, 
    this.space, 
    required this.workspaceModel
  }) {
    data = context.read(dataProvider);
    refreshData();
  }

  bool changesToSave = false;

  

  onDone() {
    if (resource != null) {
      data.saveResource(resource!);
    }
  }

  updateTitle() {
    
    resource!.title = titleController.text;
    setState(() {
      if (!changesToSave) changesToSave = true;
    });
    
  }

  refreshData() {
    setState(() {
      if (resource != null) {
        spaces = resource!.contexts.map((id) => data.getWorkspace(id)).toList();
        tags = resource!.tags;
        if (resource!.title != null) {
          titleController.text = resource!.title!;
        }
      } else if (space != null) {
        if (space!.title != null)  {
          titleController.text = space!.title!;
        }
      } else if (workspaceModel.selectedResources.isNotEmpty) {
        canEditTitle = false;
      }
    });
  }

  bool showSpaces = true;

  List<Workspace> spaces = [];

  createSpace(String title) {

  }

  addSpace(Workspace space) {
    setState(() {
      if (resource != null) {
        resource!.contexts.add(space.id);
        spaces.add(space);
      }
    });
  }

  removeSpace(Workspace space) {
    setState(() {
      resource!.contexts.removeWhere((id) => id == space.id);
      spaces.removeWhere((s) => space.id == s.id);
    }); 
  }

  


  bool showTags = true;

  List<String> tags = [];
  addTag(String tag) {
    setState(() {
      if (resource != null) {
        resource!.tags.add(tag);
        tags = resource!.tags;
      }
    });
  }

  removeTag(String tag) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (resource != null) {
        resource!.tags.remove(tag);
        tags = resource!.tags;
      }
    });
  }

  onTagSearchChange(String value) {

  }

  setRating(int rating) {
    HapticFeedback.mediumImpact();
    data.saveResource(resource!);
    setState(() {
      resource!.rating = rating;
    });
  }


  /*

    Title

    Spaces
      - current spaces
      - recent 

    Tags



  */

}