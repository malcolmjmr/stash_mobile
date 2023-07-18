import 'package:flutter/material.dart';
import 'package:stashmobile/app/collections/collection/model.dart';

class CollectionDescriptionView extends StatelessWidget {
  final CollectionViewModel model;
  CollectionDescriptionView(this.model);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: model.collection.description != null
          ? ListView(
              children: [Text(model.collection.description!)],
            )
          : Center(child: Text('No Description')),
    );
  }
}
