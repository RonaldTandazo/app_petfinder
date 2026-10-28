import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:app_petfinder/core/utils/account_storage_service.dart';

class AccountRepository extends BaseRepository {
  static const String _prefix = '/profile';

  Future<ApiResponse<Map<String, dynamic>>> getProfile(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/index', queryParameters: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfileInfo({ bool forceRefresh = false }) async {
    if (!forceRefresh) {
      final cachedData = await AccountStorageService.getAccount();
      if (cachedData != null) {
        return ApiResponse(ok: true, message: 'Perfil Obtenido', data: cachedData, code: 200);
      }
    }

    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/edit'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    await AccountStorageService.saveAccount(response.data!);

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.put('$_prefix/update', data: data),
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