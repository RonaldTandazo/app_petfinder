import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/enums/help/help_form_type.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/styles/app_form_styles.dart';
import 'package:app_petfinder/repository/help/help_repository.dart';

class HelpFormScreen extends StatefulWidget {
  final HelpFormType type;

  const HelpFormScreen({
    super.key,
    required this.type,
  });

  @override
  State<HelpFormScreen> createState() => _HelpFormScreenState();
}

class _HelpFormScreenState extends State<HelpFormScreen> {
  final HelpRepository _helpRepository = HelpRepository();
  
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _commentController = TextEditingController();


  List<TempFileModel> _selectedImages = [];

  String? _selectedCategory;

  bool get _isSupport => widget.type == HelpFormType.support;
  String get _titleScreen => _isSupport ? 'Centro de Ayuda' : 'Comentarios y Sugerencias';
  String get _typeHint => _isSupport ? 'Soporte':'Feedback';

  final List<Map<String, String>> _categories = [
    {'value': 'feature', 'label': 'Nueva Funcionalidad'},
    {'value': 'improvement', 'label': 'Mejora de Funcionalidad'},
    {'value': 'design', 'label': 'Diseño y Experiencia'},
    {'value': 'other', 'label': 'Otro'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool hasUploading = _selectedImages.any((img) => img.isUploading);
    if (hasUploading) {
      AppSnackBar.show(
        context,
        title: 'Subiendo Imágenes',
        description: 'Por favor espera a que terminen de subirse las fotografías.',
        type: StatusType.warning,
      );
      return;
    }

    final List<Map<String, dynamic>> photosPayload = _selectedImages.asMap().entries.map((entry) {
      final int index = entry.key;
      final TempFileModel image = entry.value;

      return image.toFinalPayload(
        isMain: false,
        sortOrder: index,
      );
    }).toList();

    String? subject;
    if(_isSupport){
      subject = _subjectController.text.trim().isEmpty
        ? null
        : _subjectController.text.trim();
    } else{
      subject = _selectedCategory?.trim();
    }

    final Map<String, dynamic> payload = {
      'subject': subject,
      'comment': _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      'photos': photosPayload,
    };

    AppLoadingOverlay.show(
      context,
      title: 'Registrando $_typeHint...',
      description: 'Estamos registrando el $_typeHint'
    );

    ApiResponse? response;

    try {
      if(_isSupport){
        response = await _helpRepository.support(payload);
      }else{
        response = await _helpRepository.feedback(payload);
      }
      
      if (!mounted) return;

      ApiSuccessHandler.handle(
        context,
        title: '$_typeHint Registrado',
        description: response.message
      );

      context.pop(true);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if(mounted) AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isSmallPhone
      ? 12.0
      : isTablet
          ? 32.0
          : 20.0;

    final double spacing = isSmallPhone ? 12 : 16;
    final double sectionSpacing = isSmallPhone ? 20.0 : 24.0;
    final double fieldSpacing = isSmallPhone ? 12.0 : 14.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _titleScreen,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 700 : 520,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _isSupport
                              ? Icons.bug_report_outlined
                              : Icons.lightbulb_outline_rounded,
                          size: isSmallPhone ? 44 : 56,
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: spacing),
                        Text(
                          _isSupport
                              ? 'Cuéntanos qué problema encontraste'
                              : 'Ayúdanos a mejorar PetFinder',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSupport
                              ? 'Describe el error y, si puedes, '
                                  'adjunta imágenes que nos ayuden '
                                  'a entenderlo.'
                              : 'Comparte tu idea o sugerencia. '
                                  'Puedes adjuntar imágenes para '
                                  'explicarla mejor.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: isSmallPhone ? 20 : 28),

                        if (_isSupport) ...[
                          TextFormField(
                            controller: _subjectController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 100,
                            decoration: AppFormStyles.inputDecoration(
                              context,
                              'Título del Problema',
                              Icons.title_rounded,
                            ).copyWith(
                              hintText: 'Ej. No puedo publicar una mascota',
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Ingresa un título.';
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            isExpanded: true,
                            decoration: AppFormStyles.inputDecoration(
                              context,
                              'Tipo de Sugerencia',
                              Icons.category_outlined,
                            ),
                            hint: const Text('Selecciona una Categoría'),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['label'],
                                child: Text(category['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una categoría.';
                              }
                              return null;
                            },
                          ),
                        ],

                        SizedBox(height: fieldSpacing),

                        TextFormField(
                          controller: _commentController,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          minLines: 5,
                          maxLines: 8,
                          maxLength: 3000,
                          decoration: AppFormStyles.inputDecoration(
                            context,
                            _isSupport
                              ? '¿Qué ocurrió? ¿Qué esperabas que sucediera?'
                              : '¿Qué te gustaría que mejoráramos?',
                            Icons.description_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Escribe una descripción';
                            }

                            if (value.trim().length < 10) {
                              return 'Escribe al menos 10 caracteres';
                            }
                            
                            return null;
                          },
                        ),

                        SizedBox(height: sectionSpacing),

                        AppFormStyles.buildSectionHeader(
                          context,
                          'Imágenes (opcional)',
                          _isSupport
                              ? 'Puedes adjuntar capturas del error'
                              : 'Puedes adjuntar imágenes de referencia',
                        ),
                        const SizedBox(height: 12),

                        AppImagePickerGrid(
                          images: _selectedImages,
                          onImagesChanged: (updatedList) {
                            setState(() {
                              _selectedImages = updatedList;
                            });
                          },
                        ),

                        SizedBox(height: sectionSpacing),

                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _submitForm,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded),
                            label: Text(
                              'Enviar Comentario',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'No incluyas contraseñas ni información '
                          'personal sensible en tu comentario '
                          'o en las imágenes.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
