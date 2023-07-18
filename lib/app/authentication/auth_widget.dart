import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';

class AuthWidget extends ConsumerWidget {
  const AuthWidget({
    Key? key,
    required this.signedInBuilder,
    required this.nonSignedInBuilder,
  }) : super(key: key);
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final session = watch(sessionProvider);
    switch (session.state) {
      case SessionState.loggedIn:
        return signedInBuilder(context);
      case SessionState.loggedOut:
        return nonSignedInBuilder(context);
    }
  }
}
