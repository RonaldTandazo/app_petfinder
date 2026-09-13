import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/enums/datepicker/date_filter_type.dart';
import 'package:app_petfinder/enums/datepicker/date_selection_type.dart';
import 'package:app_petfinder/repository/adoption/adoption_repository.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/models/catalog/animal_gender_model.dart';
import 'package:app_petfinder/models/catalog/health_condition_model.dart';
import 'package:app_petfinder/models/catalog/size_model.dart';
import 'package:app_petfinder/models/catalog/species_model.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/datepickers/app_datepicker.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';
import 'package:app_petfinder/features/adoption/widgets/health_status_card.dart';
import 'package:app_petfinder/widgets/toggles/app_toggle_tile.dart';
import 'package:app_petfinder/widgets/contact/app_contact_phone_fields.dart';
import 'package:app_petfinder/widgets/locations/app_location_picket_tile.dart';
import 'package:app_petfinder/core/network/api_response.dart';
import 'package:app_petfinder/features/lost_pet/widgets/publish_pet_skeleton.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/core/router/main/main_routes.dart';

class PublishAdoptionPetScreen extends StatefulWidget {
  final int? petId;

  const PublishAdoptionPetScreen({
    super.key,
    this.petId
  });

  @override
  State<PublishAdoptionPetScreen> createState() => _PublishAdoptionPetScreenState();
}

class _PublishAdoptionPetScreenState extends State<PublishAdoptionPetScreen> {
  final CatalogRepository _catalogRepository = CatalogRepository();
  final AdoptionRepository _adoptionRepository = AdoptionRepository();
  final _formKey = GlobalKey<FormState>();

  Set<int> _selectedHealthConditionIds = {};
  List<TempFileModel> _selectedImages = [];

  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _colorController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneHomeController = TextEditingController();
  final _phoneMobileController = TextEditingController();
  final _descriptionController = TextEditingController();

  String titleScreen = 'Dar en Adopción';
  String submitButton =  'Publicar en Adopción';

  bool _isLoadingCatalog = true;
  bool _isLoadingPet = false;
  int _mainImageIndex = 0;
  int? _selectedSizeId;
  int? _selectedGenderId;
  int? _selectedSpeciesId;
  DateTime? _selectedBornDate;
  bool _isUrgent = false;
  double? _latitude;
  double? _longitude;

  List<SpeciesModel> _speciesList = [];
  List<AnimalGenderModel> _gendersList = [];
  List<SizeModel> _sizesList = [];
  List<HealthConditionModel> _healthConditionsList = [];

  bool get _isLoadingForm => _isLoadingCatalog || _isLoadingPet;
  bool get _isUpdate => widget.petId != null;

  @override
  void initState() {
    super.initState();

    _loadFormCatalogs();
  
    if (_isUpdate) {
      titleScreen = 'Editar Adopción de Mascota';
      submitButton = 'Guardar Cambios';

      _loadPet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _colorController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneMobileController.dispose();
    _phoneHomeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFormCatalogs() async {
    try {
      final response = await _catalogRepository.getPetCatalogs();
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
      if (mounted) setState(() => _isLoadingCatalog = false);
    }
  }

  Future<void> _loadPet() async {
    if (!mounted) return;

    setState(() => _isLoadingPet = true);

    try {
      final response = await _adoptionRepository.getAdoptionPet(widget.petId!);
      if (!mounted) return;

      final data = response.data;

      if (data != null) {
        if (data['pet'] != null) {
          final Map<String, dynamic> adoptionPetJson = data['pet'];

          final AdoptionPetModel adoptionPet = AdoptionPetModel.fromJson(adoptionPetJson);

          setState(() {
            _nameController.text = adoptionPet.name;
            _selectedSpeciesId = adoptionPet.speciesId;
            _selectedGenderId = adoptionPet.genderId;
            _selectedSizeId = adoptionPet.sizeId;
            _selectedBornDate = adoptionPet.bornDate;
            _raceController.text = adoptionPet.race ?? '';
            _colorController.text = adoptionPet.color ?? '';
            _cityController.text = adoptionPet.city;
            _addressController.text = adoptionPet.address;
            _latitude = adoptionPet.latitude;
            _longitude = adoptionPet.longitude;
            _phoneMobileController.text = adoptionPet.phoneMobile ?? '';
            _phoneHomeController.text = adoptionPet.phoneHome ?? '';
            _isUrgent = adoptionPet.isUrgent;
            _selectedHealthConditionIds = adoptionPet.healthConditions.map((condition) => (condition['id'] as num).toInt()).toSet();
            _descriptionController.text = adoptionPet.description ?? '';
          });
        }
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoadingPet = false);
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

  Future<void> _submitForm() async {
    if (_selectedImages.isEmpty) {
      AppSnackBar.show(
        context,
        title: 'Fotografías requeridas',
        description: 'Por favor agrega al menos 1 fotografía de la mascota.',
        type: SnackBarType.warning,
      );
      return;
    }

    final bool hasUploading = _selectedImages.any((img) => img.isUploading);
    if (hasUploading) {
      AppSnackBar.show(
        context,
        title: 'Imágenes subiendo',
        description: 'Por favor espera a que terminen de subirse las fotografías.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final List<Map<String, dynamic>> photosPayload = _selectedImages.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return {
        'path_temp': item.key,
        'is_main': idx == _mainImageIndex,
      };
    }).toList();

    final Map<String, dynamic> payload = {
      'name': _nameController.text.trim(),
      'species_id': _selectedSpeciesId,
      'animal_gender_id': _selectedGenderId,
      'size_id': _selectedSizeId,
      'race': _raceController.text.trim().isEmpty ? null : _raceController.text.trim(),
      'color': _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      'born_date': _selectedBornDate?.toIso8601String().split('T').first,
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'phone_home': _phoneHomeController.text.trim().isEmpty ? null : _phoneHomeController.text.trim(),
      'phone_mobile': _phoneMobileController.text.trim().isEmpty ? null : _phoneMobileController.text.trim(),
      'is_urgent': _isUrgent,
      'health_conditions': _selectedHealthConditionIds.toList(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'photos': photosPayload,
    };

    AppLoadingOverlay.show(
      context,
      title: !_isUpdate ? 'Registrando adopción...' : 'Actualizando adopción...',
      description: !_isUpdate ? 'Estamos enviando la adopción a la comunidad' : 'Estamos actualizando la adopción en la comunidad',
    );

    ApiResponse response;

    try {
      if(!_isUpdate){
        response = await _adoptionRepository.store(payload);
      }else{
        response = await _adoptionRepository.update(widget.petId!, payload);
      }

      if (!mounted) return;

      ApiSuccessHandler.handle(
        context,
        title: !_isUpdate ? '¡Adopción publicada!' : 'Adopción actualizada!',
        description: response.message
      );

      !_isUpdate ? context.go(MainRoutes.adoptions) : context.go(MainRoutes.account);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingForm 
    ? const PublishPetSkeleton()
    : Scaffold(
        backgroundColor: const Color(0xFFF8FAF9),
        appBar: AppBar(
          title: Text(titleScreen, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // FOTOGRAFIAS
              PetFormStyles.buildSectionHeader('Fotografías', 'Sube hasta 5 fotos claras (mínimo 1)'),
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
              const SizedBox(height: 24),

              // INFORMACIÓN DE LA MASCOTA
              PetFormStyles.buildSectionHeader('Información de la Mascota', 'Datos requeridos de la mascota'),
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
                      label: 'Fecha Aprox. Nacimiento *',
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

              // BOTÓN PARA SELECCIONAR POSICIÓN OPCIONAL EN EL MAPA
              PetFormStyles.buildSectionHeader('Ubicación de Referencia', '¿Dónde se encuentra la mascota actualmente?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: PetFormStyles.inputDecoration('Ciudad *', Icons.location_city_rounded),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la ciudad' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _addressController,
                      decoration: PetFormStyles.inputDecoration('Dirección de Referencia / Sector / Barrio *', Icons.place_rounded),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el sector' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppLocationPickerTile(
                latitude: _latitude,
                longitude: _longitude,
                isRequired: false,
                customHint: 'Punto de referencia para el encuentro',
                onLocationSelected: (LatLng result) {
                  setState(() {
                    _latitude = result.latitude;
                    _longitude = result.longitude;
                  });
                },
              ),
              const SizedBox(height: 24),

              // INFORMACION DE CONTACTO
              AppContactPhoneFields(
                mobileController: _phoneMobileController,
                homeController: _phoneHomeController
              ),
              const SizedBox(height: 24),

              // PRIORIDAD DE ADOPCION
              PetFormStyles.buildSectionHeader('Prioridad de Adopción', 'Identifica el nivel de prioridad'),
              const SizedBox(height: 8),
              AppToggleTile(
                value: _isUrgent,
                onChanged: (val) => setState(() => _isUrgent = val),
                title: 'Caso Urgente',
                subtitle: 'Marca esta opción si la mascota requiere adopción/hogar temporal de forma prioritaria',
                icon: Icons.warning_amber_rounded,
                activeColor: Colors.amber.shade800,
              ),
              const SizedBox(height: 24),

              // ESTADO DE SALUD
              PetFormStyles.buildSectionHeader('Estado de Salud', 'Información clave para los adoptantes'),
              const SizedBox(height: 8),
              HealthStatusCard(
                healthConditions: _healthConditionsList,
                selectedConditionIds: _selectedHealthConditionIds,
                onConditionToggled: _toggleHealthCondition,
              ),
              const SizedBox(height: 24),

              // HISTORIA Y PERSONALIDAD
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

              // SUBMIT
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
                    submitButton,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
  }
}