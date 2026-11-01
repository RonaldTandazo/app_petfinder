import 'dart:convert';
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
    if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
      rethrow;
    }

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

Future<List<int>> safeFileApiCall(
  Future<Response<List<int>>> Function() apiCall,
) async {
  try {
    final response = await apiCall();
    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      throw ApiException(
        message: 'El archivo recibido está vacío',
        code: 500,
      );
    }

    return bytes;

  } on DioException catch (e) {
    if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
      rethrow;
    }

    final errorData = e.response?.data;

    if (errorData != null) {
      try {
        final dynamic decoded = errorData is List<int>
            ? jsonDecode(utf8.decode(errorData))
            : errorData;

        if (decoded is Map<String, dynamic>) {
          throw ApiException(
            message: decoded['message'] ?? 'Error al descargar el archivo',
            code: decoded['code'] ?? e.response?.statusCode ?? 500,
            error: decoded['error'],
          );
        }
      } on ApiException {
        rethrow;
      } catch (_) {
        // La respuesta no contiene un JSON válido.
      }
    }

    if (e.error is ApiException) {
      throw e.error as ApiException;
    }

    throw ApiException(
      message: 'No se pudo descargar el archivo',
      code: e.response?.statusCode ?? 500,
    );

  } catch (e) {
    if (e is ApiException) rethrow;

    throw ApiException(
      message: 'Error inesperado: ${e.toString()}',
      code: 500,
    );
  }
}