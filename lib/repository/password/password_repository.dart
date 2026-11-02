import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class PasswordRepository extends BaseRepository {
  static const String _prefix = '/password';

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/forgot', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}