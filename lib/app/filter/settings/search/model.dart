import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/filters.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late FilterManager filterSettings;
  ViewModel(this.context) {
    filterSettings = context.read(filterProvider);
  }
}
