import 'package:flutter/material.dart';
import 'package:stashmobile/app/model.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/content/content.dart';

class HighlightViewModel {
  BuildContext context;
  late AppController app;
  late Content highlight;
  late Content document;
  HighlightViewModel(this.context) {
    app = context.read(appProvider);
    highlight = app.viewModel.root;
    document = app.content.getContentById(highlight.annotation!.document);
  }

  openDocument() {
    app.viewModel.open(context, document, view: ContentViewType.website);
  }
}
