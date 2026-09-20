import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/models/catalog/country_model.dart';
import 'package:app_petfinder/models/pictures/picture_model.dart';
import 'package:app_petfinder/widgets/contact/app_contact_phone_fields.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';
import 'package:app_petfinder/widgets/locations/app_location_picket_tile.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/core/utils/account_storage_service.dart';
import 'package:app_petfinder/core/utils/session_storage_service.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';

class EditShelterScreen extends StatefulWidget {
  const EditShelterScreen({super.key});

  @override
  State<EditShelterScreen> createState() => _EditShelterScreenState();
}

class _EditShelterScreenState extends State<EditShelterScreen> {
  final _formKey = GlobalKey<FormState>();
  final CatalogRepository _catalogRepository = CatalogRepository();
  final AccountRepository _accountRepository = AccountRepository();
  final String? _initName = SessionStorageService.name;
  final String? _initEmail = SessionStorageService.email;
  final PictureModel? _initAvatar = SessionStorageService.avatar != null ? PictureModel.fromJson(SessionStorageService.avatar!) : null;

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _taxIdentificationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _webPageController = TextEditingController();
  final _businessHoursController = TextEditingController();

  int? _selectedCountryId;
  double? _latitude;
  double? _longitude;
  List<TempFileModel> _avatarImages = [];

  bool _isLoadingData = true;
  bool _isLoadingCatalog = true;

  List<CountryModel> _countriesList = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadFormCatalogs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _taxIdentificationController.dispose();
    _emailController.dispose();
    _phoneMobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _webPageController.dispose();
    _businessHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final response = await _accountRepository.getProfileInfo();

      if (!mounted) return;

      final data = response.data;

      if(data != null){
        final List<TempFileModel> images = _initAvatar != null ? [
          TempFileModel(
            id: _initAvatar.id,
            uuid: 'existing_${_initAvatar.id}',
            file: null,
            path: _initAvatar.url,
            isExisting: true,
            isUploading: false,
          )
        ].toList() : [];

        setState(() {
          _avatarImages = images;
          _nameController.text = _initName ?? '';
          _businessNameController.text = data['business_name'] ?? '';
          _taxIdentificationController.text = data['tax_identification'] ?? '';
          _emailController.text = _initEmail ?? '';
          _phoneMobileController.text = data['phone_mobile'] ?? '';
          _addressController.text = data['address'] ?? '';
          _cityController.text = data['city'] ?? '';
          _webPageController.text = data['web_page'] ?? '';
          _businessHoursController.text = data['business_hours'] ?? '';
          _selectedCountryId = data['country_id'];

          if (data['latitude'] != null) {
            _latitude = (data['latitude'] as num?)?.toDouble();
          }
          if (data['longitude'] != null) {
            _longitude = (data['_longitude'] as num?)?.toDouble();
          }
        });
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadFormCatalogs() async {
    try {
      final response = await _catalogRepository.getAccountCatalogs();
      if (!mounted) return;

      final data = response.data;

      setState(() {
        if (data != null) {
          if (data['countries'] is List) {
            _countriesList = (data['countries'] as List)
                .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
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

  Future<void> _submit() async {
    final bool hasUploading = _avatarImages.any((img) => img.isUploading);
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

    final List<Map<String, dynamic>> photosPayload = _avatarImages.asMap().entries.map((entry) {
      final int index = entry.key;
      final TempFileModel image = entry.value;

      return image.toFinalPayload(
        isMain: true,
        sortOrder: index,
      );
    }).toList();

    Map<String, dynamic> sessionFields = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    final Map<String, dynamic> payload = {
      ...sessionFields,
      'business_name': _businessNameController.text.trim().isEmpty ? null : _businessNameController.text.trim(),
      'tax_identification': _taxIdentificationController.text.trim().isEmpty ? null : _taxIdentificationController.text.trim(),
      'phone_mobile': _phoneMobileController.text.trim().isEmpty ? null : _phoneMobileController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'country_id': _selectedCountryId,
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'web_page': _webPageController.text.trim().isEmpty ? null : _webPageController.text.trim(),
      'business_hours': _businessHoursController.text.trim().isEmpty ? null : _businessHoursController.text.trim(),
      'avatar': photosPayload,
    };

    AppLoadingOverlay.show(
      context,
      title: 'Actualizando Datos...',
      description: 'Estamos actualizando tus datos',
    );

    try {
      final response = await _accountRepository.updateProfile(payload);
      if (!mounted) return;

      final data = response.data;

      if(data != null){
        sessionFields['avatar'] = data['avatar'];
      }

      ApiSuccessHandler.handle(
        context,
        title: 'Refugio actualizado',
        description: 'Tus datos se actualizaron correctamente',
      );

      AccountStorageService.saveAccount(payload);
      SessionStorageService.updateSession(sessionFields);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) AppLoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          'Editar Perfil del Refugio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingData || _isLoadingCatalog
        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                PetFormStyles.buildSectionHeader('Logo / Foto de Perfil', 'Sube la imagen representativa del refugio'),
                const SizedBox(height: 12),
                AppImagePickerGrid(
                  images: _avatarImages,
                  maxImages: 1,
                  onImagesChanged: (updated) {
                    setState(() => _avatarImages = updated);
                  },
                ),
                const SizedBox(height: 24),

                PetFormStyles.buildSectionHeader('Información del Refugio', 'Datos comerciales y de contacto'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: PetFormStyles.inputDecoration('Nombre *', Icons.store_rounded),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _businessNameController,
                  decoration: PetFormStyles.inputDecoration('Razón Social', Icons.business_rounded),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _taxIdentificationController,
                  decoration: PetFormStyles.inputDecoration('RUC / Identificación fiscal', Icons.badge_outlined),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: PetFormStyles.inputDecoration('Correo electrónico *', Icons.email),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un correo' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppContactPhoneFields(
                        mobileController: _phoneMobileController,
                        isPhoneHomeRequired: false,
                        showHeader: false,
                        showPhoneHome: false,
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedCountryId,
                        decoration: PetFormStyles.inputDecoration('País', Icons.public),
                        items: _countriesList.map((item) => DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(item.name),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedCountryId = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: PetFormStyles.inputDecoration('Ciudad', Icons.location_city_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                TextFormField(
                  controller: _addressController,
                  decoration: PetFormStyles.inputDecoration('Dirección Física', Icons.home_work_outlined),
                ),
                const SizedBox(height: 14),
                
                PetFormStyles.buildSectionHeader('Ubicación', 'Selecciona las coordenadas en el mapa'),
                const SizedBox(height: 12),
                AppLocationPickerTile(
                  latitude: _latitude,
                  longitude: _longitude,
                  isRequired: false,
                  customHint: 'Ubicación física del refugio',
                  onLocationSelected: (LatLng result) {
                    setState(() {
                      _latitude = result.latitude;
                      _longitude = result.longitude;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                PetFormStyles.buildSectionHeader('Información Adicional', 'Página web y horarios de atención'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _webPageController,
                  keyboardType: TextInputType.url,
                  decoration: PetFormStyles.inputDecoration('Sitio Web', Icons.language_rounded),

                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _businessHoursController,
                  decoration: PetFormStyles.inputDecoration('Horarios de Atención', Icons.access_time_rounded),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Guardar Cambios',
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