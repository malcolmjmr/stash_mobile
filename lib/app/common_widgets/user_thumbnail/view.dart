import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/models/user/model.dart';

class UserThumbnail extends StatelessWidget {
  final String userId;
  final bool isListItem;
  UserThumbnail(this.userId, {this.isListItem = false})
      : super(key: ValueKey(userId));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: context.read(databaseProvider).getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = snapshot.data;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildIcon(user?.imageUrl), Text(user?.name ?? '')],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _buildIcon(String? imageUrl) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: imageUrl != null ? Image.network(imageUrl) : Icon(Icons.person),
      );
}
