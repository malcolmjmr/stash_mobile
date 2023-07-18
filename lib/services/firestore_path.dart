class FirestorePath {
  static String users = 'users';
  static String user({required String userId}) => 'users/$userId';
  static String privateCollections({required String userId}) =>
      'users/$userId/collections';
  static String privateCollection(
          {required String userId, required String collectionId}) =>
      'users/$userId/collections/$collectionId';
  static String privateCollectionContents(
          {required String userId, required String collectionId}) =>
      'users/$userId/collections/$collectionId/content';
  static String privateCollectionContent(
          {required String userId,
          required String collectionId,
          required String contentId}) =>
      'users/$userId/collections/$collectionId/content/$contentId';

  static String userFields({required String userId}) => '$users/$userId/fields';
  static String userField({required String userId, required String fieldId}) =>
      '$users/$userId/fields/$fieldId';
  static String categories = 'categories';
  static String category({required String categoryId}) =>
      '$categories/$categoryId';
  static String collections = 'collections';
  static String sharedCollection({required String collectionId}) =>
      '$collections/$collectionId';
  static String sharedCollectionContent(
          {required String collectionId, required String contentId}) =>
      'collections/$collectionId/content/$contentId';
  static String sharedCollectionContents({required String collectionId}) =>
      '$collections/$collectionId/content';
  static String publicPosts = 'publicContent';
  static String publicPost({required postId}) => '$publicPosts/$postId';
}
