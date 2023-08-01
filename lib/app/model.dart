import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/resource.dart';


import 'package:stashmobile/app/providers/web.dart';

import 'package:stashmobile/app/web/model.dart';


final appViewProvider = ChangeNotifierProvider<AppViewModel>((ref) {
  final resourceManager = ref.watch(resourceProvider);
  return AppViewModel(
      resourceManager: resourceManager, webView: ref.watch(webManagerProvider));
});

enum ResourceViewType {
  search,
  links,
  website,
  article,
  document,
  book,
  audio,
  tags,
  ratings,
  annotations,
  highlight,
  note,
  task,
  filter,
}

class AppViewModel extends ChangeNotifier {


  ResourceManager resourceManager;
  WebManager webView;
  bool webViewIsOpen = false;


  AppViewModel({
    required this.resourceManager,
    required this.webView,
  }) {
    load();
  }

  load() {
    if (resourceManager.isLoading) return;
    
    //webViewIsOpen = false;
    setIsLoading(false);
  }

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

 
}

class ViewState {
  ResourceViewType view;
  String resourceId;
  List<String> filters = [];
  ViewState({required this.resourceId, this.view = ResourceViewType.links});
  @override
  String toString() {
    // TODO: implement toString
    return '<ViewState: $resourceId $view>';
  }
}
