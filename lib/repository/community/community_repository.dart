import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class CommunityRepository extends BaseRepository {
  static const String _prefix = '/community';

  Future<ApiResponse<Map<String, dynamic>>> getFormCatalog() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/form-catalog'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getPosts({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get(
        '$_prefix/posts',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      ),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> createPost(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/posts', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getPost(String postId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/posts/$postId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePost(String postId, Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/posts/$postId', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePost(String postId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/posts/$postId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getComments(String postId, {int page = 1, int limit = 20}) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/posts/$postId/comments', queryParameters: {'page': page, 'limit': limit}),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> createComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post(
        '$_prefix/posts/$postId/comments',
        data: {
          'content': content,
          'parent_id': ?parentId,
        },
      ),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> updateComment(String commentId, String content) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/comments/$commentId', data: {'content': content}),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteComment(String commentId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/comments/$commentId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleReaction(String postId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/posts/$postId/reactions'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> removeReaction(String postId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/posts/$postId/reactions'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}