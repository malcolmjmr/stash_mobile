import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/providers/provider_observer.dart';
import 'package:stashmobile/app/sign_in/email_password_sign_in_model.dart';
import 'package:stashmobile/app/sign_in/email_password_sign_in_page.dart';
import 'package:stashmobile/app/sign_in/sign_in_page.dart';
import 'package:stashmobile/app/view.dart';
import 'package:stashmobile/development/users/user_selection.dart';
import 'package:stashmobile/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/services/shared_preferences.dart';
import 'package:stashmobile/app/authentication/auth_widget.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    observers: [Logger()],
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: AuthWidget(
          nonSignedInBuilder: (_) => SignInPage(),
          signedInBuilder: (_) => AppView(),
        ),
      ),
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, firebaseAuth),
    );
  }
}
