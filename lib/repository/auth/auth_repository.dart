import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:app_petfinder/core/utils/token_storage_service.dart';
import 'package:app_petfinder/core/utils/session_info.dart';

class AuthRepository extends BaseRepository {
  static const String _prefix = '/auth';

  Future<ApiResponse<Map<String, dynamic>>> registerUser(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/register/user', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> registerShelter(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/register/shelter', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> login(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/login', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data != null) {
      final res = response.data!;

      if (res['access_token'] != null) {
        await TokenStorageService.saveToken(res['access_token']);
      }

      if (res['session_info'] != null) {
        await SessionInfo.saveSession(res['session_info'] as Map<String, dynamic>);
      }
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> checkAuthStatus() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/me'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data != null) {
      await SessionInfo.saveSession(response.data!);
    } else {
      await TokenStorageService.deleteToken();
      await SessionInfo.clearSession();
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/logout'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    await TokenStorageService.deleteToken();
    await SessionInfo.clearSession();

    return response;
  }
}