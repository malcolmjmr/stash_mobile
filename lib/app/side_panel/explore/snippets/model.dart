import 'package:flutter/cupertino.dart';

import 'package:stashmobile/app/providers/content_manager.dart';
import 'package:stashmobile/app/providers/filters.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicPostsViewModel extends ChangeNotifier {
  BuildContext context;
  late ContentManager contentManager;
  late User user;
  late FilterManager filters;
  PublicPostsViewModel(this.context) {
    filters = context.read(filterProvider);
    contentManager = context.read(contentProvider);
    user = contentManager.user;
    loadUsersImFollowing();
    refreshFeed();
  }

  List<User> usersImFollowing = [];
  bool loadingUsersImFollowing = true;
  loadUsersImFollowing() async {
    usersImFollowing = await contentManager.db.getFollowing(user);
    loadingUsersImFollowing = false;
  }

  List<Content> feed = [];

  bool feedIsLoading = false;
  setFeedIsLoading(bool value) {
    feedIsLoading = value;
    notifyListeners();
  }

  refreshFeed() async {
    setFeedIsLoading(true);
    if (contentManager.publicPosts.isEmpty)
      await contentManager.loadPublicPosts();
    feed = await contentManager.getPublicPosts(
        filter: filters.contentFilter.filter);
    updateUserContentMap();
    setFeedIsLoading(false);
  }

  Map<String, List<Content>> userContentMap = Map();
  updateUserContentMap() {
    userContentMap = Map();
    for (Content c in feed) {
      if (!userContentMap.containsKey(c.createdBy))
        userContentMap[c.createdBy!] = [];
      userContentMap[c.createdBy!]!.add(c);
    }
  }

  ProfileThumbnailModel get myProfileThumbnail => ProfileThumbnailModel(
        user: user,
        contentCount: userContentMap[user.id]?.length ?? 0,
      );

  List<ProfileThumbnailModel> get userProfileThumbnails {
    final userIds = userContentMap.keys;
    return usersImFollowing
        .where((user) => userIds.contains(user.id))
        .map((user) => ProfileThumbnailModel(
              user: user,
              contentCount: userContentMap[user.id]?.length ?? 0,
            ))
        .toList();
  }
}

class ProfileThumbnailModel {
  User user;
  int contentCount;
  ProfileThumbnailModel({required this.user, required this.contentCount});
}
