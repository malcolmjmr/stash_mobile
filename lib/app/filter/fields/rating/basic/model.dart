import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/type_fields/filter.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
  }

  int get rating => 0;

  updateRating(int rating) {}

  FilterOperator get operator => FilterOperator.lessThanOrEqualTo;
  setOperation(FilterOperator value) {
    notifyListeners();
  }
}
