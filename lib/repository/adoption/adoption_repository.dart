import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class AdoptionRepository extends BaseRepository {
  static const String _prefix = '/adoptions';

  Future<ApiResponse<Map<String, dynamic>>> getAdoptionPets(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/pets', queryParameters: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getAdoptionPet(int petId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/pets/$petId'),
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

  Future<ApiResponse<Map<String, dynamic>>> setFollowState(int petId, Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/follow/$petId', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}