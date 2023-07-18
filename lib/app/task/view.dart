import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class TaskView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskViewModel(context),
      child: Consumer<TaskViewModel>(builder: (context, model, _) {
        return Container(
            child: Column(
          children: [],
        ));
      }),
    );
  }
}
