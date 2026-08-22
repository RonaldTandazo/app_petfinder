import 'package:app_petfinder/core/network/api_client.dart';
import 'package:app_petfinder/core/network/api_handler.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:dio/dio.dart';

abstract class BaseRepository {
  final Dio api = ApiClient().dio;

  Future<ApiResponse<T>> safeCall<T>(
    Future<Response> Function() apiCall, {
    T Function(dynamic json)? fromJson,
  }) {
    return safeApiCall<T>(apiCall, fromJson: fromJson);
  }
}