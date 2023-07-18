import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';

class ViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  Map<dynamic, dynamic>? valueCounts;
  double minValue = 0;
  double maxValue = 0;
  ViewModel(this.context, {this.valueCounts}) {
    app = context.read(appProvider);
    if (valueCounts != null && valueCounts!.length > 1) {
      minValue = List<int>.from(valueCounts!.keys).reduce(min).toDouble();
      maxValue = List<int>.from(valueCounts!.keys).reduce(max).toDouble();
    }
  }

  int get rating => 0;

  RangeValues rangeValues = RangeValues(0.0, 1.0);
  onRangeChanged(RangeValues range) {
    rangeValues = range;
    // minValue = range.start;
    // maxValue = range.end;

    notifyListeners();
  }
}
