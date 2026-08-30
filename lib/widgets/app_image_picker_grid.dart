import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/repository/file/file_repository.dart';
import 'package:app_petfinder/widgets/app_add_image_tile.dart';
import 'package:app_petfinder/widgets/app_image_tile.dart';
import 'package:app_petfinder/widgets/app_image_picker_bottom_sheet.dart';
import 'package:app_petfinder/widgets/app_snackbar.dart';
import 'package:app_petfinder/core/network/api_exception.dart';

class AppImagePickerGrid extends StatefulWidget {
  final List<TempFileModel> images;
  final int maxImages;
  final bool enableMainSelection;
  final int selectedIndex;
  final ValueChanged<List<TempFileModel>> onImagesChanged;
  final ValueChanged<int>? onSelectMain;

  const AppImagePickerGrid({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.enableMainSelection = false,
    this.selectedIndex = 0,
    this.onSelectMain,
  });

  @override
  State<AppImagePickerGrid> createState() => _AppImagePickerGridState();
}

class _AppImagePickerGridState extends State<AppImagePickerGrid> {
  final FileRepository _fileRepository = FileRepository();
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuidGenerator = const Uuid();

  void _showImageSourceOptions() async {
    if (widget.images.length >= widget.maxImages) {
      AppSnackBar.show(
        context,
        title: 'Límite alcanzado',
        description: 'Ya has seleccionado el máximo de ${widget.maxImages} fotos.',
        type: SnackBarType.warning,
      );
      return;
    }

    final source = await AppImagePickerBottomSheet.show(context);
    if (source == null) return;

    _pickImageFromSource(source);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      List<XFile> pickedFiles = [];

      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
        if (photo != null) pickedFiles.add(photo);
      } else {
        final int maxAllowed = widget.maxImages - widget.images.length;
        final List<XFile> images = await _picker.pickMultiImage(limit: maxAllowed, imageQuality: 80);
        if (images.isNotEmpty) pickedFiles.addAll(images);
      }

      if (pickedFiles.isEmpty) return;

      final newItems = pickedFiles.map((file) {
        return TempFileModel(
          uuid: _uuidGenerator.v4(),
          file: file,
          isUploading: true,
        );
      }).toList();

      final updatedList = List<TempFileModel>.from(widget.images)..addAll(newItems);
      widget.onImagesChanged(updatedList);

      _uploadImagesInChunks(newItems, chunkSize: 5);
    } catch (_) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        title: 'Error de imagen',
        description: 'No se pudo cargar la imagen. Inténtalo de nuevo.',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _uploadImagesInChunks(List<TempFileModel> itemsToUpload, {int chunkSize = 5}) async {
    for (var i = 0; i < itemsToUpload.length; i += chunkSize) {
      final end = (i + chunkSize < itemsToUpload.length) ? i + chunkSize : itemsToUpload.length;
      final chunk = itemsToUpload.sublist(i, end);

      _processBatchUpload(chunk);
    }
  }

  Future<void> _processBatchUpload(List<TempFileModel> chunk) async {
    try {
      final response = await _fileRepository.store(chunk);
      if (!mounted) return;

      final data = response.data;
      if (data == null || data['files'] == null) return;

      final currentList = List<TempFileModel>.from(widget.images);

      for (var res in data['files']) {
        final String serverKey = res['key'];
        final String url = res['url'];

        final index = currentList.indexWhere((element) => serverKey.startsWith(element.uuid));

        if (index != -1) {
          currentList[index].key = serverKey;
          currentList[index].path = url;
          currentList[index].isUploading = false;
        }
      }

      widget.onImagesChanged(currentList);
    } on ApiException catch (e) {
      if (!mounted) return;

      final failedUuids = chunk.map((e) => e.uuid).toSet();
      final cleanedList = List<TempFileModel>.from(widget.images)
        ..removeWhere((img) => failedUuids.contains(img.uuid));

      _adjustMainIndex(cleanedList.length);

      widget.onImagesChanged(cleanedList);

      ApiErrorHandler.handle(context, e);
    }
  }

  void _adjustMainIndex(int remainingLength) {
    if (!widget.enableMainSelection || widget.onSelectMain == null) return;

    if (remainingLength == 0) {
      widget.onSelectMain!(0);
    } else if (widget.selectedIndex >= remainingLength) {
      widget.onSelectMain!(remainingLength - 1);
    }
  }

  void _removeImage(int index) {
    final currentList = List<TempFileModel>.from(widget.images)..removeAt(index);
    
    _adjustMainIndex(currentList.length);

    widget.onImagesChanged(currentList);
  }

  @override
  Widget build(BuildContext context) {
    final showAddButton = widget.images.length < widget.maxImages;
    final totalItems = showAddButton ? widget.images.length + 1 : widget.maxImages;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalItems,
        itemBuilder: (context, index) {
          if (index == widget.images.length && showAddButton) {
            return AppAddImageTile(
              currentCount: widget.images.length,
              maxImages: widget.maxImages,
              onTap: _showImageSourceOptions,
            );
          }

          final image = widget.images[index];
          final isMain = widget.enableMainSelection && index == widget.selectedIndex;

          return AppImageTile(
            image: image.file,
            isMain: isMain,
            enableMainSelection: widget.enableMainSelection,
            onTap: widget.enableMainSelection ? () => widget.onSelectMain?.call(index) : null,
            onRemove: () => _removeImage(index),
          );
        },
      ),
    );
  }
}