import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stashmobile/app/authentication/firebase_providers.dart';
import 'package:stashmobile/app/authentication/session_provider.dart';
import 'package:stashmobile/app/common_widgets/empty_content.dart';
import 'package:stashmobile/constants/strings.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/user/model.dart';
import 'package:stashmobile/services/firestore.dart';
import 'package:stashmobile/services/firestore_path.dart';
import 'package:stashmobile/services/random_generator.dart';

final usersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getUsersStream();
});

class UserSelectionView extends ConsumerWidget {
  _createNewUser(BuildContext context) async {
    final newUser = await RandomGenerator.user();
    if (newUser != null) {
      final db = context.read(databaseProvider);
      final defaultCollection = Collection(name: Strings.defaultCollection);
      newUser.currentCollection = defaultCollection.id;
      await db.saveUser(newUser);
      await db.setPrivateCollection(newUser.id, defaultCollection);
      //context.read(sessionProvider).setUser(newUser);
    }
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildUserList(context, watch),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: Row(
          children: [
            Expanded(child: Text('Users')),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _createNewUser(context),
            ),
          ],
        ),
      );

  Widget _buildUserList(BuildContext context, ScopedReader watch) =>
      watch(usersStreamProvider).when(
          data: (users) => ListView.separated(
                itemCount: users.length + 2,
                separatorBuilder: (context, index) =>
                    const Divider(height: 0.5),
                itemBuilder: (context, index) {
                  if (index == 0 || index == users.length + 1) {
                    return Container(); // zero height: not visible
                  }
                  return UserThumbnail(users[index - 1]);
                },
              ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (_, stackTrace) {
            print(stackTrace);
            return const EmptyContent(
              title: 'Something went wrong',
              message: 'Can\'t load items right now',
            );
          });
}

class UserThumbnail extends StatelessWidget {
  final User user;
  UserThumbnail(this.user);

  _selectUser(BuildContext context, User user) async {
    await context.read(sessionProvider).setUser(user);
  }

  _transferUserContent(BuildContext context, User user) async {
    final collectionId = 'bc650600';
    final originalCollectionPath = 'users/${user.id}/spaces/$collectionId';
    print(originalCollectionPath);
    final contentToMove = await FirestoreService.instance.collection(
      path: originalCollectionPath,
      builder: (id, data) => Content.fromDatabase(id, data),
    );

    await FirestoreService.instance.setBatch(
        paths: contentToMove
            .map((c) =>
                '/users/${user.id}/collections/$collectionId/content/${c.id}')
            .toList(),
        documents: contentToMove.map((c) => c.toJson()).toList());
    user.currentCollection = collectionId;
    await FirestoreService.instance.updateData(
      path: FirestorePath.user(userId: user.id),
      data: user.toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('user-${user.id}'),
      title: Text(user.name ?? 'Unnamed User'),
      leading: Container(
        width: 50,
        child: Center(
          child: user.imageUrl != null
              ? Image.network(user.imageUrl!)
              : Container(),
        ),
      ),
      onTap: () => _selectUser(context, user),
      onLongPress: () => _transferUserContent(context, user),
    );
  }
}
