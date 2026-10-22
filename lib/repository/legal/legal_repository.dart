import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class LegalRepository extends BaseRepository {
  static const String _prefix = '/legal';

  Future<ApiResponse<Map<String, dynamic>>> acceptance(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/acceptance', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}