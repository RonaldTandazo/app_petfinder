import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/models/catalog/size_model.dart';
import 'package:app_petfinder/models/catalog/animal_gender_model.dart';
import 'package:app_petfinder/models/catalog/species_model.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
// import 'package:app_petfinder/repository/pet/lost_pet_repository.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/widgets/app_loading_overlay.dart';
import 'package:app_petfinder/widgets/app_datepicker.dart';
import 'package:app_petfinder/widgets/app_snackbar.dart';
import 'package:app_petfinder/widgets/app_image_picker_grid.dart';
import 'package:app_petfinder/widgets/app_toggle_tile.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';

class PublishLostPetScreen extends StatefulWidget {
  const PublishLostPetScreen({super.key});

  @override
  State<PublishLostPetScreen> createState() => _PublishLostPetScreenState();
}

class _PublishLostPetScreenState extends State<PublishLostPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalogRepository = CatalogRepository();
  // final _lostPetRepository = LostPetRepository();

  List<TempFileModel> _selectedImages = [];
  int _mainImageIndex = 0;

  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _colorController = TextEditingController();
  final _cityController = TextEditingController();
  final _eventAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardAmountController = TextEditingController();

  bool _isLoadingCatalog = true;
  int? _selectedSpeciesId;
  int? _selectedGenderId;
  int? _selectedSizeId;
  DateTime? _selectedEventDate;

  bool _hasReward = false;

  List<SpeciesModel> _speciesList = [];
  List<AnimalGenderModel> _gendersList = [];
  List<SizeModel> _sizesList = [];

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
    _cityController.dispose();
    _eventAddressController.dispose();
    _descriptionController.dispose();
    _rewardAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadFormCatalogs() async {
    try {
      final response = await _catalogRepository.getCatalogs();
      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null) {
          print(data);

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

    final hasUploading = _selectedImages.any((img) => img.isUploading);
    if (hasUploading) {
      AppSnackBar.show(
        context,
        title: 'Imágenes subiendo',
        description: 'Por favor espera a que terminen de subirse las fotografías.',
        type: SnackBarType.warning,
      );
      return;
    }

    final hasErrors = _selectedImages.any((img) => img.hasError || img.key == null);
    if (hasErrors) {
      AppSnackBar.show(
        context,
        title: 'Error en fotos',
        description: 'Una o más imágenes fallaron al subirse. Elimínalas o vuelve a intentarlo.',
        type: SnackBarType.error,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final photosPayload = _selectedImages.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return {
        'path_temp': item.key,
        'is_main': idx == _mainImageIndex,
      };
    }).toList();

    final Map<String, dynamic> payload = {
      'species_id': _selectedSpeciesId,
      'animal_gender_id': _selectedGenderId,
      'size_id': _selectedSizeId,
      'name': _nameController.text.trim(),
      'race': _raceController.text.trim().isEmpty ? null : _raceController.text.trim(),
      'color': _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'has_reward': _hasReward,
      'reward_amount': _hasReward && _rewardAmountController.text.trim().isNotEmpty
        ? double.tryParse(_rewardAmountController.text.trim())
        : null,
      'city': _cityController.text.trim(),
      'event_address': _eventAddressController.text.trim().isEmpty ? null : _eventAddressController.text.trim(),
      'event_date': _selectedEventDate?.toIso8601String(),
      'photos': photosPayload,
    };

    AppLoadingOverlay.show(
      context,
      title: 'Registrando reporte...',
      description: 'Estamos enviando la alerta a la comunidad.',
    );

    try {
      // final response = await _lostPetRepository.store(payload);
      // if (!mounted) return;

      // ApiSuccessHandler.handle(context, title: '¡Reporte publicado!', description: response.message);

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
        title: const Text('Reportar Mascota Perdida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingCatalog
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Selección de Fotografías
                  PetFormStyles.buildSectionHeader('Fotografías', 'Sube imágenes recientes y claras de la mascota'),
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

                  // Información de la Mascota
                  PetFormStyles.buildSectionHeader('Información de la Mascota', 'Datos de identificación'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: PetFormStyles.inputDecoration('Nombre de la mascota *', Icons.pets_rounded),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
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
                        child: TextFormField(
                          controller: _raceController,
                          decoration: PetFormStyles.inputDecoration('Raza / Mezcla', Icons.merge_type_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: PetFormStyles.inputDecoration('Color principal', Icons.palette_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Datos del Evento / Extravío
                  PetFormStyles.buildSectionHeader('Ubicación y Fecha', '¿Dónde y cuándo sucedió?'),
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
                        child: AppDatePicker(
                          label: 'Fecha del evento *',
                          icon: Icons.event_rounded,
                          selectionType: DateSelectionType.single,
                          filterType: DateFilterType.disableFuture,
                          selectedDate: _selectedEventDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedEventDate = date;
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

                  TextFormField(
                    controller: _eventAddressController,
                    decoration: PetFormStyles.inputDecoration(
                      'Dirección de referencia / Sector',
                      Icons.place_rounded,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recompensa
                  PetFormStyles.buildSectionHeader('Recompensa', 'Incentivo opcional por devolución o datos'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        AppToggleTile(
                          value: _hasReward,
                          onChanged: (val) {
                            setState(() {
                              _hasReward = val;
                              if (!val) _rewardAmountController.clear();
                            });
                          },
                          title: '¿Ofreces recompensa?',
                          subtitle: 'Actívalo para motivar búsquedas comunitarias en la zona',
                          icon: Icons.monetization_on_rounded,
                          activeColor: Colors.teal.shade700,
                        ),
                        
                        if (_hasReward) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _rewardAmountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: PetFormStyles.inputDecoration(
                              'Monto de Recompensa (\$) *',
                              Icons.attach_money_rounded,
                            ),
                            validator: (val) {
                              if (_hasReward) {
                                final cleanVal = val?.trim();

                                if (cleanVal == null || cleanVal.isEmpty) {
                                  return 'Ingresa un valor';
                                }

                                final amount = double.tryParse(cleanVal);

                                if (amount == null) {
                                  return 'Monto inválido';
                                }

                                if (amount <= 0) {
                                  return 'El monto debe ser mayor a 0';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Descripción y detalles
                  PetFormStyles.buildSectionHeader('Detalles Adicionales', 'Señas particulares y lo que sea de ayuda'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: PetFormStyles.inputDecoration(
                      'Describe collar, manchas, cicatrices, temperamento o si necesita medicación urgente...',
                      Icons.description_rounded,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Submit
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade400,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Publicar Alerta de Pérdida',
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