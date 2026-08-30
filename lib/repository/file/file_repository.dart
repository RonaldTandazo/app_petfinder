import 'package:dio/dio.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class FileRepository extends BaseRepository {
  static const String _prefix = '/storage';

  Future<ApiResponse<Map<String, dynamic>>> store(List<TempFileModel> items) async {
    final formData = FormData();

    for (var i = 0; i < items.length; i++) {
      formData.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(
            items[i].file.path,
            filename: items[i].file.name,
          ),
        ),
      );
      formData.fields.add(MapEntry('uuids[]', items[i].uuid));
    }

    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/temp', data: formData),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}