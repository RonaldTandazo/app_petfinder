import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class CatalogRepository extends BaseRepository {
  static const String _prefix = '/catalog';

  Future<ApiResponse<Map<String, dynamic>>> getCatalogs() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/publish/pet'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}