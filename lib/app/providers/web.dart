import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/model.dart';

import 'resources.dart';

final webManagerProvider = ChangeNotifierProvider<WebManager>(
    (ref) => WebManager(resourceManager: ref.watch(resourceProvider)));
