import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/default_domains.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/routing/app_router.dart';

class TabEditModel {

  Function(Function()) setState;
  WorkspaceViewModel workspaceModel;
  Resource tab;
  TabEditModel({ 
    required this.setState, 
    required this.tab, 
    required this.workspaceModel
  }) {

    getInputFromUrl();
    inputController.text = input;
    inputController.selection = TextSelection(baseOffset: 0, extentOffset: input.length);
    visibleDomains = defaultDomains;
    visibleDomains.shuffle();
    
    setState(() {
      isLoaded = true;
    });
    
  }

  getInputFromUrl() { 
    if (tab.url == null) return;
    for (final domain in defaultDomains) {
      final searchQuery = domain.getSearchQuery(tab.url!);
      if (searchQuery != null ) {
        input = searchQuery;

        return;
      }
    }
    input = tab.url!;
  }

  bool isLoaded = false;


  bool showSearchResults = false;
  TextEditingController inputController = TextEditingController();
  String input = '';

  List<Resource> searchResults = [];

  onInputChanged() {
    
    setState(() {
      if (tab.url != inputController.text) {
        if (input.isEmpty && inputController.text.isNotEmpty) {
          visibleDomains = workspaceModel.data.domains.where((d) => d.searchTemplate != null).toList();
        } else if (input.isNotEmpty && inputController.text.isEmpty) {
          visibleDomains = workspaceModel.data.domains;
        }
      }
      input = inputController.text;
      
    });
    searchWorkspace();
                            
  }

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

  List<Domain> visibleDomains = [];
  createNewTab(BuildContext context, {Domain? domain, bool incognito = false}) {
    String? url;
    if (domain != null) {
      if (inputController.text.isNotEmpty) {
        if (input != workspaceModel.currentTab.model.resource.url ) {
          url = domain.createSearchUrlFromInput(inputController.text); 
        } else {
          url = domain.url;
        }
        
      } else {
        url = domain.url;
      }
    } else {
      url = getUrlFromInput();
    }
    workspaceModel.createNewTab(url: url, incognito: incognito);
    Navigator.pop(context);
  }

  createNewSpace(BuildContext context) {

    context.read(windowsProvider).openWorkspace(null, 
      resource: input != workspaceModel.currentTab.model.resource.url 
        ? Resource(
          url: getUrlFromInput(),
        )
        : null
    );
    
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

  deleteDomain(Domain domain) {
    workspaceModel.data.deleteDomain(domain.url);
  }

}