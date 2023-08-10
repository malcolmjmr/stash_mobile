import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';

class AuthWidget extends ConsumerWidget {
  const AuthWidget({
    Key? key,
    required this.signedInBuilder,
    required this.nonSignedInBuilder,
    required this.spalshScreenBuilder,
  }) : super(key: key);
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;
  final WidgetBuilder spalshScreenBuilder;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final session = watch(sessionProvider);
    switch (session.state) {
      case SessionState.loading:
        return spalshScreenBuilder(context);
      case SessionState.loggedIn:
        return signedInBuilder(context);
      case SessionState.loggedOut:
        return nonSignedInBuilder(context);
    }
  }
}
