import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class ManagementRepository extends BaseRepository {
  static const String _prefix = '/management';

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    final response = await safeCall<Map<String, dynamic>>(
      () => api.delete('$_prefix/delete-profile'),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}