import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/models/catalog/country_model.dart';
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

class EditShelterScreen extends StatefulWidget {
  const EditShelterScreen({super.key});

  @override
  State<EditShelterScreen> createState() => _EditShelterScreenState();
}

class _EditShelterScreenState extends State<EditShelterScreen> {
  final AccountRepository _accountRepository = AccountRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _taxIdentificationController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _webPageController = TextEditingController();
  final _businessHoursController = TextEditingController();

  int? _selectedCountryId;
  double? _latitude;
  double? _longitude;
  List<TempFileModel> _avatarImages = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  List<CountryModel> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _taxIdentificationController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _physicalAddressController.dispose();
    _cityController.dispose();
    _webPageController.dispose();
    _businessHoursController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // try {
    //   final shelter = await _accountRepository.getProfile();
    //   final countriesList = await _accountRepository.getCountries();

    //   if (!mounted) return;

    //   setState(() {
    //     _countries = countriesList;

    //     _nameController.text = shelter['name'] ?? '';
    //     _businessNameController.text = shelter['business_name'] ?? '';
    //     _taxIdentificationController.text = shelter['tax_identification'] ?? '';
    //     _emailController.text = shelter['email'] ?? '';
    //     _telephoneController.text = shelter['telephone'] ?? '';
    //     _physicalAddressController.text = shelter['physical_address'] ?? '';
    //     _cityController.text = shelter['city'] ?? '';
    //     _webPageController.text = shelter['web_page'] ?? '';
    //     _businessHoursController.text = shelter['business_hours'] ?? '';

    //     _selectedCountryId = shelter['country_id'];

    //     if (shelter['latitude'] != null) {
    //       _latitude = double.tryParse(shelter['latitude'].toString());
    //     }
    //     if (shelter['longitude'] != null) {
    //       _longitude = double.tryParse(shelter['longitude'].toString());
    //     }

    //     if (shelter['avatar_url'] != null || shelter['avatar'] != null) {
    //       _avatarImages = [
    //         TempFileModel(
    //           uuid: 'existing_avatar',
    //           path: shelter['avatar_url'] ?? shelter['avatar'],
    //           key: shelter['avatar'],
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
      'name': _nameController.text.trim(),
      'business_name': _businessNameController.text.trim().isEmpty ? null : _businessNameController.text.trim(),
      'tax_identification': _taxIdentificationController.text.trim().isEmpty ? null : _taxIdentificationController.text.trim(),
      'email': _emailController.text.trim(),
      'telephone': _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim(),
      'physical_address': _physicalAddressController.text.trim().isEmpty ? null : _physicalAddressController.text.trim(),
      'country_id': _selectedCountryId,
      'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'web_page': _webPageController.text.trim().isEmpty ? null : _webPageController.text.trim(),
      'business_hours': _businessHoursController.text.trim().isEmpty ? null : _businessHoursController.text.trim(),
      'avatar': photosPayload,
    };

    // AppLoadingOverlay.show(
    //   context,
    //   title: 'Actualizando Datos...',
    //   description: 'Estamos actualizando tus datos',
    // );

    // try {
    //   await _accountRepository.updateShelterProfile(payload);
    //   if (!mounted) return;

    //   ApiSuccessHandler.handle(
    //     context,
    //     title: 'Refugio actualizado',
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
          'Editar Perfil del Refugio',
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
                        initialValue: _selectedCountryId,
                        decoration: PetFormStyles.inputDecoration('País', Icons.public),
                        items: _countries.map((item) => DropdownMenuItem<int>(
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
                  controller: _physicalAddressController,
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
                  decoration: PetFormStyles.inputDecoration('Sitio Web', Icons.access_time_rounded),
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