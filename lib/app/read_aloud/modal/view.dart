import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class ReadAloudModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ChangeNotifierProvider(
        create: (context) => ViewModel(context),
        child: Consumer<ViewModel>(
          builder: (context, model, _) =>
              Container(child: _buildListenOptions(model)),
        ),
      ),
    );
  }

  Widget _buildListenOptions(ViewModel model) => Container(
        height: 120,
        child: Column(
          children: [
            GestureDetector(
              onTap: model.listenNow,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Listen Now'),
              ),
            ),
            GestureDetector(
              onTap: model.listenNext,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Listen Next'),
              ),
            ),
            GestureDetector(
              onTap: model.addToQueue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Add to Queue'),
              ),
            )
          ],
        ),
      );
}
