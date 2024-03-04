
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/windows/windows_view_model.dart';



class WindowsView extends ConsumerWidget {
  const WindowsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(windowsProvider);
    return PageView(
      controller: model.pageController,
      scrollDirection: Axis.horizontal,
      children: model.workspaces,
      onPageChanged: model.onPageChanged,
    );
  }
}