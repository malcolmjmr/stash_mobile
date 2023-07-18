import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/tree/node/model.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/models/user/notifications/share.dart';

class ShareViewModel extends ChangeNotifier {
  BuildContext context;
  late AppController app;
  late TreeNodeViewModel node;
  ShareViewModel(this.context) {
    app = context.read(appProvider);
    node = app.treeView.selected.isNotEmpty
        ? app.treeView.selected.first
        : app.treeView.rootNode;
    loadContacts();
  }

  List<User> selectedUsers = [];

  List<User> contacts = [];
  bool contactsAreLoading = true;
  loadContacts() async {
    contacts = await app.users.db.getUsers();
    contacts.removeWhere((user) => user.id == app.users.me.id);
    contactsAreLoading = false;
    notifyListeners();
  }

  bool get showTypeSelection => node.children.isNotEmpty;

  toggleUser(User user) {
    final userIndex =
        selectedUsers.indexWhere((selectedUser) => selectedUser.id == user.id);
    if (userIndex >= 0) {
      selectedUsers.removeAt(userIndex);
    } else {
      selectedUsers.add(user);
    }
    notifyListeners();
  }

  ShareAccess access = ShareAccess.full;

  ShareType type = ShareType.root;

  ShareState state = ShareState.configuring;
  setState(ShareState value) {
    state = value;
    notifyListeners();
  }

  sendRequest() async {
    setState(ShareState.sending);
    selectedUsers.forEach((user) {
      user.shareNotifications.add(
        ShareNotification(
          id: node.content.id,
          collection: app.users.me.currentCollection,
          from: app.users.me.id,
          access: access,
          type: type,
        ),
      );
      app.users.saveUser(user);
    });
    setState(ShareState.sent);
    Future.delayed(
      const Duration(seconds: 2),
      () => Navigator.of(context).pop(),
    );
  }
}

enum ShareState {
  configuring,
  sending,
  sent,
}
