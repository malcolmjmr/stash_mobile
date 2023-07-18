import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_manager.dart';

final tagProvider = ChangeNotifierProvider(
    (ref) => TagManager(contentManager: ref.watch(contentProvider)));

class TagManager extends ChangeNotifier {
  ContentManager contentManager;

  TagManager({required this.contentManager});
}
