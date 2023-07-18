import 'package:flutter/material.dart';
import 'package:stashmobile/models/field/field.dart';

class FilterFieldSettings extends StatelessWidget {
  final Field field;
  FilterFieldSettings(this.field);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: {
          FieldType.contentType: () => Container(),
          FieldType.tag: () => Container(),
          FieldType.link: () => Container(),
          FieldType.number: () => Container(),
          FieldType.string: () => Container(),
          FieldType.date: () => Container(),
        }[field.type]!(),
      ),
    );
  }
}
