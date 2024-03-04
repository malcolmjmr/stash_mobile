import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class NoteViewModel {
  
  TextEditingController textController = TextEditingController();

  BuildContext context;
  Function(Function()) setState;
  Resource resource;
  WorkspaceViewModel workspaceModel;

  NoteViewModel({
    required this.context, 
    required this.setState,
    required this.resource,
    required this.workspaceModel
  });

  saveNote() {

    if (!resource.contexts
      .contains(workspaceModel.workspace.id)) {

        resource.contexts.add(workspaceModel.workspace.id);

    }
    context.read(dataProvider).saveResource(resource);
  }

}