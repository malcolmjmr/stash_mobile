import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/workspace.dart';

class WorkspaceViewParams {
  String? workspaceId;
  Workspace? workspace;
  String? parentId;
  Resource? resourceToOpen;
  bool? isIncognito;
  WorkspaceViewParams({
    this.workspaceId, 
    this.workspace, 
    this.parentId, 
    this.resourceToOpen, 
    this.isIncognito
  });
}