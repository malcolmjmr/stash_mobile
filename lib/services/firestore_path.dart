class FirestorePath {
  static String users = 'users';
  static String user({required String userId}) => 'users/$userId';

  static String userContexts({required String userId}) =>
      'users/$userId/contexts';
  static String userContext(
          {required String userId, required String contextId}) =>
      'users/$userId/contexts/$contextId';
  static String userResources(
          {required String userId}) =>
      'users/$userId/resources';
  static String userResource(
          {required String userId,
          required String resourceId}) =>
      'users/$userId/resource/$resourceId';

  static String userFields({required String userId}) => '$users/$userId/fields';
  static String userField({required String userId, required String fieldId}) =>
      '$users/$userId/fields/$fieldId';
  static String categories = 'categories';
  static String category({required String categoryId}) =>
      '$categories/$categoryId';
  static String contexts = 'contexts';
  static String sharedContext({required String contextId}) =>
      '$contexts/$contextId';
  static String sharedContextResource(
          {required String contextId, required String contentId}) =>
      'contexts/$contextId/content/$contentId';
  static String sharedContextResources({required String contextId}) =>
      '$contexts/$contextId/content';
  static String publicPosts = 'publicResource';
  static String publicPost({required postId}) => '$publicPosts/$postId';
}
