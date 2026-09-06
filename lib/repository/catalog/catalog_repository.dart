import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';
import 'package:app_petfinder/core/utils/catalog_storage_service.dart';

class CatalogRepository extends BaseRepository {
  static const String _prefix = '/catalog';

  Future<ApiResponse<Map<String, dynamic>>> getPetCatalogs({ bool forceRefresh = false }) async {
    if (!forceRefresh) {
      final cachedData = await CatalogStorageService.getPetCatalogs();
      if (cachedData != null) {
        return ApiResponse(ok: true, message: 'Catálogo Obtenido', data: cachedData, code: 200);
      }
    }

    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/pets'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    await CatalogStorageService.savePetCatalogs(response.data!);

    return response;
  }
}