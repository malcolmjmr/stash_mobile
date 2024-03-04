import 'package:flutter/material.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class TabCommand {

  IconData icon;
  String name;

  Function() onTap;
  Function()? onDoubleTap;
  Function()? onLongPress;
  
  double Function(WorkspaceViewModel workspaceModel)? iconFillFunction;
  double opacity;

  TabCommand({
    required this.icon,
    required this.name,
    required this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.iconFillFunction,
    this.opacity = 1,
  });

}