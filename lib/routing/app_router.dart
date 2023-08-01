import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/sign_in/email_password_sign_in_page.dart';


class AppRoutes {
  static const main = '/';

  static const emailPasswordSignIn = '/email-password-sign-in';

  static const collectionHome = '/collection-home';
  static const collectionSettings = '/collection-settings';
  static const collectionCreate = '/collection-create';
  static const collectionSearch = '/collection-search';

  static const search = '/search';

  static const userSearch = 'user-search';

  static const viewSettings = '/view-settings';
  //static const query = '/query';
  static const filterSettings = '/filter-settings';
  static const filterFieldSettings = '/filter-field-settings';
  static const filterSearch = '/fitler-search';
  static const filterOperation = '/filter-operation';
  static const filterFieldValue = '/filter-field-value';
  static const typeFilters = '/type-filters';
  static const linkFilters = '/link-filters';
  static const tagFilters = '/tag-filters';
  static const ratingFilters = '/rating-filters';
  static const sort = '/sort';

  static const shareRoot = '/share-root';

  static const connectedApps = '/connected-apps';
  static const hypothesisSync = '/hypothesis-sync';

  static const contentTags = '/content-tags';
  static const contentFields = '/content-fields';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(
      RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignIn:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(firebaseAuth,
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                      child: Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text('No route defined for ${settings.name}'),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text('Go back'),
                        ),
                      ],
                    ),
                  )),
                ));
    }
  }
}
