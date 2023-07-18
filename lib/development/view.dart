import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class DevelopmentView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = DevelopmentViewModel(context);
    return SafeArea(
        child: Scaffold(
            body: ListView(
      children: model.commands
          .map((command) => ListTile(
                title: Text(command.name),
                onLongPress: command.function,
              ))
          .toList(),
    )));
  }
}
