import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/enums/help/help_form_type.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';


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
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _commentController = TextEditingController();

  List<TempFileModel> _selectedImages = [];
  int _mainImageIndex = 0;

  String? _selectedCategory;

  bool get _isSupport => widget.type == HelpFormType.support;
  String get _titleScreen => _isSupport ? 'Centro de Ayuda' : 'Comentarios y Sugerencias';

  @override
  void dispose() {
    _subjectController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Todavía no se envían datos al backend.
    // Aquí conectaremos el repositorio y la subida de imágenes.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El envío todavía no está disponible.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isTablet = screenSize.width >= 600;

    final double horizontalPadding = isSmallPhone
      ? 12.0
      : isTablet
          ? 32.0
          : 20.0;

    return Scaffold(
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
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
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
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        if (_isSupport) ...[
                          _buildLabel('Título del problema'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _subjectController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              hintText:
                                  'Ej. No puedo publicar una mascota',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.title_rounded,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Ingresa un título.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          _buildLabel('Tipo de sugerencia'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.category_outlined,
                              ),
                            ),
                            hint: const Text('Selecciona una categoría'),
                            items: const [
                              DropdownMenuItem(
                                value: 'feature',
                                child: Text('Nueva funcionalidad'),
                              ),
                              DropdownMenuItem(
                                value: 'improvement',
                                child: Text('Mejora de una función'),
                              ),
                              DropdownMenuItem(
                                value: 'design',
                                child: Text('Diseño y experiencia'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text('Otro'),
                              ),
                            ],
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
                          const SizedBox(height: 16),
                        ],

                        _buildLabel(
                          _isSupport
                              ? 'Descripción del problema'
                              : 'Tu comentario',
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _commentController,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          minLines: 5,
                          maxLines: 8,
                          maxLength: 3000,
                          decoration: InputDecoration(
                            hintText: _isSupport
                                ? '¿Qué ocurrió? ¿Qué esperabas que sucediera?'
                                : '¿Qué te gustaría que mejoráramos?',
                            alignLabelWithHint: true,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Escribe una descripción.';
                            }
                            if (value.trim().length < 10) {
                              return 'Escribe al menos 10 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel(
                          'Imágenes (opcional)',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSupport
                              ? 'Puedes adjuntar capturas del error.'
                              : 'Puedes adjuntar imágenes de referencia.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),

                        AppImagePickerGrid(
                          images: _selectedImages,
                          enableMainSelection: true,
                          selectedIndex: _mainImageIndex,
                          onImagesChanged: (updatedList) {
                            setState(() {
                              _selectedImages = updatedList;
                            });
                          },
                          onSelectMain: (newIndex) {
                            setState(() {
                              _mainImageIndex = newIndex;
                            });
                          },
                        ),

                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(
                            Icons.send_rounded,
                          ),
                          label: const Text('Enviar comentario'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
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
                            color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
