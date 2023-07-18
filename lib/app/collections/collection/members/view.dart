import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/models/collection/model.dart';

import 'model.dart';

class CollectionMembersView extends StatelessWidget {
  final Collection collection;
  CollectionMembersView(this.collection);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CollectionMembersViewModel(context),
        child:
            Consumer<CollectionMembersViewModel>(builder: (context, model, _) {
          return CustomScrollView(
            slivers: [
              _buildUserSearch(model),
              _buildHeader(model, 'Owners', collection.owners?.length),
              _buildUserList(model, collection.owners),
              _buildHeader(
                  model, 'Contributors', collection.contributors?.length),
              _buildUserList(model, collection.contributors),
              _buildHeader(
                  model, 'Subscribers', collection.subscribers?.length),
            ],
          );
        }));
  }

  Widget _buildUserSearch(CollectionMembersViewModel model) =>
      SliverToBoxAdapter(
        child: Container(),
      );

  Widget _buildHeader(
          CollectionMembersViewModel model, String title, int? count) =>
      SliverToBoxAdapter(
        child: count != null && count > 0
            ? Container(
                color: Theme.of(model.context).primaryColor,
                height: 40,
                child: Center(
                  child: Text(
                    '$title (${count.toString()})',
                    style: GoogleFonts.lato(fontSize: 18),
                  ),
                ),
              )
            : Container(),
      );

  Widget _buildUserList(
          CollectionMembersViewModel model, List<String>? users) =>
      users != null && users.isNotEmpty
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(),
                  childCount: users.length))
          : SliverToBoxAdapter(child: Container());
}
