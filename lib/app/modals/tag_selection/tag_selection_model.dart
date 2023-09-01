

import 'package:flutter/material.dart';
import 'package:stashmobile/models/resource.dart';

class TagSelectionModel {

  Resource resource;
  BuildContext context;
  Function(Function()) setState;
  TagSelectionModel(this.context, this.setState, {required this.resource}) {

  }
}