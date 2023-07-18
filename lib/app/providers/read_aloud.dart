import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/users.dart';
import 'package:stashmobile/app/providers/web.dart';
import 'package:stashmobile/app/read_aloud/model.dart';

final readAloudProvider = ChangeNotifierProvider((ref) => ReadAloudController(
      ref: ref,
      contentManager: ref.watch(contentProvider),
      userManager: ref.watch(userProvider),
      webManager: ref.watch(webManagerProvider),
    ));
