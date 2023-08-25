
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';

import '../../models/resource.dart';
import '../../models/workspace.dart';

final searchViewProvider = ChangeNotifierProvider<SearchViewModel>(
  (ref) => SearchViewModel(ref.read)
);


class SearchViewModel with ChangeNotifier {

  Reader read;
  late DataManager data;

  SearchViewModel(this.read) {
    data = read(dataProvider);
    
  }

  load() {
    updateSearchResults('');
  }

  //TextEditingController controller = TextEditingController();

  List <Workspace> workspaces = [];
  List <Resource> resources = [];

  List<Workspace> visibleWorkspaces = [];
  List<Resource> visibleResources = [];


   updateSearchResults(String searchString) {
    final text = searchString.toLowerCase();
    visibleWorkspaces = data.workspaces.where((w) => w.title?.toLowerCase().contains(text) ?? false).toList();
    visibleWorkspaces.sort((a, b) => (b.updated ?? 0).compareTo(a.updated ?? 0));
    visibleResources= data.resources.where((r) => r.title!.toLowerCase().contains(text)).toList();
    notifyListeners();
  }
}
