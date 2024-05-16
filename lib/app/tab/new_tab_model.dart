import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/web/default_domains.dart';
import 'package:stashmobile/app/web/tab.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/models/chat.dart';
import 'package:stashmobile/models/domain.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/resource.dart';

class NewTabModel {

  Function(Function()) setState;
  BuildContext context;
  TabViewModel tabModel;
  NewTabModel(
    this.context,
    this.setState,
    this.tabModel
  ){ 
    load();
  }

  late DataManager data;

  String subSection = NewTabSection.history;

  
  load() {
    data = context.read(dataProvider);
  }

  String searchText = '';
  List<Resource> searchResults = [];
  List<Resource> history = [];
  List<Resource> newsItems = [];

  TextEditingController textController = TextEditingController();

  updateSearchResults() {
    final text = searchText.toLowerCase();
    List<Resource> items = [];

    if (selectedSection == NewTabSection.history) {
      items = history;
    } else if (selectedSection == NewTabSection.journeys) {
      items = [];
    } else if (selectedSection == NewTabSection.news) {
      items =  newsItems;
    }

    setState(() {
      searchResults = items.where((r) {
        return r.toJson().toString().toLowerCase().contains(text);
      }).toList();

      if (text.length < 2) {
        visibleDomains = defaultDomains.where((d) {
          return text.isEmpty ? true : d.searchTemplate != null;
        }).toList();
      }
    });


  }

  List<Domain> favoriteDomains = defaultDomains;
  List<Domain> visibleDomains = defaultDomains; // update when search started 

  onDomainTapped(BuildContext context, Domain domain) {
    String url = '';
    searchText = textController.text;
    if (searchText.isNotEmpty) {
      url = domain.createSearchUrlFromInput(searchText);
    } else {
      url = domain.url;
    }

    tabModel.resource.url = url;
    tabModel.setViewType(TabViewType.web);
    
  }

  List<String> visibleSections = [
    NewTabSection.history,
    NewTabSection.news,
    NewTabSection.news,
  ];

  String selectedSection = NewTabSection.history;

  createAssistedNavigation() {

  }

  createPrivateTab() {
    tabModel.isIncognito = true;
    tabModel.setViewType(TabViewType.web);
  }

  createNote() {
    tabModel.workspaceModel.showToolbar = true;
    tabModel.resource.note = Note();
    tabModel.resource.title = 'New Note';
    tabModel.setViewType(TabViewType.note);
  }

  createChat() {
    tabModel.workspaceModel.showToolbar = true;
    tabModel.resource.chat = Chat();
    tabModel.resource.title = 'New Chat';
    tabModel.setViewType(TabViewType.chat);
  }

}

class NewTabSection {
  static const String history = 'History';
  static const String news = 'News';
  static const String journeys = 'Journeys';

}