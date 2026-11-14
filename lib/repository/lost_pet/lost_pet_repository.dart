import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:dio/dio.dart';

class LostPetRepository extends BaseRepository {
  static const String _prefix = '/lost-pets';

  Future<ApiResponse<Map<String, dynamic>>> getLostPets(Map<String, dynamic> data, { CancelToken? cancelToken, }) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get(_prefix, queryParameters: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getLostPet(int lostPetId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/$lostPetId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> store(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/store', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> update(int lostPetId, Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/update/$lostPetId', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(int lostPetId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/delete/$lostPetId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> changeStatus(int lostPetId, Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/status/$lostPetId', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}