import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:stashmobile/app/history/activity_history_view.dart';
import 'package:stashmobile/app/modals/create_new_tab/create_new_tab_modal.dart';
import 'package:stashmobile/app/modals/tag_selection/tag_selection.dart';
import 'package:stashmobile/app/sign_in/email_password_sign_in_page.dart';
import 'package:stashmobile/app/web/tab_edit_modal.dart';

import 'package:stashmobile/app/workspace/workspace_view.dart';
import 'package:stashmobile/app/workspace/workspace_view_params.dart';
import 'package:stashmobile/models/resource.dart';

import '../app/search/search_view.dart';


class AppRoutes {
  static const main = '/';

  static const emailPasswordSignIn = '/email-password-sign-in';

  static const workspace = '/workspace';
  static const webView = '/webview';

  static const search = '/search';

  static const collectionHome = '/collection-home';
  static const collectionSettings = '/collection-settings';
  static const collectionCreate = '/collection-create';
  static const collectionSearch = '/collection-search';


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


  static const editTab = '/edit-tab';
  static const tagSelection = '/tag-selection';

  static const spaceSelection = '/space-selection';

  static const history = '/activity-history';

  static const createNewTab = '/create-new-tab';

  
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
      case AppRoutes.search:
        return PageTransition<dynamic>(
            type: PageTransitionType.scale,
            alignment: Alignment.topCenter,
            curve: Curves.easeInExpo,
            child: SearchView(),
            settings: settings,
            fullscreenDialog: true,
          );
      case AppRoutes.workspace:
        return PageTransition<dynamic>(
            type: PageTransitionType.rightToLeft,
            curve: Curves.easeInExpo,
            child: WorkspaceView(
              params: args as WorkspaceViewParams?, 
            ),
            settings: settings,
            fullscreenDialog: true,
          );
      case AppRoutes.history:
        return PageTransition<dynamic>(
            type: PageTransitionType.rightToLeft,
            alignment: Alignment.topCenter,
            curve: Curves.easeInExpo,
            child: ActivityHistoryView(),
            settings: settings,
            fullscreenDialog: true,
          );
      case AppRoutes.createNewTab: 
        return PageTransition<dynamic>(
            type: PageTransitionType.fade,
            alignment: Alignment.topCenter,
            curve: Curves.easeInExpo,
            child: CreateNewTabModal(),
            settings: settings,
            fullscreenDialog: true,
          );
      case AppRoutes.tagSelection:
        
        return PageTransition<dynamic>(
          type: PageTransitionType.rightToLeft,
          curve: Curves.easeInExpo,
          child: TagSelectionModal(resource: args as Resource, ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.spaceSelection:
        return PageTransition<dynamic>(
          type: PageTransitionType.rightToLeft,
          curve: Curves.easeInExpo,
          child: WorkspaceView(
            params: args as WorkspaceViewParams?, 
          ),
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
