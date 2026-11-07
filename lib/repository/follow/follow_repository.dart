import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:dio/dio.dart';

class FollowRepository extends BaseRepository {
  static const String _prefix = '/follow';

  Future<ApiResponse<Map<String, dynamic>>> petPetFollowindex() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/index'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getPetFollows(Map<String, dynamic> data, { CancelToken? cancelToken, }) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/pets', queryParameters: data, cancelToken: cancelToken),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> setPetFollow(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/pet', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}