import 'package:app_petfinder/core/network/api_client.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:app_petfinder/core/utils/token_storage_service.dart';
import 'package:dio/dio.dart';

class AuthRepository extends BaseRepository {
  final Dio _api = ApiClient().dio;

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

    if (response.data != null && response.data!['access_token'] != null) {
      await TokenStorageService.saveToken(response.data!['access_token']);
    }

    return response;
  }

  Future<void> logout() async {
    try {
      await _api.post('$_prefix/logout');
    } catch (_) {
      // Incluso si falla la petición al servidor, eliminamos el token local
    } finally {
      await TokenStorageService.deleteToken();
    }
  }
}