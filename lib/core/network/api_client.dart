import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/app_router.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/utils/token_storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    const String baseUrl = 'http://192.168.100.61:8000/api';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('[${options.method.toUpperCase()}] ${options.path}');
          }

          final token = await TokenStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          if (statusCode == 401) {
            await TokenStorageService.deleteToken();

            final context = rootNavigatorKey.currentContext;
            if (context != null) {
              context.go(AuthRoutes.login);
            }
          }

          if (error.response?.data != null && error.response?.data is Map<String, dynamic>) {
            final json = error.response!.data;
            
            final apiException = ApiException(
              message: json['message'] ?? 'Ha ocurrido un error inesperado',
              code: json['code'] ?? error.response?.statusCode ?? 500,
              error: json['error'],
            );

            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: apiException,
                response: error.response,
                type: error.type,
              ),
            );
          }

          return handler.next(error);
        }
      ),
    );
  }
}