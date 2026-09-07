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

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final AccountRepository _accountRepository = AccountRepository();
  final _formKey = GlobalKey<FormState>();

  final _firstNamesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedGenderId;
  int? _selectedCountryId;
  List<TempFileModel> _avatarImages = [];

  bool _isLoading = false;

  List<CountryModel> _countries = [];
  List<GenderModel> _genders = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _firstNamesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // try {
    //   final user = await _accountRepository.getProfile();
    //   final countriesList = await _accountRepository.getCountries();
    //   final gendersList = await _accountRepository.getGenders();

    //   if (!mounted) return;

    //   setState(() {
    //     _countries = countriesList;
    //     _genders = gendersList;

    //     _firstNamesController.text = user['first_names'] ?? '';
    //     _lastNamesController.text = user['last_names'] ?? '';
    //     _emailController.text = user['email'] ?? '';
    //     _telephoneController.text = user['telephone'] ?? '';
    //     _cityController.text = user['city'] ?? '';
    //     _addressController.text = user['address'] ?? '';

    //     _selectedGenderId = user['gender_id'];
    //     _selectedCountryId = user['country_id'];

    //     if (user['avatar_url'] != null || user['avatar'] != null) {
    //       _avatarImages = [
    //         TempFileModel(
    //           uuid: 'existing_avatar',
    //           path: user['avatar_url'] ?? user['avatar'],
    //           key: user['avatar'],
    //           isUploading: false,
    //         ),
    //       ];
    //     }
    //     _isLoading = false;
    //   });
    // } catch (_) {
    //   if (mounted) setState(() => _isLoading = false);
    // }
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
        'is_main': false,
      };
    }).toList();

    final Map<String, dynamic> payload = {
      'first_names': _firstNamesController.text.trim(),
      'last_names': _lastNamesController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'telephone': _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim(),
      'gender_id': _selectedGenderId,
      'country_id': _selectedCountryId,
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'avatar': photosPayload,
    };

    // AppLoadingOverlay.show(
    //   context,
    //   title: 'Actualizando Datos...',
    //   description: 'Estamos actualizando tus datos',
    // );

    // try {
    //   await _accountRepository.updateUserProfile(payload);
    //   if (!mounted) return;

    //   ApiSuccessHandler.handle(
    //     context,
    //     title: 'Perfil actualizado',
    //     description: 'Tus datos se actualizaron correctamente.',
    //   );
    // } on ApiException catch (e) {
    //   if (e.errors != null) {
    //     setState(() => _fieldErrors = e.errors!);
    //   }
    //   ApiErrorHandler.handle(context, e);
    // } finally {
    //   if (mounted) AppLoadingOverlay.hide();
    // }
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
      body: _isLoading
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
                          mobileController: _telephoneController,
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
                          items: _genders.map((item) => DropdownMenuItem<int>(
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
                          items: _countries.map((item) => DropdownMenuItem<int>(
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