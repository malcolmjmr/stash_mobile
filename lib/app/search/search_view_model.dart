
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/resource.dart';
import '../../models/workspace.dart';

final searchViewProvider = ChangeNotifierProvider<SearchViewModel>(
  (ref) => SearchViewModel(ref.read)
);


class SearchViewModel with ChangeNotifier {

  Reader read;

  SearchViewModel(this.read) {

  }

  TextEditingController controller = TextEditingController();

  List<Workspace> visibleWorkspaces = [];
  List<Resource> visibleResources = [];

  updateResults() {

  }

  

}
