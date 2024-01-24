import 'package:stashmobile/models/resource.dart';

class WorkspaceViewParams {
  String? workspaceId;
  String? parentId;
  Resource? resourceToOpen;
  bool? isIncognito;
  WorkspaceViewParams({this.workspaceId, this.parentId, this.resourceToOpen, this.isIncognito});
}