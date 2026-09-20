import 'package:image_picker/image_picker.dart';

class TempFileModel {
  final int? id;
  final String uuid;
  final XFile? file;
  final bool isExisting;
  String? key;
  String? path;
  bool isUploading;
  bool hasError;

  TempFileModel({
    this.id,
    required this.uuid,
    this.file,
    this.isExisting = false,
    this.key,
    this.path,
    this.isUploading = false,
    this.hasError = false,
  });

  Map<String, dynamic> toFinalPayload({ required bool isMain, required int sortOrder}) {
    if (isExisting) {
      return {
        'type': 'existing',
        'id': id,
        'is_main': isMain,
        'sort_order': sortOrder,
      };
    }

    return {
      'type': 'new',
      'uuid': uuid,
      'path_temp': key,
      'is_main': isMain,
      'sort_order': sortOrder,
    };
  }
}