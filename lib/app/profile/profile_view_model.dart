import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/services/llm.dart';

class ProfileViewModel {
  BuildContext context;
  Function(Function()) setState;

  ProfileViewModel(this.context, this.setState) {
    print('creating profile view');
    load();
  }

  List<Tag> favoriteTerms = [];
  List<Resource> resources = [];

  String summary = '';
  load() async {
    favoriteTerms = context.read(homeViewProvider).tags;
    favoriteTerms.sort((a, b) => b.valueCount.compareTo(a.valueCount));
    resources = context.read(homeViewProvider).highlightedResources;
    String prompt = "I've read the following web articles and made the below highlights. What would you infer about my identity, goals, knowledge and interests. ";
    
    final data = jsonEncode(resources.map((resource) {
      return {
        'title': resource.title,
        'url': resource.url,
        'highlights': resource.highlights.map((highlight) {
          return highlight.text;
        }).toList()
      };
    }).toList());

    prompt += "\n${data}";


    print(prompt);

    final response = await LLM().mistralChatCompletion(prompt: prompt);
    print('got response from mistral');
    print(response);
    setState(() {
      summary = response;
    });
    
  }



}