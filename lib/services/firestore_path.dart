class FirestorePath {
  static String users = 'users';
  static String user({required String userId}) => 'users/$userId';

  static String userWorkspaces({required String userId}) =>
      'users/$userId/contexts';
  static String userWorkspace(
          {required String userId, required String workspaceId}) =>
      'users/$userId/contexts/$workspaceId';
  static String userDomains(
          {required String userId}) =>
      'users/$userId/domains';
 static String userDomain(
          {required String userId,
          required String domainId}) =>
      'users/$userId/domains/$domainId';
  static String userResources(
          {required String userId}) =>
      'users/$userId/resources';
  static String userResource(
          {required String userId,
          required String resourceId}) =>
      'users/$userId/resources/$resourceId';

  static String userFields({required String userId}) => '$users/$userId/fields';
  static String userField({required String userId, required String fieldId}) =>
      '$users/$userId/fields/$fieldId';
  static String categories = 'categories';
  static String category({required String categoryId}) =>
      '$categories/$categoryId';
  static String contexts = 'contexts';
  static String sharedWorkspace({required String contextId}) =>
      '$contexts/$contextId';
  static String sharedWorkspaceResource(
          {required String contextId, required String contentId}) =>
      'contexts/$contextId/content/$contentId';
  static String sharedWorkspaceResources({required String contextId}) =>
      '$contexts/$contextId/content';
  static String publicPosts = 'publicResource';
  static String publicPost({required postId}) => '$publicPosts/$postId';
}
