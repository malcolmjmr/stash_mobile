import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stashmobile/models/user/model.dart';

import '../models/workspace.dart';
import '../models/resource.dart';
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

  Future<void> saveUser(User user) => _service.setData(
        path: FirestorePath.user(userId: user.id),
        data: user.toJson(),
        merge: true,
      );

  Future<void> updateUser(User user) => _service.updateData(
        path: FirestorePath.user(userId: user.id),
        data: user.toJson(), 
      );

  Stream<User> getCurrentUserAsStream(String userId) => _service.documentStream(
        path: FirestorePath.user(userId: userId),
        builder: (id, data) => User.fromDatabase(id, data),
      );

  Stream<List<Workspace>> getUserWorkspacesStream(User user) =>
      _service.collectionStream(
          path: FirestorePath.userWorkspaces(userId: user.id),
          builder: (id, data) => Workspace.fromDatabase(id, data),
      );

  Future<List<Workspace>> getUserWorkspaces(User user) =>
      _service.collection(
          path: FirestorePath.userWorkspaces(userId: user.id),
          builder: (id, data) => Workspace.fromDatabase(id, data)
      );

  Stream<List<Resource>> getWorkspaceResourceStream(User user, String workspaceId) =>
      _service.collectionStream(
          path: FirestorePath.userResources(userId: user.id),
          builder: (id, data) => Resource.fromDatabase(id, data),
          queryBuilder: (query) => query.where('contexts', arrayContains: workspaceId),
      );

  Future<List<Resource>> getWorkspaceResources(User user, String workspaceId) =>
      _service.collection(
          path: FirestorePath.userResources(userId: user.id),
          builder: (id, data) => Resource.fromDatabase(id, data),
          queryBuilder: (query) => query.where('contexts', arrayContains: workspaceId),
      );

  Future<List<Resource>> getResourcesByTime(User user, int time) => 
    _service.collection(
      path: FirestorePath.userResources(userId: user.id),
      builder: (id, data) => Resource.fromDatabase(id, data),
      queryBuilder: (query) => query.where('updated', isGreaterThan: time),
    );
  
  Future<List<Resource>> getResourcesByContexts(User user, List<String> contextIds) => 
    _service.collection(
      path: FirestorePath.userResources(userId: user.id),
      builder: (id, data) => Resource.fromDatabase(id, data),
      queryBuilder: (query) => query.where('contexts', arrayContainsAny: [contextIds]),
    );

  Future<List<Resource>> getMiscResources(User user) =>
      _service.collection(
          path: FirestorePath.userResources(userId: user.id),
          builder: (id, data) => Resource.fromDatabase(id, data),
          queryBuilder: (query) => query.where('contexts', isNull: true),
      );

  Future<void> setUserWorkspace(String userId, Workspace workspace) =>
      _service.setData(
        path: FirestorePath.userWorkspace(
            userId: userId, workspaceId: workspace.id),
        data: workspace.toJson(),
        merge: true,
      );
  
  Future<void> deleteWorkspace(
          String userId, String workspaceId) =>
      _service.deleteData(
          path: FirestorePath.userWorkspace(
              userId: userId,
              workspaceId: workspaceId));

  Future<void> setResource(
          String userId, Resource resource) =>
      _service.setData(
          path: FirestorePath.userResource(
              userId: userId,
              resourceId: resource.id!),
          data: resource.toJson(),
          merge: true,
      );

  Future<void> deleteResource(
          String userId, String resourceId) =>
      _service.deleteData(
          path: FirestorePath.userResource(
              userId: userId,
              resourceId: resourceId));
  

  // Stream<List<Content>> getCollectionUpdateStream(
  //         Collection collection, int lastUpdated) =>
  //     _service.collectionStream(
  //       path:
  //           FirestorePath.sharedCollectionContents(collectionId: collection.id),
  //       builder: (id, data) => Content.fromDatabase(id, data),
  //       queryBuilder: (query) =>
  //           query.where('updates.last', isGreaterThan: lastUpdated),
  //     );


  // Future<Collection> getPrivateCollection(String userId, String collectionId) => _service.getData(
  //   path: FirestorePath.privateCollection(userId: userId, collectionId: collectionId),
  //   builder: (data, id) => Collection.fromDatabase(id, data),
  // );

}
