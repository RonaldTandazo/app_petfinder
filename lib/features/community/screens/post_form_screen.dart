import 'dart:io';

import 'package:app_petfinder/core/network/api_client.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/core/utils/image_url_helper.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';
import 'package:app_petfinder/models/catalog/news_type_model.dart';
import 'package:app_petfinder/models/community/post_model.dart';
import 'package:app_petfinder/models/community/post_image_model.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/repository/community/community_repository.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PostFormScreen extends StatefulWidget {
  final PostModel? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _communityRepository = CommunityRepository();
  final _uuidGenerator = const Uuid();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  List<TempFileModel> _selectedImages = [];
  final List<File> _tempImages = [];
  String? _originalImagePath;
  List<NewsTypeModel> _newsTypes = [];
  int? _selectedNewsTypeId;

  bool _isLoading = true;
  bool _isShelter = false;
  Map<String, dynamic> _fieldErrors = {};

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _loadFormCatalog();
    _loadExistingPost();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _deleteTempImages();
    super.dispose();
  }

  void _deleteTempImages() {
    for (final tempFile in _tempImages) {
      try {
        tempFile.deleteSync();
      } on IOException {
      }
    }
  }

  Future<void> _loadExistingPost() async {
    final post = widget.post;
    if (post == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _communityRepository.getPost(post.id);
      if (!mounted) return;

      final data = response.data;
      if (data == null) return;

      final freshPost = PostModel.fromJson(data);

      _titleController.text = freshPost.title;
      _contentController.text = freshPost.content;
      _selectedNewsTypeId = freshPost.newsType.id;

      if (freshPost.images.isNotEmpty) {
        final existingImage = await _downloadExistingImage(freshPost.images.first);
        if (existingImage != null) {
          setState(() {
            _originalImagePath = existingImage.path;
            _selectedImages = [existingImage];
          });
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<TempFileModel?> _downloadExistingImage(PostImageModel image) async {
    final url = image.url;
    if (url == null || url.isEmpty) return null;

    try {
      final resolvedUrl = ImageUrlHelper.resolve(url);

      final response = await ApiClient().dio.get<List<int>>(
        resolvedUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      final fileUri = Uri.parse(resolvedUrl);
      final filename = fileUri.pathSegments.isNotEmpty ? fileUri.pathSegments.last : 'imagen.jpg';

      final dir = await getTemporaryDirectory();
      final tempFile = File(
        '${dir.path}${Platform.pathSeparator}post_edit_${_uuidGenerator.v4()}_$filename',
      );

      await tempFile.writeAsBytes(bytes, flush: true);
      _tempImages.add(tempFile);

      return TempFileModel(
        uuid: _uuidGenerator.v4(),
        file: XFile(tempFile.path, name: filename),
        path: image.path,
        isUploading: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadFormCatalog() async {
    try {
      final response = await _communityRepository.getFormCatalog();
      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null) {
          if (data['news_types'] is List) {
            _newsTypes = (data['news_types'] as List)
                .map((e) => NewsTypeModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          final me = data['me'];
          if (me is Map<String, dynamic>) {
            _isShelter = me['tutor_type'] == 'shelter';
          }

          if (_selectedNewsTypeId == null && _newsTypes.isNotEmpty) {
            _selectedNewsTypeId = _newsTypes.first.id;
          }
        }
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_isShelter) {
      AppSnackBar.show(
        context,
        title: 'Solo refugios',
        description: 'Solo los refugios pueden crear publicaciones en la comunidad.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (_selectedImages.isEmpty && (!_isEditing || _originalImagePath == null)) {
      AppSnackBar.show(
        context,
        title: 'Fotografía requerida',
        description: 'Por favor agrega al menos 1 fotografía a tu publicación.',
        type: SnackBarType.warning,
      );
      return;
    }

    final hasUploading = _selectedImages.any((img) => img.isUploading);
    if (hasUploading) {
      AppSnackBar.show(
        context,
        title: 'Imagen subiendo',
        description: 'Por favor espera a que termine de subirse la fotografía.',
        type: SnackBarType.warning,
      );
      return;
    }

    final hasErrors = _selectedImages.any((img) => img.hasError || img.key == null);
    if (hasErrors) {
      AppSnackBar.show(
        context,
        title: 'Error en la fotografía',
        description: 'La imagen falló al subirse. Elimínala o vuelve a intentarlo.',
        type: SnackBarType.error,
      );
      return;
    }

    if (_selectedNewsTypeId == null) {
      AppSnackBar.show(
        context,
        title: 'Tipo de noticia requerido',
        description: 'Selecciona el tipo de publicación.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final newsTypeId = _selectedNewsTypeId!;
    final images = _selectedImages.map((img) => img.key!).toList();

    final Map<String, dynamic> payload = {
      'title': title,
      'content': content,
      'news_type_id': newsTypeId,
    };

    if (_isEditing) {
      final post = widget.post!;

      final bool textChanged =
          title != post.title || content != post.content || newsTypeId != post.newsType.id;

      final bool imageChanged = _selectedImages.isNotEmpty
          ? _selectedImages.first.key != null
          : _originalImagePath != null;

      if (!textChanged && !imageChanged) {
        AppSnackBar.show(
          context,
          title: 'Sin cambios',
          description: 'No hay cambios que guardar.',
          type: SnackBarType.warning,
        );
        return;
      }

      payload['images'] = _updateImagesPayload();
    } else {
      payload['images'] = images;
    }

    AppLoadingOverlay.show(
      context,
      title: _isEditing ? 'Guardando publicación...' : 'Publicando...',
      description: 'Estamos procesando tu publicación.',
    );

    try {
      if (_isEditing) {
        await _communityRepository.updatePost(widget.post!.id, payload);
        if (!mounted) return;

        ApiSuccessHandler.handle(context, title: '¡Publicación actualizada!');
        context.pop(true);
      } else {
        final response = await _communityRepository.createPost(payload);
        if (!mounted) return;

        ApiSuccessHandler.handle(context, title: '¡Publicación creada!', description: response.message);
        context.pop(true);
      }
    } on ApiException catch (e) {
      if (e.code == 422 && e.error is Map<String, dynamic>) {
        setState(() {
          _fieldErrors = e.error as Map<String, dynamic>;
        });
      }

      ApiErrorHandler.handle(context, e);
    } finally {
      AppLoadingOverlay.hide();
    }
  }

  List<Map<String, dynamic>> _updateImagesPayload() {
    if (_selectedImages.isEmpty) return [];

    final image = _selectedImages.first;

    if (image.key != null) {
      return [{'path': null, 'path_temp': image.key}];
    }

    return [{'path': image.path, 'path_temp': null}];
  }

  String? _fieldValidator(String? value) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon, String field) {
    final errors = _fieldErrors[field];
    if (errors is List && errors.isNotEmpty) {
      return PetFormStyles.inputDecoration(label, icon).copyWith(errorText: errors.first.toString());
    }

    return PetFormStyles.inputDecoration(label, icon);
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() {
        _fieldErrors.remove(field);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Publicación' : 'Nueva Publicación',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  PetFormStyles.buildSectionHeader('Fotografía', 'Sube 1 imagen de la publicación'),
                  const SizedBox(height: 12),
                  AppImagePickerGrid(
                    images: _selectedImages,
                    maxImages: 1,
                    onImagesChanged: (updatedList) {
                      setState(() {
                        _selectedImages = updatedList;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  PetFormStyles.buildSectionHeader('Detalles', 'Información de tu publicación'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedNewsTypeId,
                    decoration: PetFormStyles.inputDecoration('Tipo de noticia *', Icons.newspaper_rounded),
                    items: _newsTypes.map((item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedNewsTypeId = val),
                    validator: (val) => val == null ? 'Selecciona un tipo' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _titleController,
                    maxLength: 140,
                    onChanged: (_) => _clearFieldError('title'),
                    decoration: _inputDecoration('Título *', Icons.title_rounded, 'title'),
                    validator: _fieldValidator,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _contentController,
                    maxLines: 6,
                    maxLength: 2000,
                    onChanged: (_) => _clearFieldError('content'),
                    decoration: _inputDecoration(
                      'Contenido *',
                      Icons.description_rounded,
                      'content',
                    ),
                    validator: _fieldValidator,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _isEditing ? 'Guardar Cambios' : 'Publicar',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}