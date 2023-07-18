import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stashmobile/models/collection/model.dart';
import 'package:stashmobile/models/content/content.dart';
import 'package:stashmobile/models/field/field.dart';
import 'package:stashmobile/models/collection/category.dart';
import 'package:stashmobile/models/user/model.dart';

import 'firestore.dart';
import 'firestore_path.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase();

  final _service = FirestoreService.instance;

  Stream<List<User>> getUsersStream() => _service.collectionStream(
        path: FirestorePath.users,
        builder: (id, data) => User.fromDatabase(id, data),
      );

  Future<List<User>> getUsers() => _service.collection(
        path: FirestorePath.users,
        builder: (id, data) => User.fromDatabase(id, data),
      );

  Future<User?> getUserById(String userId) => _service.document(
        path: FirestorePath.user(userId: userId),
        builder: (id, json) =>
            json != null ? User.fromDatabase(id, json) : null,
      );

  Future<List<User>> getFollowing(User user) => _service.collection(
        path: FirestorePath.users,
        builder: (id, data) => User.fromDatabase(id, data),
        queryBuilder: (Query query) =>
            query.where('followers', arrayContains: user.id),
      );

  Future<void> saveUser(User user) => _service.setData(
        path: FirestorePath.user(userId: user.id),
        data: user.toJson(),
      );

  Future<void> updateUser(User user) => _service.updateData(
        path: FirestorePath.user(userId: user.id),
        data: user.toJson(),
      );

  Stream<User> getCurrentUserAsStream(String userId) => _service.documentStream(
        path: FirestorePath.user(userId: userId),
        builder: (id, data) => User.fromDatabase(id, data),
      );

  Stream<List<Collection>> getCollectionsStream(User user) =>
      _service.collectionStream(
          path: FirestorePath.privateCollections(userId: user.id),
          builder: (id, data) => Collection.fromDatabase(id, data,
              isCurrentCollection: user.currentCollection == id));

  Future<List<Collection>> getPrivateCollections(User user) =>
      _service.collection(
        path: FirestorePath.privateCollections(userId: user.id),
        builder: (id, data) => Collection.fromDatabase(id, data),
      );

  Future<void> setPrivateCollection(String userId, Collection collection) =>
      _service.setData(
        path: FirestorePath.privateCollection(
            userId: userId, collectionId: collection.id),
        data: collection.toJson(),
      );

  Future<List<Collection>> getSharedCollections(User user) =>
      _service.collection(
        path: FirestorePath.collections,
        builder: (id, data) => Collection.fromDatabase(id, data),
        queryBuilder: (query) =>
            query.where('contributors', arrayContains: user.id),
      );

  Future<void> setSharedCollection(Collection collection) => _service.setData(
        path: FirestorePath.sharedCollection(collectionId: collection.id),
        data: collection.toJson(),
      );

  Stream<List<Content>> getCollectionUpdateStream(
          Collection collection, int lastUpdated) =>
      _service.collectionStream(
        path:
            FirestorePath.sharedCollectionContents(collectionId: collection.id),
        builder: (id, data) => Content.fromDatabase(id, data),
        queryBuilder: (query) =>
            query.where('updates.last', isGreaterThan: lastUpdated),
      );

  Future<List<Collection>> getSubscriptions(User user) => _service.collection(
        path: FirestorePath.collections,
        builder: (id, data) => Collection.fromDatabase(id, data),
        queryBuilder: (query) =>
            query.where('subscribers', arrayContains: user.id),
      );

  // Future<Collection> getPrivateCollection(String userId, String collectionId) => _service.getData(
  //   path: FirestorePath.privateCollection(userId: userId, collectionId: collectionId),
  //   builder: (data, id) => Collection.fromDatabase(id, data),
  // );

  Future<List<Field>> getUserFields(User user) => _service.collection(
        path: FirestorePath.userFields(userId: user.id),
        builder: (id, data) => Field.fromDatabase(id, data),
      );

  Future<void> setUserField(String userId, Field field) => _service.setData(
      path: FirestorePath.userField(userId: userId, fieldId: field.id),
      data: field.toJson());

  Future<void> setUserFields(String userId, List<Field> fields) async {
    await _service.setBatch(
        paths: fields
            .map((Field field) =>
                FirestorePath.userField(userId: userId, fieldId: field.id))
            .toList(),
        documents: fields.map((field) => field.toJson()).toList());
  }

  Future<void> setPrivateContent(
          String userId, String collectionId, Content content) =>
      _service.setData(
          path: FirestorePath.privateCollectionContent(
              userId: userId,
              collectionId: collectionId,
              contentId: content.id),
          data: content.toJson());

  Future<void> setSharedContent(String collectionId, Content content) =>
      _service.setData(
          path: FirestorePath.sharedCollectionContent(
              collectionId: collectionId, contentId: content.id),
          data: content.toJson());

  Future<void> postContent(Content content) => _service.setData(
      path: FirestorePath.publicPost(postId: content.id),
      data: content.toJson());

  Future<void> deleteContent(
          String userId, String collectionId, Content content) =>
      _service.deleteData(
          path: FirestorePath.privateCollectionContent(
              userId: userId,
              collectionId: collectionId,
              contentId: content.id));

  Stream<List<Content>> getContentStream(String userId, String collectionId,
          {Query Function(Query query)? queryBuilder}) =>
      _service.collectionStream(
          path: FirestorePath.privateCollection(
              userId: userId, collectionId: collectionId),
          builder: (id, data) => Content.fromDatabase(id, data),
          queryBuilder: queryBuilder);

  Future<List<Content>> getAllContentFromPrivateCollection(
          String userId, String collectionId,
          {Query Function(Query query)? queryBuilder}) async =>
      await _service.collection(
          path: FirestorePath.privateCollectionContents(
              userId: userId, collectionId: collectionId),
          builder: (id, data) => Content.fromDatabase(id, data),
          queryBuilder: queryBuilder);

  Future<List<Content>> getAllContentFromSharedCollection(String collectionId,
          {Query Function(Query query)? queryBuilder}) async =>
      await _service.collection(
          path: FirestorePath.sharedCollectionContents(
              collectionId: collectionId),
          builder: (id, data) => Content.fromDatabase(id, data),
          queryBuilder: queryBuilder);

  Future<Content?> getContentFromPrivateCollection(
    String userId,
    String collectionId,
    String contentId,
  ) async =>
      await _service.document(
        path: FirestorePath.privateCollectionContent(
            userId: userId, collectionId: collectionId, contentId: contentId),
        builder: (id, data) =>
            data != null ? Content.fromDatabase(id, data) : null,
      );

  Future<List<Content>> getContentFromSharedCollection(
          String userId, String collectionId,
          {Query Function(Query query)? queryBuilder}) async =>
      await _service.collection(
          path: FirestorePath.sharedCollectionContents(
              collectionId: collectionId),
          builder: (id, data) => Content.fromDatabase(id, data),
          queryBuilder: queryBuilder);

  Future<List<Collection>> getPublicCollections(
          {Query Function(Query)? queryBuilder}) async =>
      await _service.collection(
          path: FirestorePath.collections,
          builder: (id, json) => Collection.fromDatabase(id, json),
          queryBuilder: queryBuilder);

  Future<List<Category>> getCategories() async => await _service.collection(
      path: FirestorePath.categories,
      builder: (id, json) => Category.fromDatabase(id, json));

  Future<List<Content>> getPublicPosts() async => await _service.collection(
        path: FirestorePath.publicPosts,
        builder: (id, data) => Content.fromDatabase(id, data),
      );

  Future<void> saveBatchOfContent(
      String userId, String collectionId, List<Content> content) async {
    await _service.setBatch(
        paths: content
            .map((Content c) => FirestorePath.privateCollectionContent(
                userId: userId, collectionId: collectionId, contentId: c.id))
            .toList(),
        documents: content.map((c) => c.toJson()).toList());
  }
}
