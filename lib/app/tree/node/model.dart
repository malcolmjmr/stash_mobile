import 'package:flutter/material.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/tree/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/links.dart';
import 'package:stashmobile/models/content/type_fields/task.dart';
import 'package:stashmobile/models/content/type_fields/web_search.dart';

class TreeNodeViewModel {
  int depth;
  Content content;
  TreeNodeViewModel? parent;
  List<TreeNodeViewModel> children = [];
  bool isLastChild = false;
  TreeNodeViewModel({
    required this.content,
    this.depth = 0,
    this.parent,
  }) {
    textController = TextEditingController(text: content.name);
  }

  bool get isOpen => content.isOpen != null && content.isOpen!;

  onTapTitle(BuildContext context) {
    context.read(appViewProvider).open(context, content);
  }

  onDoubleTapTitle(BuildContext context) {
    context.read(appViewProvider).openMainView(context, content);
  }

  onLongPressTitle(BuildContext context) {
    final app = context.read(appProvider);
    app.treeView.toggleSelection(this);
    if (app.treeView.selected.isNotEmpty)
      app.menuView.openCollapsedMenu(context);
    else
      app.menuView.openNavBar();
  }

  onHorizontalDragEnd(BuildContext context, DragEndDetails details) {
    final threshold = 200;
    final isSwipingLeft = (details.primaryVelocity ?? 0) < -threshold;
    final isSwipingRight = (details.primaryVelocity ?? 0) > threshold;
    if (isSwipingLeft) {
      moveNodeOut(context);
    } else if (isSwipingRight) {
      moveNodeIn(context);
    }
  }

  moveNodeOut(BuildContext context) async {
    bool parentIsRoot = parent?.parent == null;
    if (parentIsRoot) return;

    final treeView = context.read(treeViewProvider);
    final contentManager = context.read(contentProvider);

    // Remove existing links
    parent!.content.links!.forward!.remove(content.id);
    content.links!.back!.remove(parent!.content.id);

    // Create new links
    final grandParent = parent!.parent!;
    grandParent.content.links!.forward!.add(content.id);
    content.links!.back!.add(grandParent.content.id);

    // Save changes
    await contentManager.saveContent(parent!.content);
    await contentManager.saveContent(content);
    await contentManager.saveContent(grandParent.content);

    treeView.reloadTree();
  }

  moveNodeIn(BuildContext context) async {
    final nodeIndex = parent!.children.indexOf(this);
    final isOldestChild = nodeIndex == 0;
    if (isOldestChild) return;

    final treeView = context.read(treeViewProvider);
    final contentManager = context.read(contentProvider);

    // Remove existing links
    parent!.content.links!.forward!.remove(content.id);
    content.links!.back!.remove(parent!.content.id);

    // Create new links
    final olderSibling = parent!.children[nodeIndex - 1];
    if (olderSibling.content.links == null) {
      olderSibling.content.links = ContentLinks(forward: []);
    } else if (olderSibling.content.links!.forward == null) {
      olderSibling.content.links!.forward = [];
    }
    olderSibling.content.links!.forward!.add(content.id);
    content.links!.back!.add(olderSibling.content.id);

    // Save changes
    await contentManager.saveContent(parent!.content);
    await contentManager.saveContent(content);
    await contentManager.saveContent(olderSibling.content);

    treeView.reloadTree();
  }

  late TextEditingController textController;
  String? searchResultTitle;
  List<Content> searchResults = [];
  onSearchChanged(BuildContext context, String text) async {
    final app = context.read(appProvider);
    searchResults = app.content.searchContent(text);
    searchResults.sort((a, b) => a.title.length.compareTo(b.title.length));
  }

  onSubmitText(BuildContext context, String text) async {
    final app = context.read(appProvider);

    app.treeView.showAddContentOptions = false;
    bool isNewContent = app.treeView.newContent?.id == content.id;
    if (text.isEmpty && isNewContent) {
      await app.treeView.deleteFocus();
      app.menuView.openNavBar();
      return;
    }

    text = text.trim();
    content.name = text;

    ContentViewType view = ContentViewType.links;

    if (content.type == ContentType.webSearch) {
      final queryText = text.replaceAll(' ', '+');
      final searchUrl = Uri.parse('https://www.google.com/search?q=$queryText');
      content.webSearch = WebSearchFields(
        query: text,
        url: searchUrl.toString(),
      );
      view = ContentViewType.website;
      //content.visits.addNewVisit();
    }

    if (isNewContent) {
      final parent = app.content.getContentById(content.links!.back!.first);
      await app.content.addLinkedContent(
        parent: parent,
        child: content,
        context: context,
      );
      if (![ContentType.note, ContentType.task].contains(content.type))
        app.viewModel.openMainView(context, content);

      app.menuView.openNavBar();
    } else {
      await app.content.saveContent(content);
      app.menuView.openCollapsedMenu(context);
    }
    app.treeView.setFocus(null);
  }

  onTapIcon(BuildContext context) {
    // toggle open
    print('icon taped');
    content.isOpen = content.isOpen;
  }

  onLongPressIcon(BuildContext context) {
    // make draggable
    isDraggable = !isDraggable;
  }

  onDoubleTapIcon(BuildContext context) {
    // mark complete
    if (content.type != ContentType.task) return;
    if (content.task == null) content.task = TaskFields();
    content.task!.completed = DateTime.now().millisecondsSinceEpoch;
  }

  bool isDraggable = false;

  bool get hasChildren => children.isNotEmpty;
  bool get showChildren => isOpen != false && hasChildren;
  int get uncompletedTaskCount => children.where((child) {
        final isTask = child.content.type == ContentType.task;
        final hasTaskField = child.content.task != null;

        if (isTask || hasTaskField) {
          if (!hasTaskField || child.content.task!.completed == null)
            return true;
        }
        return false;
      }).length;
  bool get hasUncompletedTask => uncompletedTaskCount > 0;

  bool isEditing = false;
  bool isSelected = false;

  String get hintText {
    switch (content.type) {
      case ContentType.note:
        return 'Create note';
      case ContentType.topic:
        return 'Create topic';
      case ContentType.empty:
        return 'Add item from collection';
      case ContentType.webSearch:
        if (content.isIncognito)
          return 'Search web in incognito mode';
        else
          return 'Search web or enter url';
      default:
        return 'Enter Name';
    }
  }

  bool showPriority = true;

  @override
  String toString() {
    // TODO: implement toString
    return content.toString();
  }
}
