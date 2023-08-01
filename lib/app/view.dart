import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stashmobile/app/web/view.dart';


import 'model.dart';

class AppView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(appViewProvider);
    return model.isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            //drawer: SidePanelView(),
            body: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: model.webViewIsOpen ? 0 : 1,
                    children: [
                      WebView(),
                     // _buildView(model.view),
                    ],
                  ),
                ),
                //MenuView(),
                //NotificationAlert()
              ],
            ),
          );
  }

  // Widget _buildView(ContentViewType view) {
  //   final Map<ContentViewType, Widget Function()> viewBuilders = {
  //     ContentViewType.links: () => TreeView(),
  //     ContentViewType.website: () => Container(),
  //     ContentViewType.article: () => ArticleView(),
  //     ContentViewType.highlight: () => HighlightView(),
  //     ContentViewType.note: () => NoteView(),
  //     ContentViewType.task: () => TaskView(),
  //     ContentViewType.filter: () => FilterView(),
  //   };
  //   return viewBuilders[view]!();
  // }
}
