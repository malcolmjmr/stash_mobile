import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/home/home_view.dart';
import 'package:stashmobile/app/web/view.dart';


import 'splash_screen.dart';
import 'model.dart';

class AppView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //final model = watch(appViewProvider);
    return Scaffold(
      //drawer: SidePanelView(),
      backgroundColor: Colors.black12,
      body: HomeView(),
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
