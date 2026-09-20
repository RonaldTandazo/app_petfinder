import 'package:dio/dio.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/repository/base_repository.dart';

class FileRepository extends BaseRepository {
  static const String _prefix = '/storage';

  Future<ApiResponse<Map<String, dynamic>>> store(List<TempFileModel> items) async {
    final newItems = items.where((item) => !item.isExisting).toList();

    if (newItems.isEmpty) {
      return ApiResponse(ok: true, message: 'Imágenes Subidad', data: {'files': []}, code: 200);
    }

    final formData = FormData();

    for (final TempFileModel item in newItems) {
      formData.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(
            item.file!.path,
            filename: item.file!.name,
          ),
        ),
      );

      formData.fields.add(
        MapEntry(
          'uuids[]',
          item.uuid,
        ),
      );
    }

    final response = await safeCall<Map<String, dynamic>>(
      () => api.post('$_prefix/temp', data: formData),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response;
  }
}