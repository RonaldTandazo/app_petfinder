import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class AccountRepository extends BaseRepository {
  static const String _prefix = '/account';

  Future<ApiResponse<Map<String, dynamic>>> getFormCatalog() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/form-catalog'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/profile', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePassword(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/password', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}