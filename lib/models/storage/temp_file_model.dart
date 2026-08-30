import 'package:image_picker/image_picker.dart';

class TempFileModel {
  final String uuid;
  final XFile file;
  String? key;
  String? path;
  bool isUploading;
  bool hasError;

  TempFileModel({
    required this.uuid,
    required this.file,
    this.key,
    this.path,
    this.isUploading = false,
    this.hasError = false,
  });

  Map<String, dynamic> toFinalPayload({required bool isMain}) {
    return {
      'uuid': uuid,
      'key': key,
      'path': path,
      'is_main': isMain,
    };
  }
}