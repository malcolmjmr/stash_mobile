import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as mbs;
import 'package:stashmobile/app/menu/model.dart';
import 'package:stashmobile/app/menu/text_selection/view.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/scent/colors.dart';
import 'package:stashmobile/app/side_panel/settings/connected_apps/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/content/type_fields/annotation.dart';
import 'package:stashmobile/models/content/type_fields/web_article.dart';
import 'package:stashmobile/models/content/type_fields/website.dart';
import 'package:stashmobile/services/hypothesis.dart';
import 'package:collection/collection.dart';

import 'js.dart';

class WebEventHandlers {
  static onTextSelection(BuildContext context, args) {
    final String newSelection = args[0];
    final app = context.read(appProvider);
    final selectedText = app.web.selectedText;

    final selectionHasBeenCleared =
        newSelection.isEmpty && selectedText.isNotEmpty;
    final foundNewSelectedText =
        newSelection.isNotEmpty && newSelection != selectedText;
    if (selectionHasBeenCleared) {
      app.web.selectedText = newSelection;
      app.menuView.setSubMenuView(null);
      app.menuView.openNavBar();
    } else if (foundNewSelectedText) {
      app.web.selectedText = newSelection;
      final selectedText = app.web.selectedText;
      final shouldAddTags = app.menuView.subMenuView == SubMenuView.tags ||
          app.treeView.selected.isNotEmpty;
      print('text selection');
      if (shouldAddTags) {
        print('adding tag');
        if (selectedText.split(' ').length <= 2)
          app.tagsView.addNewTag(selectedText);
      } else if (app.menuView.subMenuView == SubMenuView.fields) {
        app.fieldsView.addFieldFromTextSelection(selectedText);
      } else if (app.menuView.state != MenuState.textSelection) {
        app.menuView.state = MenuState.textSelection;
        mbs.showCupertinoModalBottomSheet(
          barrierColor: Colors.transparent,
          //clipBehavior: BorderRadius.only(),
          //backgroundColor: Colors.transparent,
          duration: Duration(milliseconds: 100),
          animationCurve: Curves.fastOutSlowIn,
          context: context,
          builder: (context) => Material(child: TextSelectionMenu()),
        ).then((value) {
          app.menuView.openNavBar();
          app.web.clearSelectedText();
        });
      }
    }
  }

  static onLinkSelected(BuildContext context, args) async {
    final app = context.read(appProvider);
    String text = args[0];
    String rawUrl = args[1];
    String url = rawUrl.toString();

    if (!url.contains('http')) {
      final webViewUrl = (await app.web.controller.getUrl()).toString();
      final baseUrlEndIndex = webViewUrl.lastIndexOf('/');
      final baseUrl = webViewUrl.substring(0, baseUrlEndIndex);
      url = '$baseUrl/$url';
    }
    // check that link doesn't exist
    final childLink = app.treeView.rootNode.children
        .firstWhereOrNull((node) => node.content.url == url);
    if (childLink != null) {
      app.treeView.selected = [childLink];
      app.menuView.setSubMenuView(SubMenuView.saveForLater);
    } else if (app.content.getContentByUrl(url) != null) {
      return;
    } else {
      final newLink = await app.content.addLinkedContent(
        parent: app.viewModel.root,
        child: Content(
            name: text,
            type: ContentType.webSite,
            website: WebsiteFields(url: url)),
      );
      app.treeView.reloadTree();

      app.treeView.selected = [
        app.treeView.rootNode.children.firstWhere(
          (node) => node.content.id == newLink.id,
        )
      ];
      await app.web.addSavedLink(newLink);
      app.menuView.setSubMenuView(SubMenuView.saveForLater);
    }
  }

  static onAnnotationTarget(BuildContext context, args) async {
    final target = args[0];
    final String uri = target['source'];
    final app = context.read(appProvider);
    final parent = app.viewModel.root;
    final hypothesisId = await Hypothesis().createAnnotation({
      'document': {
        'title': [parent.title]
      },
      'uri': uri.replaceFirst('.m.', '.'),
      'target': [target],
    });
    if (hypothesisId == null) return;

    final newContent = await app.content.addLinkedContent(
      parent: parent,
      child: Content(
        type: ContentType.annotation,
        annotation: AnnotationFields(
          document: parent.id,
          connectedAppId: hypothesisId,
          connectedAppSource: ConnectedApps.hypothesis,
          target: target,
        ),
      ),
    );
    Navigator.of(context).pop();
    // Todo: create function to add new node to tree without full reload
    app.treeView.reloadTree();
    app.treeView.selected = [
      app.treeView.rootNode.children.firstWhere(
        (node) => node.content.id == newContent.id,
      )
    ];

    app.web.clearSelectedText();
    final color = PriorityColors.getColorHexFromPriority(0);
    app.web.controller.evaluateJavascript(
      source: JS.addAnnotation({
        'id': newContent.id,
        'target': target,
        'color': color,
      }),
    );

    app.menuView.setSubMenuView(SubMenuView.rating);
  }

  static onDocumentBodyClicked(BuildContext context, args) {
    final app = context.read(appProvider);
    if (app.menuView.state != MenuState.navigationBar)
      app.menuView.openNavBar();
    if (app.treeView.selected.isNotEmpty) app.treeView.selected.clear();
  }

  static onHighlightClicked(BuildContext context, args) {
    final id = args[0];
    final app = context.read(appProvider);
    app.treeView.selected.clear();
    app.treeView.selected.add(
      app.treeView.rootNode.children.firstWhere(
        (node) => node.content.id == id,
      ),
    );
    app.tagsView.refresh();
    app.menuView.setState(MenuState.highlight);
  }

  static onHighlightDoubleClicked(BuildContext context, args) {
    print('double clicked');
    final id = args[0];
    final app = context.read(appProvider);
    app.viewModel.openMainView(
      context,
      app.content.getContentById(id),
    );
  }

  static onLinkClicked(BuildContext context, args) async {
    final String? href = args[0];
    final String? text = args[0];
    print('Click Event');
    //print('Text: $text');
    //print('Link: $href');
    await Future.delayed(Duration(seconds: 1));
    //print(await controller.getUrl());
    //print(await getFaviconUrl());
    final app = context.read(appProvider);
    final url = (await app.web.controller.getUrl()).toString();
    if (url != app.viewModel.root.url) {
      print(url);
      final ampMarker = '/amp/s/';
      if (url.contains(ampMarker)) {
        List<String> urlPaths = url.split(ampMarker).last.split('/');
        urlPaths.removeWhere((path) =>
            path.startsWith('amp') ||
            path.endsWith('amp') ||
            path == 'platform');
        final articleUrl = 'https://' + urlPaths.join('/');
        print(articleUrl);
        app.web.controller.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(articleUrl)),
        );
      }
    }
    //handleNewLink(context, url.toString(), text: text);
  }

  static onDocumentInfo(BuildContext context, args) async {
    final app = context.read(appProvider);
    final title = args[0];
    final content = app.viewModel.root;
    bool newTitleIsNotBlank = title != '' || title != null;
    bool oldTitleIsLowerCase = (content.name?.isNotEmpty ?? false) &&
        content.name![0] == content.name![0].toLowerCase();
    bool contentNameIsBlank = content.name == '' || content.name == null;
    bool contentNameContainsUrl = (content.name?.contains('http') ?? false) ||
        (content.name?.contains('www') ?? false);
    bool needToAddTitle = newTitleIsNotBlank &&
        (oldTitleIsLowerCase || contentNameIsBlank || contentNameContainsUrl);

    if (needToAddTitle) {
      content.name = title!.split(' - ')[0];
      content.isNew = false;
      content.editName = false;
      await app.content.saveContent(content);
    }
  }

  static onDocumentContent(BuildContext context, args) async {
    final List? sections = args[0];
    if (sections == null || sections.length <= 1) return;
    final app = context.read(appProvider);
    final newArticle = Article.fromWebView(sections);
    final savedArticle = app.viewModel.root.webArticle?.article;
    final needToSaveArticleData = savedArticle == null ||
        savedArticle.sections.length != newArticle.sections.length;
    if (needToSaveArticleData) {
      if (app.viewModel.root.webArticle == null) {
        app.viewModel.root.webArticle = WebArticleFields();
      }
      app.viewModel.root.webArticle!.article = newArticle;
      await app.content.saveContent(app.viewModel.root);
    }
    app.menuView.refresh();
  }

  static onScrollEnd(BuildContext context, args) async {
    final xPos = args[0];
    final app = context.read(appProvider);
    final content = app.viewModel.root;
    if (content.website!.scrollPosition != xPos) {
      content.website!.scrollPosition = xPos;
      app.content.saveContent(app.viewModel.root);
    }
  }
}
