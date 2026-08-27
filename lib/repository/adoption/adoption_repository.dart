import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class AdoptionRepository extends BaseRepository {
  static const String _prefix = '/adoptions';

  Future<ApiResponse<Map<String, dynamic>>> getAdoptionPets() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.get('$_prefix/pets'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}