import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/models/resource.dart';

final activeTabProvider = StateNotifierProvider<ActiveTabNotifier, Resource>((ref) => ActiveTabNotifier());

class ActiveTabNotifier extends StateNotifier<Resource> {
  ActiveTabNotifier() : super(Resource()) {
 
  }

  update
}