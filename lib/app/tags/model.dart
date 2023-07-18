import 'package:flutter/material.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/tags.dart';
import 'package:stashmobile/models/content/type_fields/tag.dart';
import 'package:collection/collection.dart';

final tagsViewProvider = ChangeNotifierProvider((ref) => TagsViewModel(
    contentManager: ref.watch(contentProvider),
    treeView: ref.watch(treeViewProvider)));

class TagsViewModel extends ChangeNotifier {
  ContentManager contentManager;
  TreeViewModel treeView;
  TagsViewModel({required this.contentManager, required this.treeView}) {
    getAllTags();
    refresh();
    addFocusListener();
  }

  goBack(BuildContext context) =>
      context.read(appProvider).menuView.setSubMenuView(null);

  bool isLoading = false;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  refresh() {
    setIsLoading(true);
    getTagViewModels();
    setIsLoading(false);
  }

  List<Content> allTags = [];
  getAllTags() {
    allTags = contentManager.allContent.values
        .where((content) => content.type == ContentType.tag)
        .toList();
  }

  List<TagViewModel> get relevantTags => tagViewModels
      .where((tagViewModel) => tagViewModel.tag.name!
          .toLowerCase()
          .contains(textController.text.toLowerCase()))
      .toList();

  List<TagViewModel> tagViewModels = [];
  getTagViewModels() {
    getSelectedTags();
    getSuggestedTags();
    tagViewModels = [
      ...selectedTags.map((tag) => TagViewModel(tag: tag, isSelected: true)),
      ...suggestedTags.map((tag) => TagViewModel(tag: tag))
    ];
  }

  List<Content> selectedTags = [];
  getSelectedTags() {
    bool tagIsSelected(Content tag) => treeView.selected.isEmpty
        ? (treeView.rootNode.content.tags?.values.contains(tag.id) ?? false)
        : treeView.selected.every(
            (node) => node.content.tags?.values.contains(tag.id) ?? false);
    selectedTags = allTags.where(tagIsSelected).toList();
    selectedTags
        .sort((a, b) => (a.updates?.last ?? 0).compareTo(b.updates?.last ?? 0));
  }

  List<Content> suggestedTags = [];
  getSuggestedTags() {
    suggestedTags =
        allTags.where((content) => !selectedTags.contains(content)).toList();
    suggestedTags
        .sort((a, b) => (b.updates?.last ?? 0).compareTo(a.updates?.last ?? 0));
  }

  bool showFullScreen = false;
  setFullScreen(bool value) {
    showFullScreen = value;
  }

  onSearchOpen() => setFullScreen(true);

  // Search Bar
  FocusNode focusNode = FocusNode();
  bool keyboardIsOpen = false;
  addFocusListener() {
    focusNode.addListener(() {
      if (focusNode.hasFocus != keyboardIsOpen) {
        keyboardIsOpen = focusNode.hasFocus;
        if (keyboardIsOpen)
          setFullScreen(true);
        else
          setFullScreen(false);
      }
    });
  }

  TextEditingController textController = TextEditingController();
  onSearchUpdated(String text) {
    notifyListeners();
  }

  onSearchSubmit(BuildContext context, String? text) =>
      addNewTag(text, context: context);

  addNewTag(String? text, {BuildContext? context}) {
    if (text == null || text.isEmpty) return;

    bool tagExists(Content c) =>
        c.name?.toLowerCase() == text.toLowerCase().trim();
    Content? tag = allTags.firstWhereOrNull(tagExists);

    if (tag == null) {
      final lowerCaseName = text.trim().toLowerCase();
      print(lowerCaseName);
      tag = Content(
        name: lowerCaseName,
        type: ContentType.tag,
        tag: TagFields(instances: []),
      );
    }

    toggleTagSelection(tag);
    textController.clear();
    if (context != null) {
      Navigator.of(context).pop();
    }
  }

  toggleTagSelection(Content selectedTag) async {
    final isNewTag = !allTags.any((tag) => selectedTag.id == tag.id);
    if (isNewTag) allTags.add(selectedTag);
    if (treeView.selected.isEmpty) {
      await updateContentTags(treeView.rootNode.content, selectedTag);
    } else {
      treeView.selected.forEach((node) async {
        await updateContentTags(node.content, selectedTag);
      });
    }
    refresh();
  }

  updateContentTags(Content content, Content selectedTag) async {
    // Add current element as instance of tag
    if (selectedTag.tag!.instances.contains(content.id)) {
      selectedTag.tag!.instances.remove(content.id);
    } else {
      selectedTag.tag!.instances.add(content.id);
    }
    await contentManager.saveContent(selectedTag);
    // Add tag to current element's list of tags
    if (content.tags == null) content.tags = ContentTags(values: []);
    if (content.tags!.values.contains(selectedTag.id)) {
      content.tags!.values.remove(selectedTag.id);
    } else {
      content.tags!.values.add(selectedTag.id);
    }
    await contentManager.saveContent(content);
  }

  openTag(BuildContext context, Content tag) {
    context.read(appViewProvider).open(context, tag);
  }
}

class TagViewModel {
  Content tag;
  bool isSelected;
  bool isPartiallySelected;
  TagViewModel(
      {required this.tag,
      this.isSelected = false,
      this.isPartiallySelected = false});
}
