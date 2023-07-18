import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stashmobile/app/collections/collection/view.dart';
import 'package:stashmobile/app/fields/view.dart';
import 'package:stashmobile/app/tags/view.dart';
import 'package:stashmobile/app/filter/fields/view.dart';
import 'package:stashmobile/app/filter/settings/search/view.dart';
import 'package:stashmobile/app/filter/view.dart';
import 'package:stashmobile/app/search/view.dart';
import 'package:stashmobile/app/collections/collection/create/view.dart';
import 'package:stashmobile/app/collections/collection/search/view.dart';
import 'package:stashmobile/app/side_panel/settings/connected_apps/hypothesis/view.dart';
import 'package:stashmobile/app/side_panel/settings/connected_apps/view.dart';
import 'package:stashmobile/app/sign_in/email_password_sign_in_page.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/field/field.dart';

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
      case AppRoutes.connectedApps:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ConnectedAppsView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.hypothesisSync:
        return MaterialPageRoute<dynamic>(
          builder: (_) => HypothesisSyncView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.filterSettings:
        return MaterialPageRoute<dynamic>(
          builder: (_) => FilterView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.filterFieldSettings:
        final field = args as Field;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FilterFieldSettings(field),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.filterSearch:
        return MaterialPageRoute<dynamic>(
          builder: (_) => FilterSearchView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.collectionHome:
        return MaterialPageRoute<dynamic>(
          builder: (_) => CollectionView(args as Collection),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.collectionCreate:
        return MaterialPageRoute<dynamic>(
          builder: (_) => CollectionCreateView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.collectionSearch:
        return MaterialPageRoute<dynamic>(
          builder: (_) => CollectionSearchView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.search:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SearchView(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.contentTags:
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              SafeArea(child: Scaffold(body: TagsView(fullScreenMode: true))),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.contentFields:
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              SafeArea(child: Scaffold(body: FieldsView(fullScreenMode: true))),
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
