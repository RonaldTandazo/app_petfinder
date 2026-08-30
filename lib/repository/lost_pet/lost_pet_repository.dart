import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class LostPetRepository extends BaseRepository {
  static const String _prefix = '/lost-pets';

  Future<ApiResponse<Map<String, dynamic>>> store(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/store', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}