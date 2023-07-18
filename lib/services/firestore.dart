import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> setBatch({
    required List<String> paths,
    required List<Map<String, dynamic>> documents,
  }) async {
    // divide documents in batches less than limit of 500
    final firestore = FirebaseFirestore.instance;
    final maxBatchSize = 500;
    final numBatches = (documents.length / maxBatchSize).ceil();
    print('Number of batches: $numBatches');
    for (var batchNum = 0; batchNum < numBatches; batchNum++) {
      print('Batch $batchNum');
      final startIndex = batchNum == 0 ? 0 : batchNum * maxBatchSize;
      final endIndex = documents.length < maxBatchSize
          ? documents.length - 1
          : batchNum == numBatches - 1
              ? (maxBatchSize * numBatches) - documents.length
              : startIndex + maxBatchSize;
      print('Start index: $startIndex');
      print('End index: $endIndex');
      WriteBatch batch = firestore.batch();
      for (var docIndex = startIndex; docIndex < endIndex; docIndex++) {
        final path = paths[docIndex];
        final data = documents[docIndex];
        final reference = firestore.doc(path);
        batch.set(reference, data);
      }
      batch.commit();
    }
  }

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.update(data);
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    print('delete: $path');
    await reference.delete();
  }

  Future<List<T>> collection<T>({
    required String path,
    required T Function(String documentID, Map<String, dynamic> data) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
    asSnapshot = false,
  }) async {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final response = await query.get();
    List<T> collection = response.docs
        .map((doc) => builder(doc.id, doc.data() as Map<String, dynamic>))
        .where((value) => value != null)
        .toList();
    if (sort != null) {
      collection.sort(sort);
    }
    return collection;
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(String documentID, Map<String, dynamic> data) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.id, snapshot.data() as Map<String, dynamic>))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Future<void> deleteCollection({required String path}) async {
    final reference = FirebaseFirestore.instance.collection(path);
    print('delete: $path');
    reference.get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(String documentID, Map<String, dynamic> data) builder,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        builder(snapshot.id, snapshot.data()! as Map<String, dynamic>));
  }

  Future<T> document<T>({
    required String path,
    required T Function(String documentID, Map<String, dynamic>? data) builder,
  }) async {
    final doc = await FirebaseFirestore.instance.doc(path).get();
    return builder(doc.id, doc.data());
  }
}
