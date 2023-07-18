import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';

class NotificationsViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  NotificationsViewModel(this.context) {
    app = context.read(appProvider);
    loadNotifications();
  }

  List<NotificationModel> notifications = [];
  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  loadNotifications() async {
    final db = app.content.db;
    app.users.me.shareNotifications.forEach((n) async {
      final user = await db.getUserById(n.from);
      final content =
          await db.getContentFromPrivateCollection(n.from, n.collection!, n.id);
      if (user == null || content == null) return;
      notifications.add(
        NotificationModel(
          user: user,
          content: content,
        ),
      );
    });
    setIsLoading(false);
  }

  clearNotifications() {
    app.users.me.shareNotifications.clear();
    app.users.saveUser(app.users.me);
    app.menuView.openNavBar();
  }

  confirm(NotificationModel notification) {}

  reject(NotificationModel notification) {}
}

class NotificationModel {
  Content content;
  User user;
  NotificationModel({required this.user, required this.content});
}
