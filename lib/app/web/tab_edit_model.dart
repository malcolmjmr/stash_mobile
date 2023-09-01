import 'package:flutter/material.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/resource.dart';

class TabEditModel {

  Function(Function()) setState;
  WorkspaceViewModel workspaceModel;
  Resource tab;
  TabEditModel({ 
    required this.setState, 
    required this.tab, 
    required this.workspaceModel
  }) {
    input = tab.url!;
    inputController.text = input;
    inputController.selection = TextSelection(baseOffset: 0, extentOffset: input.length);
    setState(() {
      isLoaded = true;
    });
    
  }

  bool isLoaded = false;


  bool showSearchResults = false;
  TextEditingController inputController = TextEditingController();
  String input = '';

  List<Resource> searchResults = [];

  searchWorkspace() {

  }

  clearInput() {
    setState(() {
      input = '';
      inputController.clear();
    });
  }

  dispose() {
    inputController.dispose();
  }

  updateTab(BuildContext context) async {
    
    
    await workspaceModel.updateTabFromUrlField(tab, getUrlFromInput());

    Navigator.pop(context);
  }

  createNewTab(BuildContext context) {
    workspaceModel.createNewTab(url: getUrlFromInput());
    Navigator.pop(context);
  }

  getUrlFromInput() {
    input = inputController.text;
    String url = input;
    if (input.contains('.')) {
      final missingProtocol = !input.contains('http://') && !input.contains('https://');
      if (missingProtocol) url = 'https://www.' + input;
    } else {
      url = 'https://www.google.com/search?q=' + Uri.encodeComponent(input);
    }
    return url;
  }

}