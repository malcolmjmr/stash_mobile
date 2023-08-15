import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/models/user/model.dart';

final userProvider = StateProvider<User?>((ref) {
  return ref.watch(sessionProvider).user;
});