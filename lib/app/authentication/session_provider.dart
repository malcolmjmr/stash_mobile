import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:firebase_auth/firebase_auth.dart' as FB;
import 'package:stashmobile/services/firestore_database.dart';

final sessionProvider = ChangeNotifierProvider((ref) {
  final auth = ref.watch(authStateChangesProvider).data?.value;
  final db = ref.watch(databaseProvider);
  return AppSession(auth, db);
});


class AppSession extends ChangeNotifier {

  FB.User? auth;
  User? user;
  FirestoreDatabase db;
  AppSession(this.auth, this.db) {
    getUser();
  }

  
  SessionState state = SessionState.loading;
  setUser(User? newUser) {
    user = newUser;
    state = user != null ? SessionState.loggedIn : SessionState.loggedOut;
    notifyListeners();
  }

  getUser() async {
    if (auth != null) {
      user = await db.getUserById(auth!.uid);
      state = user != null ? SessionState.loggedIn : SessionState.loggedOut;
      notifyListeners();
    } 
    else {
      // Timer(Duration(seconds: 3),  () async {
        if (state == SessionState.loading) {
          state = SessionState.loggedOut;
          notifyListeners();
        }
      // });
    }
  }
}

enum SessionState { loading, loggedIn, loggedOut }
