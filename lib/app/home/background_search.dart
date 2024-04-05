import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/search.dart';

class BackgroundTab extends ConsumerWidget {
  const BackgroundTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final search = watch(searchProvider);
    return search.webView;
  }
}