import 'dart:async';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as MBS;
import 'package:stashmobile/app/menu/more/expanded.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/fields.dart';
import 'package:stashmobile/app/tree/filter_selection/default_filters.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'node/model.dart';

final treeViewProvider = ChangeNotifierProvider(
  (ref) => TreeViewModel(
    contentManager: ref.watch(contentProvider),
    fieldManager: ref.watch(fieldProvider),
  ),
);

class TreeViewModel extends ChangeNotifier {
  ContentManager contentManager;
  FieldManager fieldManager;
  TreeViewModel({required this.contentManager, required this.fieldManager}) {
    initializeScrollController();
    loadTree(null);
  }

  PageController headerPageController = PageController();
  bool headerIsExpanded = false;
  setHeaderIsExpanded(bool value) {
    headerIsExpanded = value;
    notifyListeners();
  }

  showHeaderMenu() {
    headerPageController.animateToPage(
      1,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
    setHeaderIsExpanded(true);
  }

  showMenu(BuildContext context) {
    MBS.showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => ExpandedMenu(),
      //expand: true,
    );
  }

  StreamSubscription? updateSubscription;

  onHeaderPageChanged(int index) {
    if (index == 0)
      setHeaderIsExpanded(false);
    else
      setHeaderIsExpanded(true);
  }

  reset(BuildContext context) {
    resetScrollPosition();
    linkDirection = LinkDirection.forward;
    selected.clear();
    loadTree(context);
  }

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool showFilterSelection = true;
  late ScrollController scrollController;
  initializeScrollController() {
    scrollController =
        ScrollController(initialScrollOffset: 40, keepScrollOffset: false);
    //scrollController.addListener(() {});
  }

  resetScrollPosition() {
    if (scrollController.positions.isNotEmpty) scrollController.jumpTo(40);
  }

  loadTree(BuildContext? context) {
    setIsLoading(true);
    Content root;
    if (context != null)
      root = context.read(appViewProvider).root;
    else
      root = contentManager.dailyPage;

    final noAvailableFilter =
        filterObject == null || root.filters == null || root.filters!.isEmpty;
    if (noAvailableFilter) {
      filterObject = contentManager.allContent[defaultFilters.first];
    } else {
      if (filterObject!.id != root.filters!.first)
        filterObject = contentManager.allContent[root.filters!.first];
    }

    treeNodes.clear();

    rootNode = TreeNodeViewModel(content: root);
    rootNode.children = recursivelyGetChildren(rootNode);

    if (showFilteredList)
      treeNodes.sort((a, b) => sortContent(a.content, b.content));

    handleUpdateSubscription(context);

    setIsLoading(false);
  }

  handleUpdateSubscription(BuildContext? context) async {
    if (contentManager.collectionIsShared) {
      await updateSubscription?.cancel();
      updateSubscription = contentManager.updateStream.listen((updates) {
        bool sendNotification = false;
        updates.forEach((Content content) {
          final ignoreUpdate =
              content.updates?.all?.last.user == contentManager.user.id;
          if (ignoreUpdate) return;

          bool needToUpdate = treeNodes.any((node) {
            final exists = node.content.id == content.id;
            if (!exists) return false;
            final nameChanged = node.content.name != content.name;
            final linksChanged = node.content.links != content.links;
            return nameChanged || linksChanged;
          });

          if (needToUpdate) {
            sendNotification = true;
            print(content);
          }
          contentManager.allContent[content.id] = content;
        });
        if (sendNotification) {
          loadTree(context);
        }
      });
    }
  }

  bool get showFilteredList => showFilter && needToFilterContent;

  bool get needToFilterContent =>
      linkDirection == LinkDirection.forward &&
      (filterObject?.filter?.fieldSpecs
              ?.any((spec) => spec.operations?.isNotEmpty ?? false) ??
          false);

  reloadTree({clearSelected = true}) {
    setIsLoading(true);
    if (clearSelected) selected.clear();
    if (showFilteredList) {
      getFilteredNodes();
    } else {
      fieldManager.fieldsInTree.clear();
      rootNode = TreeNodeViewModel(
        content: contentManager.getContentById(rootNode.content.id),
      );
      rootNode.children = recursivelyGetChildren(rootNode);
    }
    setIsLoading(false);
  }

  List<String> treeNodeIds = [];
  List<TreeNodeViewModel> recursivelyGetChildren(TreeNodeViewModel parent,
      {depth = 0}) {
    if (depth == 0) {
      treeNodeIds.clear();
      treeNodes.clear();
    }
    bool shouldTerminate = parent.content.links == null ||
        depth > maxDepth ||
        treeNodeIds.contains(parent.content.id);
    if (shouldTerminate) return [];

    treeNodeIds.add(parent.content.id);
    if (showFilteredList) {
      bool satisfiesFilter =
          filterObject?.filter?.criteriaAreSatisfied(parent.content) ?? true;

      if (satisfiesFilter) treeNodes.add(parent);
    } else {
      treeNodes.add(parent);
    }

    bool hasCustomFields = parent.content.customFields != null;
    if (hasCustomFields)
      fieldManager.fieldsInTree.addAll(parent.content.customFields?.keys ?? []);

    if (newContent?.id == parent.content.id) focus = parent;
    List<TreeNodeViewModel> children = contentManager
        .getContentByIds(getChildIds(parent.content))
        .map((content) {
      final child = TreeNodeViewModel(
        parent: parent,
        content: content,
        depth: depth,
      );

      if (expandAll != null && depth == 1) child.content.isOpen = expandAll;
      child.children = recursivelyGetChildren(child, depth: depth + 1);
      return child;
    }).toList();
    if (showFilteredList) {
      children.sort((a, b) => sortContent(a.content, b.content));
    }

    return children;
  }

  List<String> getChildIds(Content content, {LinkDirection? direction}) {
    return {
          LinkDirection.forward: content.links?.forward,
          LinkDirection.back: content.links?.back
        }[direction ?? linkDirection] ??
        [];
  }

  int maxDepth = 20;
  late TreeNodeViewModel rootNode;

  List<TreeNodeViewModel> getChildren(TreeNodeViewModel node) =>
      node.depth <= maxDepth
          ? contentManager
              .getContentByIds(getChildIds(node.content))
              .map((child) => TreeNodeViewModel(
                  content: child, parent: node, depth: node.depth + 1))
              .toList()
          : [];

  Content? newContent;
  addNodeToTree() async {
    final parent = selected.length == 1 ? selected.first : rootNode;
    ContentType contentType = ContentType.webSearch;
    if (parent.children.isNotEmpty) {
      if (parent.children.last.content.type != ContentType.webSite)
        contentType = parent.children.last.content.type;
    } else if ([
      ContentType.note,
      ContentType.annotation,
    ].contains(parent.content.type)) {
      contentType = parent.content.type;
    }

    newContent = await contentManager.addLinkedContent(
      parent: parent.content,
      type: contentType,
      saveToDb: false,
    );

    showAddContentOptions = true;
    expandAll = false;
    setShowFilter(false);
    //setShowAddContentOptions(true);
  }

  bool showAddContentOptions = false;
  setShowAddContentOptions(bool value) {
    showAddContentOptions = value;
    notifyListeners();
  }

  LinkDirection linkDirection = LinkDirection.forward;
  setLinkDirection(BuildContext context, LinkDirection value) {
    linkDirection = value;
    loadTree(context);
    notifyListeners();
  }

  FocusNode focusNode = FocusNode();
  TextEditingController textController = TextEditingController();

  TreeNodeViewModel? focus;
  setFocus(TreeNodeViewModel? value) {
    if (value == null && newContent != null) newContent = null;
    focus = value;
    notifyListeners();
  }

  updateFocusType(ContentType type, {isIncognito = false}) {
    if (focus == null) return;
    focus!.content.type = type;
    focus!.content.isIncognito = isIncognito;
    contentManager.saveContent(focus!.content);
    notifyListeners();
  }

  deleteFocus() async {
    if (focus != null) {
      if (newContent?.id == focus!.content.id) {
        newContent = null;
      }
      await contentManager.deleteContent(focus!.content);
      focus = null;
      reloadTree();
      //notifyListeners();
    }
  }

  Content? filterObject;

  bool showFilter = false;
  setShowFilter(bool value) {
    showFilter = value;
    reloadTree();
  }

  setFilter(Content? value, {filterIsSaved = false}) async {
    if (value == null || filterObject == value) return;
    filterObject = value;
    if (filterIsSaved) await addFilterToContent();
    reloadTree();
  }

  addFilterToContent() async {
    if (rootNode.content.filters != null) {
      final filterIndex = rootNode.content.filters!.indexOf(filterObject!.id);
      final isInFilter = filterIndex > -1;
      if (isInFilter) rootNode.content.filters!.removeAt(filterIndex);
      rootNode.content.filters!.insert(0, filterObject!.id);
    } else {
      rootNode.content.filters = [filterObject!.id];
    }
    await contentManager.saveContent(rootNode.content);
  }

  List<TreeNodeViewModel> treeNodes = [];

  getFilteredNodes() {
    //setIsLoading(true);
    treeNodes.clear();
    recursivelyGettreeNodes(TreeNodeViewModel node, {depth = 0}) {
      node.content.isOpen = false;

      // get children
      node.children.forEach((child) {
        bool alreadyFound =
            treeNodes.any((item) => item.content.id == child.content.id);

        if (alreadyFound) return;

        bool satisfiesFilter =
            filterObject?.filter?.criteriaAreSatisfied(child.content) ?? true;

        if (satisfiesFilter) treeNodes.add(child);
        recursivelyGettreeNodes(child, depth: depth + 1);
      });
    }

    recursivelyGettreeNodes(rootNode);
    treeNodes.sort((a, b) => sortContent(a.content, b.content));
    //setIsLoading(false);
  }

  int sortContent(Content a, Content b) {
    if (filterObject?.filter == null ||
        filterObject!.filter!.fieldSpecs == null ||
        filterObject!.filter!.fieldSpecs!.isEmpty) return 0;

    return filterObject!.filter!.sortContent(a, b);
  }

  bool? expandAll;
  setExpandAll(bool value) {
    expandAll = value;
    expand(TreeNodeViewModel node) {
      for (TreeNodeViewModel child in node.children) {
        child.content.isOpen = expandAll;
        //expand(child);
      }
    }

    expand(rootNode);
    notifyListeners();
  }

  bool selectAll = false;
  List<TreeNodeViewModel> selected = [];
  setSelectAll(bool value) {
    selectAll = value;

    for (TreeNodeViewModel child in rootNode.children)
      addSelection(child, notify: false);
    notifyListeners();
  }

  addSelection(TreeNodeViewModel node, {notify = true}) {
    if (!selected.any((n) => n.content.id == node.content.id))
      selected.add(node);
    if (notify) notifyListeners();
  }

  toggleSelection(TreeNodeViewModel selectedNode, {bool notify = true}) {
    final index = selected
        .indexWhere((node) => node.content.id == selectedNode.content.id);
    bool alreadySelected = index >= 0;
    if (alreadySelected)
      selected.removeAt(index);
    else
      selected.add(selectedNode);

    if (notify) notifyListeners();
  }

  onBackgroundTap(BuildContext context) {
    final app = context.read(appProvider);
    if (selected.isNotEmpty) clearSelected();
    app.menuView.openNavBar();
  }

  clearSelected() {
    selected.clear();
    notifyListeners();
  }

  cutSelected() {}

  copySelected() {}

  archiveSelected() {}

  int get forwardLinkCount =>
      getChildIds(rootNode.content, direction: LinkDirection.forward).length;
  int get backLinkCount =>
      getChildIds(rootNode.content, direction: LinkDirection.back).length;
}

enum LinkDirection { forward, back }
