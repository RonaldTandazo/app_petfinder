import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class LostPetEventRepository extends BaseRepository {
  static const String _prefix = '/lost-pet/events';

  Future<ApiResponse<Map<String, dynamic>>> store(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/store', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(int lostPetEventId) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/delete/$lostPetEventId'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}