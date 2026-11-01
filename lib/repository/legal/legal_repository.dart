import 'package:dio/dio.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:app_petfinder/core/network/api_response.dart';

class LegalRepository extends BaseRepository {
  static const String _prefix = '/legal';

  Future<ApiResponse<Map<String, dynamic>>> getDocument(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/document', queryParameters: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }

  Future<List<int>> downloadPdf(Map<String, dynamic> data) async {
    return safeFileCall(
      () => api.get<List<int>>(
        '$_prefix/document/download/pdf',
        queryParameters: data,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      ),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> acceptance(Map<String, dynamic> data) async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/acceptance', data: data),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}