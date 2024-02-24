import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/routing/app_router.dart';

class CreateNewTabModel {


  BuildContext context;
  Function(Function()) setState;
  late DataManager data;
  WorkspaceViewModel? workspaceModel;

  CreateNewTabModel(this.context, this.setState, {this.workspaceModel}) {
    load();
  }

  String textInput = '';
  TextEditingController inputController = TextEditingController();

  List<Domain> favoriteDomains = [];
  List<Domain> favoirteSearchDomains = [];

  load() {
    data = context.read(dataProvider);
    favoriteDomains = data.domains.where((d) => d.isFavorite).toList();
    favoirteSearchDomains = favoriteDomains.where((d) => d.searchTemplate != null).toList();
  }


  onInputChanged() {
    textInput = inputController.text;
  }

  createTab() {
    //Navigator.pushNamed(context, AppRoutes.workspace, arguments: WorkspaceViewParams(resourceToOpen: Resource()));
  }

  onDomainTap(Domain domain) {
    String url = domain.url;
    if (textInput.isNotEmpty) {
      // create tab url 
    } 
    
    if (workspaceModel != null) {
      workspaceModel!.createNewTab(url: url);
    } else {

      context.read(windowsProvider).openWorkspace(null, resource: Resource(url: url));
      
    }
  }

  onDomainLongPress(Domain domain) {
    // set as default
    //data.
  }

  clearInput() {

  }

  dispose() {
    inputController.dispose();
  }
}