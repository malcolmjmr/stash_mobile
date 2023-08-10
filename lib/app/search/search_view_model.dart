
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';

import '../../models/resource.dart';
import '../../models/workspace.dart';

final searchViewProvider = ChangeNotifierProvider<SearchViewModel>(
  (ref) => SearchViewModel(app: ref.watch(appProvider))
);


class SearchViewModel with ChangeNotifier {

  AppController app;

  SearchViewModel({ required this.app}) {

  }

  TextEditingController controller = TextEditingController();

  List<Workspace> visibleWorkspaces = [];
  List<Resource> visibleResources = [];

  updateResults() {

  }

  

}
