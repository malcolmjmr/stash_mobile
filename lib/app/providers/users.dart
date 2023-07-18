import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';

final userProvider = Provider<UserManager>((ref) {
  final user = ref.watch(sessionProvider).user;
  if (user != null) {
    return UserManager(me: user, db: ref.watch(databaseProvider));
  }
  throw UnimplementedError();
});

class UserManager {
  UserManager({required this.me, required this.db}) {
    userStream = db.getCurrentUserAsStream(me.id);
    loadContacts();
  }

  User me;
  FirestoreDatabase db;

  saveUser(User user) {
    db.saveUser(user);
  }

  saveCurrentUser() {
    saveUser(me);
  }

  late Stream<User> userStream;

  List<User> contacts = [];
  loadContacts() async {
    contacts = await db.getUsers();
  }
}

final currentUserStreamProvider = StreamProvider<User>((ref) {
  final user = ref.watch(sessionProvider).user;
  final database = ref.watch(databaseProvider);
  if (user != null) {
    return database.getCurrentUserAsStream(user.id);
  } else {
    return Stream.empty();
  }
});
