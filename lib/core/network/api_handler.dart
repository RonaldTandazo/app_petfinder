import 'package:dio/dio.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/network/api_response.dart';

Future<ApiResponse<T>> safeApiCall<T>(
  Future<Response> Function() apiCall, {
  T Function(dynamic json)? fromJson,
}) async {
  try {
    final response = await apiCall();

    return ApiResponse<T>.fromJson(
      response.data,
      fromJson,
    );
  } on DioException catch (e) {
    if (e.error is ApiException) {
      throw e.error as ApiException;
    }
    throw ApiException(
      message: 'Error de conexión con el servidor',
      code: 500,
    );
  } catch (e) {
    throw ApiException(
      message: 'Error inesperado: ${e.toString()}',
      code: 500,
    );
  }
}