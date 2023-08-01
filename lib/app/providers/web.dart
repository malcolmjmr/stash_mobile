import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/web/model.dart';

import 'resource.dart';

final webManagerProvider = ChangeNotifierProvider<WebManager>(
    (ref) => WebManager(resourceManager: ref.watch(resourceProvider)));
