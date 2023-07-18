import 'package:flutter/material.dart';

class PriorityColors {
  static const Map<int, int> valueToShades = {
    1: 50,
    2: 100,
    3: 200,
    4: 300,
    5: 400,
    6: 500,
    7: 600,
    8: 700,
    9: 800,
    10: 900,
  };

  static Color getColorFromPriority(int value) {
    int? shade = valueToShades[value] ?? valueToShades.values.first;
    return Colors.blue[shade]!;
  }

  static getColorHexFromPriority(int value) {
    Color color = getColorFromPriority(value);
    return color.toString().replaceFirst('Color(0x', '#').replaceFirst(')', '');
  }
}
