import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/model.dart';

import 'content_manager.dart';

final webManagerProvider = ChangeNotifierProvider<WebManager>(
    (ref) => WebManager(contentManager: ref.watch(contentProvider)));
