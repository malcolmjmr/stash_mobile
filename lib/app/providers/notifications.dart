import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore_database.dart';

final notificationProvider = ChangeNotifierProvider(
  (ref) => NotificationProvider(
    session: ref.watch(sessionProvider),
    db: ref.watch(databaseProvider),
  ),
);

class NotificationProvider extends ChangeNotifier {
  late User user;
  AppSession session;
  FirestoreDatabase db;
  NotificationProvider({required this.session, required this.db}) {
    if (session.user == null) return;
    user = session.user!;
    listenForNotifications();
  }

  listenForNotifications() {
    db.getCurrentUserAsStream(user.id).listen((user) {
      if (user.shareNotifications.isNotEmpty) {
        notifyListeners();
      }
    });
  }
}
