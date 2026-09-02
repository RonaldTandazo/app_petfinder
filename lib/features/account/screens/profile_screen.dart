import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/account/account_routes.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';
import 'package:app_petfinder/models/account/account_profile.dart';
import 'package:app_petfinder/models/catalog/country_summary_model.dart';
import 'package:app_petfinder/models/catalog/gender_summary_model.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final AccountRepository? repository;

  const ProfileScreen({super.key, this.repository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AccountRepository _repository = widget.repository ?? AccountRepository();

  final _formKey = GlobalKey<FormState>();

  final _firstNamesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _webPageController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _addressController = TextEditingController();

  List<CountrySummaryModel> _countries = [];
  List<GenderSummaryModel> _genders = [];
  AccountProfile? _profile;
  int? _countryId;
  int? _genderId;

  bool _isLoading = true;
  bool _isSubmitting = false;
  Map<String, dynamic> _fieldErrors = {};

  List<TextEditingController> get _textControllers => [
    _firstNamesController,
    _lastNamesController,
    _nameController,
    _businessNameController,
    _taxIdController,
    _telephoneController,
    _physicalAddressController,
    _cityController,
    _latitudeController,
    _longitudeController,
    _webPageController,
    _businessHoursController,
    _addressController,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _textControllers) {
      controller.addListener(_onFormChanged);
    }
    _loadFormCatalog();
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFormCatalog() async {
    try {
      final response = await _repository.getFormCatalog();
      if (!mounted) return;

      final data = response.data;
      if (data == null) return;

      final me = data['me'];
      if (me is! Map<String, dynamic>) return;

      final profile = AccountProfile.fromJson(me);

      setState(() {
        _profile = profile;
        _countries = (data['countries'] as List? ?? [])
            .map((e) => CountrySummaryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _genders = (data['genders'] as List? ?? [])
            .map((e) => GenderSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _seedFields(profile);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _seedFields(AccountProfile profile) {
    switch (profile) {
      case UserProfileModel user:
        _firstNamesController.text = user.firstNames;
        _lastNamesController.text = user.lastNames;
        _telephoneController.text = user.telephone;
        _cityController.text = user.city;
        _addressController.text = user.address;
        _countryId = user.country?.id;
        _genderId = user.gender?.id;
      case ShelterProfileModel shelter:
        _nameController.text = shelter.name;
        _businessNameController.text = shelter.businessName;
        _taxIdController.text = shelter.taxIdentification;
        _telephoneController.text = shelter.telephone;
        _physicalAddressController.text = shelter.physicalAddress;
        _cityController.text = shelter.city;
        _latitudeController.text = shelter.latitude ?? '';
        _longitudeController.text = shelter.longitude ?? '';
        _webPageController.text = shelter.webPage;
        _businessHoursController.text = shelter.businessHours;
        _countryId = shelter.country?.id;
    }
  }

  String? _normalizedText(String value) {
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  void _putIfChanged(Map<String, dynamic> payload, String field, String value, String original) {
    final newValue = _normalizedText(value);
    final oldValue = _normalizedText(original);
    if (newValue != oldValue) payload[field] = newValue;
  }

  Map<String, dynamic> _buildPayload() {
    final profile = _profile;
    if (profile == null) return {};

    final Map<String, dynamic> payload = {};

    switch (profile) {
      case UserProfileModel user:
        _putIfChanged(payload, 'first_names', _firstNamesController.text, user.firstNames);
        _putIfChanged(payload, 'last_names', _lastNamesController.text, user.lastNames);
        _putIfChanged(payload, 'telephone', _telephoneController.text, user.telephone);
        _putIfChanged(payload, 'city', _cityController.text, user.city);
        _putIfChanged(payload, 'address', _addressController.text, user.address);
        if (_countryId != user.country?.id) payload['country_id'] = _countryId;
        if (_genderId != user.gender?.id) payload['gender_id'] = _genderId;
      case ShelterProfileModel shelter:
        _putIfChanged(payload, 'name', _nameController.text, shelter.name);
        _putIfChanged(payload, 'business_name', _businessNameController.text, shelter.businessName);
        _putIfChanged(payload, 'tax_identification', _taxIdController.text, shelter.taxIdentification);
        _putIfChanged(payload, 'telephone', _telephoneController.text, shelter.telephone);
        _putIfChanged(payload, 'physical_address', _physicalAddressController.text, shelter.physicalAddress);
        _putIfChanged(payload, 'city', _cityController.text, shelter.city);
        _putIfChanged(payload, 'web_page', _webPageController.text, shelter.webPage);
        _putIfChanged(payload, 'business_hours', _businessHoursController.text, shelter.businessHours);
        final lat = double.tryParse(_latitudeController.text.trim());
        final oldLat = double.tryParse(shelter.latitude ?? '');
        if (lat != oldLat) payload['latitude'] = lat;
        final lng = double.tryParse(_longitudeController.text.trim());
        final oldLng = double.tryParse(shelter.longitude ?? '');
        if (lng != oldLng) payload['longitude'] = lng;
        if (_countryId != shelter.country?.id) payload['country_id'] = _countryId;
    }

    return payload;
  }

  bool get _hasChanges => _buildPayload().isNotEmpty;

  Future<void> _save() async {
    if (_isSubmitting) return;

    final payload = _buildPayload();
    if (payload.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _fieldErrors = {};
    });

    try {
      final response = await _repository.updateProfile(payload);
      if (!mounted) return;

      final data = response.data;
      if (data != null) {
        setState(() {
          _profile = AccountProfile.fromJson(data);
        });
      }

      ApiSuccessHandler.handle(
        context,
        title: 'Perfil guardado',
        description: 'Tus cambios se aplicaron correctamente.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 422 && e.error is Map<String, dynamic>) {
        setState(() => _fieldErrors = e.error as Map<String, dynamic>);
      }
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String get _initials {
    final profile = _profile;
    if (profile == null) return '?';

    final words = switch (profile) {
      UserProfileModel(:final fullName) => fullName.split(' '),
      ShelterProfileModel(:final name) => name.split(' '),
    }.where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) return '?';

    final buffer = StringBuffer();
    for (final word in words.take(2)) {
      buffer.write(word[0].toUpperCase());
    }
    return buffer.toString();
  }

  String _displayName(AccountProfile profile) {
    return switch (profile) {
      UserProfileModel(:final fullName) => fullName.isEmpty ? profile.email : fullName,
      ShelterProfileModel(:final name) => name.isEmpty ? profile.email : name,
    };
  }

  Widget _buildHeader(AccountProfile profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.teal.shade100,
          child: Text(
            _initials,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName(profile),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _decorationWithErrors(String label, IconData icon, String field) {
    final errors = _fieldErrors[field];
    if (errors is List && errors.isNotEmpty) {
      return PetFormStyles.inputDecoration(label, icon).copyWith(errorText: errors.first.toString());
    }

    return PetFormStyles.inputDecoration(label, icon);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String fieldKey,
    TextInputType? keyboardType,
    bool isUrl = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => _clearFieldError(fieldKey),
      decoration: _decorationWithErrors(label, icon, fieldKey),
      validator: isUrl
          ? (value) {
              final clean = value?.trim() ?? '';
              if (clean.isEmpty) return null;
              final uri = Uri.tryParse(clean);
              if (uri == null || !uri.hasScheme) return 'Ingresa una URL válida';
              return null;
            }
          : null,
    );
  }

  Widget _buildCountrySelector() {
    return DropdownButtonFormField<int>(
      initialValue: _countryId,
      decoration: _decorationWithErrors('País', Icons.public_rounded, 'country_id'),
      hint: const Text('Selecciona tu país'),
      items: [
        for (final country in _countries)
          DropdownMenuItem<int>(value: country.id, child: Text(country.name)),
      ],
      onChanged: (val) {
        setState(() {
          _countryId = val;
          _fieldErrors.remove('country_id');
        });
      },
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<int>(
      initialValue: _genderId,
      decoration: _decorationWithErrors('Género', Icons.wc_rounded, 'gender_id'),
      hint: const Text('Selecciona tu género'),
      items: [
        for (final gender in _genders)
          DropdownMenuItem<int>(value: gender.id, child: Text(gender.name)),
      ],
      onChanged: (val) {
        setState(() {
          _genderId = val;
          _fieldErrors.remove('gender_id');
        });
      },
    );
  }

  List<Widget> _buildUserFields() {
    return [
      PetFormStyles.buildSectionHeader('Datos personales', 'Tu información de contacto'),
      const SizedBox(height: 12),
      _buildTextField(label: 'Nombres', icon: Icons.person_rounded, controller: _firstNamesController, fieldKey: 'first_names'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Apellidos', icon: Icons.person_outline_rounded, controller: _lastNamesController, fieldKey: 'last_names'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Teléfono', icon: Icons.phone_rounded, controller: _telephoneController, fieldKey: 'telephone', keyboardType: TextInputType.phone),
      const SizedBox(height: 14),
      _buildCountrySelector(),
      const SizedBox(height: 14),
      _buildGenderSelector(),
      const SizedBox(height: 14),
      _buildTextField(label: 'Ciudad', icon: Icons.location_city_rounded, controller: _cityController, fieldKey: 'city'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Dirección', icon: Icons.home_rounded, controller: _addressController, fieldKey: 'address'),
    ];
  }

  List<Widget> _buildShelterFields() {
    return [
      PetFormStyles.buildSectionHeader('Información del refugio', 'Datos que ven los adoptantes'),
      const SizedBox(height: 12),
      _buildTextField(label: 'Nombre', icon: Icons.store_rounded, controller: _nameController, fieldKey: 'name'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Razón social', icon: Icons.business_rounded, controller: _businessNameController, fieldKey: 'business_name'),
      const SizedBox(height: 14),
      _buildTextField(label: 'RUC', icon: Icons.badge_rounded, controller: _taxIdController, fieldKey: 'tax_identification'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Teléfono', icon: Icons.phone_rounded, controller: _telephoneController, fieldKey: 'telephone', keyboardType: TextInputType.phone),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTextField(
              label: 'Latitud',
              icon: Icons.explore_rounded,
              controller: _latitudeController,
              fieldKey: 'latitude',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              label: 'Longitud',
              icon: Icons.explore_rounded,
              controller: _longitudeController,
              fieldKey: 'longitude',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _buildCountrySelector(),
      const SizedBox(height: 14),
      _buildTextField(label: 'Ciudad', icon: Icons.location_city_rounded, controller: _cityController, fieldKey: 'city'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Dirección física', icon: Icons.home_rounded, controller: _physicalAddressController, fieldKey: 'physical_address'),
      const SizedBox(height: 14),
      _buildTextField(label: 'Página web', icon: Icons.language_rounded, controller: _webPageController, fieldKey: 'web_page', keyboardType: TextInputType.url, isUrl: true),
      const SizedBox(height: 14),
      _buildTextField(label: 'Horario de atención', icon: Icons.schedule_rounded, controller: _businessHoursController, fieldKey: 'business_hours'),
    ];
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
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _profile == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No se pudo cargar tu perfil'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _loadFormCatalog();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    final profile = _profile!;

    final fields = switch (profile) {
      UserProfileModel() => _buildUserFields(),
      ShelterProfileModel() => _buildShelterFields(),
    };

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildHeader(profile),
          const SizedBox(height: 24),
          ...fields,
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _hasChanges && !_isSubmitting ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                disabledBackgroundColor: Colors.teal.shade100,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.push(AccountRoutes.changePassword),
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Cambiar contraseña'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}