import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/common_widgets/app_bar_container.dart';
import 'package:stashmobile/services/hypothesis.dart';

import 'model.dart';

class HypothesisSyncView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = Model(context);
    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBarContainer(
          title: 'Hypothes.is',
        ),
      ),
      body: _buildBody(context, model),
    ));
  }

  Widget _buildBody(BuildContext context, Model model) => Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => model.saveApiToken(Hypothesis.apiToken),
              child: Text('Save Token'),
            ),
            ElevatedButton(
              onPressed: () => model.syncAnnotations(),
              child: Text('Sync Annotations'),
            ),
          ],
        ),
      );
}
