import 'package:flutter/material.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class EditBookmarkModel {

  BuildContext context;
  Function(Function()) setState;
  Resource? resource;
  Workspace? space;

  bool canEditTitle = true;

  WorkspaceViewModel workspaceModel;
  TextEditingController titleController = TextEditingController();

  EditBookmarkModel(this.context, this.setState, {
    this.resource, 
    this.space, 
    required this.workspaceModel
  }) {
    setState(() {
      if (resource != null) {
        spaces = resource!.contexts.map((id) => workspaceModel.data.workspaces.firstWhere((s) => s.id == id)).toList();
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

  addSpaces(List<Workspace> spacesToAdd) {
    if (resource != null) {
      resource!.contexts.addAll(spacesToAdd.map((s) => s.id));
      spaces.addAll(spacesToAdd);
    }
  }

  bool showTags = true;

  List<String> tags = [];
  addTags(List<String> tagsToAdd) {
    if (resource != null) {
      resource!.tags.addAll(tagsToAdd);
      tags = resource!.tags;
    }
  }

  /*

    Title

    Spaces
      - current spaces
      - recent 

    Tags



  */

}