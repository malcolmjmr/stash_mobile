import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ExploreViewModel(this.context) {
    app = context.read(appProvider);
  }
}
