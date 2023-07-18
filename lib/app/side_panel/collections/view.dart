import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/collections/collection/list_item/view.dart';
import 'package:stashmobile/app/providers/collections.dart';
import 'package:stashmobile/routing/app_router.dart';

class CollectionsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final model = watch(collectionProvider);
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          _buildList(context, model),
          _buildCreateButton(context, model),
        ],
      ),
    );
  }

  _buildList(BuildContext context, CollectionManager model) => model.loading
      ? Center(
          child: CircularProgressIndicator(),
        )
      : Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              final collection = model.collections[index];
              return CollectionListItem(collection,
                  onTap: () => model.setUserCollection(collection),
                  isCurrentCollection:
                      collection.id == model.user.currentCollection);
            },
            itemCount: model.collections.length,
          ),
        );

  _buildCreateButton(BuildContext context, CollectionManager model) =>
      Positioned(
        bottom: 15,
        right: 20,
        child: GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.collectionCreate),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: Container(
              color: Theme.of(context).highlightColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 12, left: 15, right: 15),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
