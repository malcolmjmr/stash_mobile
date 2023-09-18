

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';

class TagSelectionModel {

  Resource resource;
  BuildContext context;
  late DataManager data;
  Function(Function()) setState;
  TagSelectionModel(this.context, this.setState, {required this.resource}) { 
    
  }
    

  List<Tag> visibleTags = [];
  Set<String> allTags = Set();
  Map<String, int> tagCounts = {};

  load() {
    data = context.read(dataProvider);
    
    for (final resource in data.resources) {
      for (final tag in resource.tags) {
        if (tagCounts[tag] == null) {
          tagCounts[tag] = 0;
        }
        tagCounts[tag] = tagCounts[tag]! + 1;
      }
    }

  }

  String searchText = '';
  updateVisibleTags(String updatedSearchText) {
    searchText = updatedSearchText;
    final text = searchText.toLowerCase();

    setState(() {
      visibleTags = tagCounts.keys
        .where((tagName) => tagName.contains(text))
        .map((tagName) => Tag(
          name: tagName, 
          isSelected: resource.tags.contains(tagName))
        )
        .toList();
    });
  
  }
  
}