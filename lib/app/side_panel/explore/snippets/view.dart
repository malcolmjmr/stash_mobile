import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:stashmobile/app/common_widgets/list_item/view.dart';
import 'package:stashmobile/app/filter/selection_bar/view.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/routing/app_router.dart';

import 'model.dart';

class PublicPostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicPostsViewModel(context),
      child: Consumer<PublicPostsViewModel>(builder: (context, model, _) {
        return Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                //_buildHeader(context),
                _buildProfileThumbnails(model),
                FilterSelectionBar(),
                _buildFeed(model),
              ],
            ),
          ),
        );
      }),
    );
  }

  _buildHeader(BuildContext context) => Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
                child: Text(
              'Public',
              style:
                  GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 26),
            )),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.collectionSearch),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
            ),
          ],
        ),
      );

  Widget _buildProfileThumbnails(PublicPostsViewModel model) {
    final profileThumbnails = model.userProfileThumbnails;
    return Container(
      height: 60,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: profileThumbnails.length + 1,
          itemBuilder: (context, index) {
            if (index == 0)
              return _buildProfileThumbnail(context, model.myProfileThumbnail);
            else
              return _buildProfileThumbnail(
                  context, profileThumbnails[index - 1]);
          }),
    );
  }

  Widget _buildProfileThumbnail(
    BuildContext context,
    ProfileThumbnailModel model, {
    bool isCurrentUser = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Container(
          height: 50,
          width: 50,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(model.user.imageUrl!),
              ),
              model.contentCount > 0
                  ? Positioned(
                      bottom: 5,
                      right: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: Theme.of(context).highlightColor,
                          height: 15,
                          width: 15,
                          child: Center(
                            child: Text(
                              model.contentCount.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    )
                  : isCurrentUser
                      ? Icon(Icons.add_circle)
                      : Container(),
            ],
          ),
        ),
      );

  Widget _buildFeed(PublicPostsViewModel model) => Expanded(
      child: model.feedIsLoading
          ? Center(child: CircularProgressIndicator())
          : model.feed.isEmpty
              ? Center(child: Text('Nothing here'))
              : ListView.builder(
                  itemCount: model.feed.length,
                  itemBuilder: (context, index) =>
                      _buildFeedListItem(model.feed[index])));

  Widget _buildFeedListItem(Content content) => ListItem(content);
}
