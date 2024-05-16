import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stashmobile/app/home/home_view_model.dart';
import 'package:stashmobile/app/providers/data.dart';
import 'package:stashmobile/app/web/tab_model.dart';
import 'package:stashmobile/app/workspace/workspace_view_model.dart';
import 'package:stashmobile/models/note.dart';
import 'package:stashmobile/models/resource.dart';
import 'package:stashmobile/models/tag.dart';
import 'package:stashmobile/services/llm.dart';

class NoteViewModel {
  
  QuillController quillController = QuillController.basic();
  TextEditingController textController = TextEditingController();

  ScrollController scrollController = ScrollController();
  

  BuildContext context;
  Function(Function()) setState;
  Resource resource;
  WorkspaceViewModel workspaceModel;
  TabViewModel get tabModel =>  workspaceModel.currentTab.model;
  Note get note => resource.note!;

  PageController pageController = PageController(initialPage: 1);

  NoteViewModel({
    required this.context, 
    required this.setState,
    required this.resource,
    required this.workspaceModel
  }) {
    load();
  }

  load() {


    getHighlightPrompt();
    
    textController.addListener(textListener);
   
    scrollController.addListener(scrollListener);
    
    configureQuillEditor();
    
    textController.text = note.text ?? '';
    if (note.promptResourceId != null) {
      if (note.highlightId != null) {

      }

      promptResource = workspaceModel.data.resources
        .firstWhere((r) => r.id == note.promptResourceId);
      highlightPrompt = promptResource?.highlights
          .firstWhere((h) => h.id == note.highlightId);

    } else if (note.prompt != null) {
      prompt = note.prompt;
    }
  }




  dispose() {
    quillController.dispose();
    textController.dispose();
    scrollController.dispose();
  }

  configureQuillEditor() {
    quillController.onDelete = onDelete;
    quillController.onSelectionCompleted = onSelectionChanaged;
    quillController.addListener(quillListener);
    quillController.document.insert(0, note.text ?? '');
    //SizeAttribute('18')
    //Attributes.fontSize.quill(18)
    print('formating quill editor');
    quillController.formatSelection(Attribute('size', AttributeScope.inline, '38'));
  }

  onSelectionChanaged() {
    print('selection changed');
  }

  onDelete(int pos, bool isDeleted) {

  }

  quillListener() {
    note.text = quillController.plainTextEditingValue.text;
    checkIfTransciptionCompleted();
    if (!needToSave) {
      needToSave = true;
    }
  }

  checkIfTransciptionCompleted() {
   
    if (highlightPrompt == null || highlightPrompt!.transcribed) return;

    if (highlightPrompt!.text.trim() != quillController.plainTextEditingValue.text.trim()) return;
    
    HapticFeedback.mediumImpact();

    setState(() {
      transcribed = true;
    });
    
    
    final index =  promptResource!.highlights.indexWhere((h) => h.text == highlightPrompt);
    if (index > -1) {
      promptResource!.highlights[index].transcribed = true;
      workspaceModel.saveResource(promptResource!);
    } 

    

    generateQuestions();
  }


  scrollListener() {
    
    final threshold = 50;
    if (scrollController.offset < threshold && !workspaceModel.showToolbar) {
      workspaceModel.setShowToolbar(true);

    } else if (scrollController.offset > threshold && workspaceModel.showToolbar) {
      workspaceModel.setShowToolbar(false);
    }
  }

  getHighlightPrompt() {

    if (note.promptResourceId != null) return;

    final workspace = workspaceModel.workspace;
    final highlightedResources = [...context.read(homeViewProvider).highlightedResources];

    highlightedResources.shuffle();


    for (final highlightedResource in highlightedResources) {
      final matchesFilter = (
        highlightedResource.contexts.contains(workspace.id) 
        || workspace.title == null
      );
      
      if (matchesFilter) {
        note.promptResourceId = highlightedResource.id;
        note.highlightId = highlightedResource.highlights.firstWhere((h) => h.favorites > 0 || h.likes > 0 || h.hasQuestion || h.dislikes > 0).id;
        break;
      }
    }

    

  }


  FocusNode focusNode = FocusNode();

  onKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      // Do something
    } else if (event.logicalKey == LogicalKeyboardKey.delete) {
      print('text deleted');
    }
  }


  bool promptIsExpanded = false;
  Resource? promptResource;
  Highlight? highlightPrompt;
  bool transcribed = false;
  String? prompt;

  togglePromptExpansion() {
    setState(() {
      promptIsExpanded = !promptIsExpanded;
    });
  }


  textListener() {
    // This listener will be called whenever the user changes the selection
    // or the content of the text field.
    final selection = textController.selection;
    if (selection.start == -1) return;
    final selectedText = textController.text.substring(selection.start, selection.end);
    if (selection.isValid && selectedText.isNotEmpty) {
      
      
      // workspaceModel.selectedText = selection.toString();
      // workspaceModel.setShowTextSelectionMenu(true);
    }
  }

  List<Resource> visibleResources = [];
  List<Tag> visibleTags = [];
  List<Tag> selectedTags = [];

  bool needToSave = false;
  saveNote() {

    //quillController.formatSelection(Attribute.align)
    final noteHasBeenSaved = !resource.contexts
      .contains(workspaceModel.workspace.id);
    
    if (noteHasBeenSaved) {

      context.read(dataProvider).saveResource(resource);
      // resource.contexts.add(workspaceModel.workspace.id);
      // workspaceModel.allResources.add(resource);
      // workspaceModel.updateVisibleResources();
    }

    workspaceModel.updateWorkspaceTabs();

    needToSave = false;
    
    
  }



  updateVisibleResources() {

    List<Resource> tempResources = []; ; 
    Map<String,Tag> tempTags = {}; 

    for (final resource in workspaceModel.data.resources) {
      bool matchesFilter = true;

      /*
        match against title, highlights, summary 
      */

      final tagFound =  selectedTags.isEmpty || (selectedTags.every((t) => resource.tags.contains(t.name)));
      if (tagFound && matchesFilter) {
        tempResources.add(resource);
        for (final tagName in resource.tags) {
          Tag? tag = tempTags[tagName];
          if (tag == null) {
            tag = Tag(
              name: tagName, 
              lastViewed: resource.lastVisited ?? resource.updated ?? resource.created ?? 0,
              isSelected: selectedTags.firstWhereOrNull((selectedTag) => selectedTag.name == tagName) != null
            );
          }
          tag.valueCount += 1;
          tempTags[tagName] = tag;
        }
      }
    }

    print('finished iterating through resources');

    if (tempResources.isEmpty && selectedTags.isNotEmpty) {
      selectedTags = [];
      updateVisibleResources();
      return;
    }
    tempResources.sort(sortResources);
    visibleResources = tempResources;
    List<Tag> sortedTags = tempTags.values.where((t) => t.valueCount > 1).toList();
    
    sortedTags.sort(sortTags);
    
    
    visibleTags = selectedTags.isEmpty
      ? sortedTags.sublist(0, min(20, sortedTags.length)).toList()
      : sortedTags;
  }

  int sortResources(Resource a, Resource b) {
    final lastVistComp = (b.lastVisited ?? 0).compareTo(a.lastVisited ?? 0);
    if (lastVistComp == 0) {
      return (b.created ?? 0).compareTo(a.created ?? 0);
    }

    return lastVistComp;
  }

  int sortTags(Tag a, Tag b) { 
    final selectionComp = (b.isSelected ? 1 : 0).compareTo(a.isSelected ? 1 : 0);
    if (selectionComp == 0) {

      final viewComp = b.lastViewed.compareTo(a.lastViewed);
      if (viewComp == 0) {
        final valueCountComp = b.valueCount.compareTo(a.valueCount);
        return valueCountComp;
      } else {
        return viewComp;
      }
      
    } else {
      return selectionComp;
    }
  }

  toggleTagSelection(Tag selectedTag) {
    final index = selectedTags.indexWhere((t) => t.name == selectedTag.name);
    if (index > -1) {
      selectedTags.removeAt(index);
    } else {
      selectedTags.add(selectedTag);
    }
    updateVisibleResources();
  }

  onPageChanged(int index) {
    
  }

  onTextChanged(String text) {
    note.text = textController.text;
  }

  onTextFieldTapped() {
    // FocusScope.of(context).unfocus();
    // if (textController.selection.toString().isNotEmpty && workspaceModel.showTextSelectionMenu) {
    //   workspaceModel.selectedText = null;
    //   workspaceModel.setShowTextSelectionMenu(false);

    // }
    
  }

  bool textIsSelected = false;
  List<String> suggestions = [];
  List<String> selectedSuggestions = [];

  toggleSuggestionSelection(String suggestion) {
    final index = selectedSuggestions.indexOf(suggestion);

    if (index > -1) {
      selectedSuggestions.removeAt(index);
    } else {
      selectedSuggestions.insert(0, suggestion);
    }

    setState(() {
      selectedSuggestions = selectedSuggestions;
    });
  }

  String get contextPrompt {
    String prompt = "I'm writing a note. ";
    
    if (highlightPrompt != null && promptResource != null) {

      prompt += 'I highlighted the following text from an article titled, ${promptResource!.title}:\n"${highlightPrompt!.text}"\nI\'d like to reflect on above text.';
      if (promptResource?.summary != null) {

      } else if (promptResource?.text != null) {
        
      }
    } else if (note.text?.isNotEmpty ?? false) {
      prompt += "So far, I have written the following:\n${note.text}";
    }
    return prompt;
  }

  List<String> continuationCache = [];
  continueText({bool useFullContext = false}) async {

    /*
      Check if anything has been typed => rag items related the prompt or with on of the most used terms
    */
    HapticFeedback.mediumImpact();
    String prompt = contextPrompt;
    final selection = quillController.selection;
    final text = quillController.plainTextEditingValue.text;
    final textSelection = text.substring(selection.start, selection.end);
    
    if ((note.text ?? '').isEmpty) {
      /*
          what resources do i want to bring to bear in this context and on this task

      */
      final data = context.read(dataProvider);
      final home = context.read(homeViewProvider);
      final keywords = promptResource?.tags ?? home.tags.getRange(0, 10).map((t) => t.name).toList();

      


      List<Highlight> retrievedHighlights = [];
      final resources = [...workspaceModel.allResources];
      resources.shuffle();
      for (final resource in resources) {
        for (final highlight in resource.highlights) {
          final isRelevantHighlight = keywords.any(
              (k) => highlight.text.contains(k.substring(0, min(4, k.length))) 
              && (highlight.hasQuestion || highlight.likes > 0 || highlight.favorites > 0)
          );
          if (isRelevantHighlight) {
            retrievedHighlights.add(highlight);
          }
        }
        if (retrievedHighlights.length > 10) break;
      }

      if (retrievedHighlights.length > 0) {
        prompt += 'Here are some examples of related texts that I have highlighted:\n';
        for (final highlight in retrievedHighlights) {
          prompt += '"${highlight.text}"\n';
        }
        prompt += '\nUse the above texts as inspiration for writing the first two sentences of this note.\nOutput:';
      }

      
    } else {
      
      if (textSelection.isNotEmpty) {
        prompt += '\nPlease continue the following text with a single sentence:\n${textSelection}\nOutput:';
      } else {
        prompt += '\nPlease continue the note above with a single sentence.\nOutput:';
      }
    }   
    

    final String response = await LLM().mistralChatCompletion(prompt: prompt);

    String newText = response.replaceFirst('Output:', '').trim();
    
    if (textSelection.isNotEmpty) {
      quillController.replaceText(selection.end, newText.length, newText, null);
    } else {
      quillController.document.insert(selection.start, newText);
    }

    setState(() {
      note.text = quillController.plainTextEditingValue.text;
    });
    
    

  }

  openFormatModal() {
    setState(() {
      bottomPanelType = BottomPanelType.format;
    });
  }

  toggleTask() {
    final selection = quillController.selection;
    final textSelection = note.text!.substring(selection.start, selection.end);
    final style = quillController.getSelectionStyle();
    final isChecklist = style.containsKey('list') && style.values.contains(Attribute.unchecked);

    if (isChecklist) {
      quillController.formatSelection(Attribute('list', AttributeScope.block, false));
      
    } else {
      quillController.formatSelection(Attribute.unchecked);
    }

    final json = jsonEncode(quillController.document.toDelta().toJson());
    print(json);
    print(quillController.plainTextEditingValue.text);
    
    // if (textSelection.isNotEmpty) {
      
    // } else {
      
    //   //quillController.formatText(selection.start, 0, Attribute.unchecked);
    // }
    
  }


  List<Resource> relatedResources = [];
  List<String> relatedHighlights = [];
  List<String> keywords = [];
  showRelated() {
    final selection = quillController.selection;
    final textSelection = note.text!.substring(selection.start, selection.end);
    final text = textSelection.isNotEmpty ? textSelection : textController.text;
    final dataManager = context.read(dataProvider);
    final home = context.read(homeViewProvider);

    final words = text.toLowerCase().split(' ');
    keywords = home.tags
      .where((t) => words.any((w) => w.startsWith(t.name.substring(0, min(t.name.length, 4))) ))
      .map((t) => t.name)
      .toList();
    
    relatedResources = [];
    relatedHighlights = [];
    
    for (Resource resource in dataManager.resources) {
      resource.matchingTags = resource.tags
          .where((t) => keywords.any((k) => k.startsWith(t.substring(0, min(t.length, 4)))))
          .map((t) => Tag(name: t))
          .toList();

      

      if (resource.matchingTags.length > 0) {

        relatedResources.add(resource);
        relatedHighlights.addAll(
          resource.highlights
            .where((h) => resource.matchingTags
              .any((t) => h.text.toLowerCase()
                .contains(t.name.substring(0, min(t.name.length, 4)))
              )
            )
            .map((h) => h.text)
        );

      }
    }
     
    relatedResources.sort((a,b) {
      final keywordComp = b.matchingTags.length.compareTo(a.matchingTags.length);

      if (keywordComp == 0 ) {
        return workspaceModel.sortResources(a, b);
      } else return keywordComp;
    });
    
    setBottomPanel(BottomPanelType.related);
  }

  searchSelectedText({ String? text }) {
    final selection = quillController.selection;
    final textSelection = text ?? note.text!.substring(selection.start, selection.end);
    if (textSelection.isNotEmpty) {
      workspaceModel.searchSelectedText(text: textSelection, openInNewTab: true);
    }
  }


  bool keyboardIsVisible = false;
  setBottomPanel(BottomPanelType value) {
    print('setting bottom panel');
  
    if (keyboardIsVisible) {
      focusNode.unfocus();
    } else if (bottomPanelType == value) {
      bottomPanelType = null;
      focusNode.requestFocus();
    }

    if (tabModel.workspaceModel.showToolbar) {
      tabModel.workspaceModel.setShowToolbar(false);
    }

    
    Timer(Duration(milliseconds: keyboardIsVisible ? 200 : 0), () {
      setState(() {
        bottomPanelType = value;
      });
    });
      
    

  }


  bool showSuggestions = false;

  generateSuggestions() async {

    HapticFeedback.mediumImpact();

    if (suggestions.isNotEmpty) {
      setBottomPanel(BottomPanelType.suggest);
      return;
    }
    
    String prompt = contextPrompt;


    
    if (note.text!.isEmpty) {
      final home = context.read(homeViewProvider);
      home.highlightedResources.shuffle();
      final highlights = home.highlightedResources.getRange(0, 5)
        .map((r) => r.highlights.firstWhere((h) => h.dislikes > 0 || h.likes > 0 || h.favorites > 0 ));

        prompt = "Here a few text excerpts that resonated with me:\n";
        for (final highlight in highlights) {
          prompt += '"' + highlight.text + '"' + '\n';
        }

    } else {
      final selection = quillController.selection;
      final textSelection = quillController.plainTextEditingValue.text.substring(selection.start, selection.end);
      if (textSelection.isNotEmpty) {
        prompt = "I've selected the following text:\n${textSelection}";
      }

    }

    prompt += """\nPlease provide five suggestions for expanding on and improving the above text. Format the output in JSON as an array of strings as follows:

    Output: ["sugestion 1", "suggestion 2", ...]""";


    final String response = await LLM().mistralChatCompletion(prompt: prompt);
    
    suggestions = List<String>.from(jsonDecode(response.replaceFirst('Output:', '').trim()));

    setBottomPanel(BottomPanelType.suggest);


  }

  List<String> questions = [];
   generateQuestions() async {
    HapticFeedback.mediumImpact();

    if (questions.isNotEmpty) {
      setBottomPanel(BottomPanelType.question);
      return;
    }
    String prompt = '';

    if (note.text!.isEmpty) {
      final home = context.read(homeViewProvider);
      home.highlightedResources.shuffle();
      final highlights = home.highlightedResources.getRange(0, 5)
        .map((r) => r.highlights.firstWhere((h) => h.dislikes > 0 || h.likes > 0 || h.favorites > 0 ));

        prompt = "Here a few text excerpts that resonated with me:\n";
        for (final highlight in highlights) {
          prompt += '"' + highlight.text + '"' + '\n';
        }

    } else {

      prompt = contextPrompt;
      final selection = quillController.selection;
      final textSelection = quillController.plainTextEditingValue.text.substring(selection.start, selection.end);
      if (textSelection.isNotEmpty) {
        prompt = "I've selected the following text:\n${textSelection}";
      }

    }

    prompt += """\nPlease provide five questions that explore tangential topics to those discussed above. Format the output in JSON as an array of strings as follows:

    Output: ["question", "question", ...]""";


    final String response = await LLM().mistralChatCompletion(prompt: prompt);
    
    questions = List<String>.from(jsonDecode(response.replaceFirst('Output:', '').trim()));

    setBottomPanel(BottomPanelType.question);

  }

  List<String> stashedText = [];

  stashText() {
    HapticFeedback.mediumImpact();
    if (note.text!.isNotEmpty) {
       final selection = quillController.selection;
      String textSelection = quillController.plainTextEditingValue.text.substring(selection.start, selection.end);
      if (textSelection.isNotEmpty) { 
        stashedText.add(textSelection);
        quillController.replaceText(selection.start, textSelection.length, '', null);
        // show stash 
        stashedText = stashedText;
      }
      
    }
   
   setBottomPanel(BottomPanelType.stash);
  }

  popStashedText(String text) {
    final index = stashedText.indexOf(text);
    if (index > -1) {
      stashedText.removeAt(index);
    }
    setState(() {
      stashedText = stashedText;
    });

    final selectionStart = quillController.selection.start;
    quillController.document.insert(quillController.selection.end, '\n' + text);
    textController.selection = TextSelection(baseOffset: selectionStart, extentOffset: selectionStart + text.length);
  }

  compressText() async {
    HapticFeedback.mediumImpact();
    String prompt = contextPrompt;

    final selection = quillController.selection;
    final textSelection = quillController.plainTextEditingValue.text.substring(selection.start, selection.end);
    if (textSelection.isNotEmpty) {
      prompt = "I've selected the following text:\n${textSelection}";
    }

    prompt += "\nPlease provide a more concsise version of the above text.\nOutput:";

    final String response = await LLM().mistralChatCompletion(prompt: prompt);



    updateTextFromLlmResponse(selection, textSelection, response);
  }

  expandText() async {
    HapticFeedback.mediumImpact();
    String prompt = contextPrompt;

    final selection = textController.selection;
    final textSelection = textController.text.substring(selection.start, selection.end);
    if (textSelection.isNotEmpty) {
      prompt = "I've selected the following text:\n${textSelection}";
    }

    prompt += "\nPlease provide a a slightly expanded yet concise version of the above text.\nOutput:";


    final String response = await LLM().mistralChatCompletion(prompt: prompt);
    updateTextFromLlmResponse(selection, textSelection, response);
  }

  styleText() async {
    HapticFeedback.mediumImpact();
    String prompt = contextPrompt;

    final selection = textController.selection;
    final textSelection = textController.text.substring(selection.start, selection.end);
    if (textSelection.isNotEmpty) {
      prompt = "I've selected the following text:\n${textSelection}";
    }

    prompt += "\nPlease provide a version of the selected text with a different voice and style.\nOutput:";

    final String response = await LLM().mistralChatCompletion(prompt: prompt);
    updateTextFromLlmResponse(selection, textSelection, response);
  }


  hideKeyboard() {
    Focus.of(context).requestFocus(focusNode);
    Focus.of(context).unfocus();

  }

  updateTextFromLlmResponse(TextSelection selection, String textSelection, String response) {
    String newText = response.replaceFirst('Output:', '');


    if (textSelection.isNotEmpty) {
      quillController.document.insert(selection.start, newText);
      quillController.updateSelection(
        TextSelection(baseOffset: selection.start, extentOffset: selection.start + newText.length),
        ChangeSource.local,
      );
    } else {
      quillController.document.insert(quillController.plainTextEditingValue.text.length - 1, newText);
    }
    note.text = quillController.plainTextEditingValue.text;
  }

  BottomPanelType? bottomPanelType;

  double keyboardHeight = 0;

  addText(String text) {
    
    quillController.document.insert(quillController.selection.end, '\n' + text);
    note.text = quillController.plainTextEditingValue.text;

  }

  String? selectedText;
  setSelectedText(String? value) {
    setState(() {
      if (selectedText == value) {
        selectedText = null;
      } else {
        selectedText = value;
      }
      
    });
  }

  List<String> get bottomPanelListItems {
    List<String> listItems = [];
    if (bottomPanelType == BottomPanelType.continuation) {
      listItems = continuationCache;
    } else if (bottomPanelType == BottomPanelType.question) {
      listItems = questions;
    } else if (bottomPanelType == BottomPanelType.related) {
      listItems = relatedHighlights;
    } else if (bottomPanelType == BottomPanelType.stash) {
      listItems = stashedText;
    } else if (bottomPanelType == BottomPanelType.suggest) {
      listItems = suggestions;
    }
    return listItems;
  }

  double bottomPanelHeight = 250;

  setBottomPanelHeight(double value) {
    setState(() {
      bottomPanelHeight = value;
    });
  }

  ScrollController? bottomPanelScrollController;
  setBottomPanelScrollController(ScrollController controller) {
    bottomPanelScrollController = controller;
    bottomPanelScrollController?.addListener(() {
      print(bottomPanelScrollController?.offset);
    });
  }

}

enum BottomPanelType {
  continuation,
  suggest,
  question,
  format,
  related,
  stash,
}