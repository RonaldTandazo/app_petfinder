import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class HelpRepository extends BaseRepository {
  static const String _prefix = '/help';

  Future<ApiResponse<Map<String, dynamic>>> feedback(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/feedback/store', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> support(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/support/store', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}