import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/repository/pet/pet_repository.dart';
import 'package:app_petfinder/widgets/app_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/models/catalog/animal_gender_model.dart';
import 'package:app_petfinder/models/catalog/health_condition_model.dart';
import 'package:app_petfinder/models/catalog/size_model.dart';
import 'package:app_petfinder/models/catalog/species_model.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/app_datepicker.dart';
import 'package:app_petfinder/widgets/app_image_picker_bottom_sheet.dart';
import 'package:app_petfinder/widgets/app_snackbar.dart';
import 'package:app_petfinder/widgets/app_image_picker_grid.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';
import 'package:app_petfinder/features/pet/widgets/health_status_card.dart';

class PublishPetScreen extends StatefulWidget {
  const PublishPetScreen({super.key});

  @override
  State<PublishPetScreen> createState() => _PublishPetScreenState();
}

class _PublishPetScreenState extends State<PublishPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalogRepository = CatalogRepository();
  final _petRepository = PetRepository();

  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedSpeciesId;
  int? _selectedGenderId;
  int? _selectedSizeId;
  DateTime? _selectedBornDate;

  final Set<int> _selectedHealthConditionIds = {};

  List<SpeciesModel> _speciesList = [];
  List<AnimalGenderModel> _gendersList = [];
  List<SizeModel> _sizesList = [];
  List<HealthConditionModel> _healthConditionsList = [];

  bool _isLoadingCatalog = true;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFormCatalogs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFormCatalogs() async {
    try {
      final response = await _catalogRepository.getCatalogs();

      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null) {
          if (data['species'] is List) {
            _speciesList = (data['species'] as List)
                .map((e) => SpeciesModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          if (data['genders'] is List) {
            _gendersList = (data['genders'] as List)
                .map((e) => AnimalGenderModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          if (data['sizes'] is List) {
            _sizesList = (data['sizes'] as List)
                .map((e) => SizeModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }

          if (data['health_conditions'] is List) {
            _healthConditionsList = (data['health_conditions'] as List)
                .map((e) => HealthConditionModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      });
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingCatalog = false);
      }
    }
  }

  void _showImageSourceOptions() async {
    if (_selectedImages.length >= 5) {
      AppSnackBar.show(
        context,
        title: 'Límite alcanzado',
        description: 'Ya has seleccionado el máximo de 5 fotos.',
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
      if (source == ImageSource.camera) {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
        if (photo != null) setState(() => _selectedImages.add(photo));
      } else {
        final int maxAllowed = 5 - _selectedImages.length;
        final List<XFile> images = await _picker.pickMultiImage(limit: maxAllowed, imageQuality: 80);
        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images);
            if (_selectedImages.length > 5) {
              _selectedImages.removeRange(5, _selectedImages.length);
            }
          });
        }
      }
    } catch (_) {
      AppSnackBar.show(
        context,
        title: 'Error de imagen',
        description: 'No se pudo cargar la imagen. Inténtalo de nuevo.',
        type: SnackBarType.error,
      );
    }
  }

  void _toggleHealthCondition(int conditionId) {
    setState(() {
      if (_selectedHealthConditionIds.contains(conditionId)) {
        _selectedHealthConditionIds.remove(conditionId);
      } else {
        _selectedHealthConditionIds.add(conditionId);
      }
    });
  }

  void _submitForm() async {
    if (_selectedImages.isEmpty) {
      AppSnackBar.show(
        context,
        title: 'Fotografías requeridas',
        description: 'Por favor agrega al menos 1 fotografía de la mascota.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> payload = {
      'name': _nameController.text.trim(),
      'species_id': _selectedSpeciesId,
      'animal_gender_id': _selectedGenderId,
      'size_id': _selectedSizeId,
      'race': _raceController.text.trim().isEmpty ? null : _raceController.text.trim(),
      'color': _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      'born_date': _selectedBornDate?.toIso8601String().split('T').first,
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'health_conditions': _selectedHealthConditionIds.toList(),
    };

    AppLoadingOverlay.show(
      context,
      title: 'Publicando mascota en adopción...',
      description: 'Estamos registrando los datos y procesando la información',
    );

    try {

      final response = await _petRepository.store(payload);

      if (!mounted) return;

      AppSnackBar.show(
        context,
        title: '¡Publicación creada!',
        description: response.message,
        type: SnackBarType.success,
      );

      ApiSuccessHandler.handle(context, title: '¡Publicación creada!', description: response.message);

      context.pop();
    } on ApiException catch (e) {
        ApiErrorHandler.handle(context, e);
    } finally {
      AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Dar en Adopción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingCatalog ? const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            PetFormStyles.buildSectionHeader('Fotografías', 'Sube hasta 5 fotos claras (mínimo 1)'),
            const SizedBox(height: 12),
            AppImagePickerGrid(
              images: _selectedImages,
              onAddPressed: _showImageSourceOptions,
              onRemovePressed: (index) => setState(() => _selectedImages.removeAt(index)),
            ),
            const SizedBox(height: 24),

            PetFormStyles.buildSectionHeader('Información General', 'Datos requeridos de la mascota'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: PetFormStyles.inputDecoration('Nombre de la mascota *', Icons.pets),
              validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedSpeciesId,
                    decoration: PetFormStyles.inputDecoration('Especie *', Icons.category_rounded),
                    items: _speciesList.map((item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name), 
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedSpeciesId = val),
                    validator: (val) => val == null ? 'Selecciona' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedGenderId,
                    decoration: PetFormStyles.inputDecoration('Sexo *', Icons.transgender_rounded),
                    items: _gendersList.map((item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedGenderId = val),
                    validator: (val) => val == null ? 'Selecciona' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedSizeId,
                    decoration: PetFormStyles.inputDecoration('Tamaño *', Icons.straighten_rounded),
                    items: _sizesList.map((item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.name),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedSizeId = val),
                    validator: (val) => val == null ? 'Selecciona' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDatePicker(
                    label: 'Aprox. Nacimiento *',
                    icon: Icons.cake_rounded,
                    selectionType: DateSelectionType.single,
                    filterType: DateFilterType.disableFuture,
                    selectedDate: _selectedBornDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedBornDate = date;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value == 'Seleccionar fecha') {
                        return 'Selecciona fecha';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _raceController,
                    decoration: PetFormStyles.inputDecoration('Raza / Mezcla', Icons.merge_type_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _colorController,
                    decoration: PetFormStyles.inputDecoration('Color principal', Icons.palette_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            PetFormStyles.buildSectionHeader('Estado de Salud', 'Información clave para los adoptantes'),
            const SizedBox(height: 8),
            HealthStatusCard(
              healthConditions: _healthConditionsList,
              selectedConditionIds: _selectedHealthConditionIds,
              onConditionToggled: _toggleHealthCondition,
            ),
            const SizedBox(height: 24),

            PetFormStyles.buildSectionHeader('Historia y Personalidad', 'Cuéntale a la comunidad sobre la mascota'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: PetFormStyles.inputDecoration(
                'Describe su carácter, convivencia con niños u otros animales...',
                Icons.description_rounded,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Publicar en Adopción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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