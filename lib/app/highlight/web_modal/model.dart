import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  ViewModel(this.context) {
    app = context.read(appProvider);
  }
}
