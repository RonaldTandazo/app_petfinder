import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/widgets/contact/app_contact_phone_fields.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/models/catalog/country_model.dart';
import 'package:app_petfinder/models/catalog/gender_model.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';
import 'package:app_petfinder/models/storage/temp_file_model.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';
import 'package:app_petfinder/widgets/images/app_image_picker_grid.dart';
import 'package:app_petfinder/core/utils/account_storage_service.dart';
import 'package:app_petfinder/core/utils/session_storage_service.dart';
import 'package:app_petfinder/repository/catalog/catalog_repository.dart';
import 'package:app_petfinder/widgets/loaders/app_loading_overlay.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final CatalogRepository _catalogRepository = CatalogRepository();
  final AccountRepository _accountRepository = AccountRepository();
  final String? _initEmail = SessionStorageService.email;
  final _formKey = GlobalKey<FormState>();

  final _firstNamesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneMobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedGenderId;
  int? _selectedCountryId;
  List<TempFileModel> _avatarImages = [];

  bool _isLoadingData = true;
  bool _isLoadingCatalog = true;

  List<CountryModel> _countriesList = [];
  List<GenderModel> _gendersList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadFormCatalogs();
  }

  @override
  void dispose() {
    _firstNamesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _phoneMobileController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final response = await _accountRepository.getProfileInfo();

      if (!mounted) return;

      final data = response.data;

      if(data != null){
        setState(() {
          _firstNamesController.text = data['first_names'] ?? '';
          _lastNamesController.text = data['last_names'] ?? '';
          _emailController.text = _initEmail ?? '';
          _phoneMobileController.text = data['phone_mobile'] ?? '';
          _cityController.text = data['city'] ?? '';
          _addressController.text = data['address'] ?? '';
          _selectedGenderId = data['gender_id'];
          _selectedCountryId = data['country_id'];
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

          if (data['genders'] is List) {
            _gendersList = (data['genders'] as List)
                .map((e) => GenderModel.fromJson(e as Map<String, dynamic>))
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
      final item = entry.value;

      return {
        'path_temp': item.key,
        'is_main': true,
      };
    }).toList();

    final Map<String, dynamic> payload = {
      'first_names': _firstNamesController.text.trim(),
      'last_names': _lastNamesController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_mobile': _phoneMobileController.text.trim().isEmpty ? null : _phoneMobileController.text.trim(),
      'gender_id': _selectedGenderId,
      'country_id': _selectedCountryId,
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'avatar': photosPayload,
    };

    Map<String, dynamic> sessionFields = {
      'name': '${_firstNamesController.text.trim()} ${_lastNamesController.text.trim()}',
      'email': payload['email'],
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
        title: 'Perfil actualizado',
        description: 'Tus datos se actualizaron correctamente.',
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
          'Editar Perfil',
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
                  PetFormStyles.buildSectionHeader('Avatar', 'Sube o actualiza tu foto de perfil'),
                  const SizedBox(height: 12),
                  AppImagePickerGrid(
                    images: _avatarImages,
                    maxImages: 1,
                    onImagesChanged: (updated) {
                      setState(() => _avatarImages = updated);
                    },
                  ),
                  const SizedBox(height: 24),

                  PetFormStyles.buildSectionHeader('Datos Personales', 'Información de la cuenta de usuario'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNamesController,
                          decoration: PetFormStyles.inputDecoration('Nombres *', Icons.person),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tus nombres' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNamesController,
                          decoration: PetFormStyles.inputDecoration('Apellidos *', Icons.person),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tus apellidos' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: PetFormStyles.inputDecoration('Correo Electronico *', Icons.email),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un email' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:  AppContactPhoneFields(
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
                          initialValue: _selectedGenderId,
                          decoration: PetFormStyles.inputDecoration('Género', Icons.wc_rounded),
                          items: _gendersList.map((item) => DropdownMenuItem<int>(
                            value: item.id,
                            child: Text(item.name),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedGenderId = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:  DropdownButtonFormField<int>(
                          initialValue: _selectedCountryId,
                          decoration: PetFormStyles.inputDecoration('País', Icons.public),
                          items: _countriesList.map((item) => DropdownMenuItem<int>(
                            value: item.id,
                            child: Text(item.name),
                          )).toList(),
                          onChanged: (val) => setState(() => _selectedCountryId = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: PetFormStyles.inputDecoration('Ciudad', Icons.location_city_outlined)
                        )
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:  TextFormField(
                          controller: _addressController,
                          decoration: PetFormStyles.inputDecoration('Dirección', Icons.home_outlined)
                        )
                      ),
                    ],
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
      );
  }
}