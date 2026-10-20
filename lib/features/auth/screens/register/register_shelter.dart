import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/widgets/requirements/requirement_item.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/repository/auth/auth_repository.dart';

class RegisterShelterScreen extends StatefulWidget {
  const RegisterShelterScreen({super.key});

  @override
  State<RegisterShelterScreen> createState() => _RegisterShelterScreenState();
}

class _RegisterShelterScreenState extends State<RegisterShelterScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneMobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _webController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasDigit = false;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordRequirements);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRequirements);
    _nameController.dispose();
    _businessNameController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneMobileController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _webController.dispose();
    super.dispose();
  }

  void _validatePasswordRequirements() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasLetter = text.contains(RegExp(r'[A-Za-z]'));
      _hasDigit = text.contains(RegExp(r'[0-9]'));
    });
  }

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms || !_acceptedPrivacy) {
      AppSnackBar.show(
        context,
        title: 'Debes aceptar los términos y leer la política de privacidad',
        type: SnackBarType.warning,
      );

      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'name': _nameController.text.trim(),
      if (_businessNameController.text.trim().isNotEmpty) 'business_name': _businessNameController.text.trim(),
      if (_taxIdController.text.trim().isNotEmpty) 'tax_identification': _taxIdController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      if (_phoneMobileController.text.trim().isNotEmpty) 'phone_mobile': _phoneMobileController.text.trim(),
      if (_cityController.text.trim().isNotEmpty) 'city': _cityController.text.trim(),
      if (_addressController.text.trim().isNotEmpty) 'address': _addressController.text.trim(),
      if (_hoursController.text.trim().isNotEmpty) 'business_hours': _hoursController.text.trim(),
      if (_webController.text.trim().isNotEmpty) 'web_page': _webController.text.trim(),
    };

    try {
      final response = await _authRepository.registerShelter(payload);
      if (!mounted) return;

      ApiSuccessHandler.handle(context, title: response.message);
      context.go(AuthRoutes.login);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget buildBusinessFields({
    required bool useTwoColumns,
    required double fieldSpacing,
  }) {
    final businessNameField = TextFormField(
      controller: _businessNameController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Razón Social',
        prefixIcon: Icon(Icons.badge_outlined),
      ),
    );

    final taxIdField = TextFormField(
      controller: _taxIdController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'RUC / RIF / NIT',
        prefixIcon: Icon(Icons.assignment_ind_outlined),
      ),
    );

    if (!useTwoColumns) {
      return Column(
        children: [
          businessNameField,
          SizedBox(height: fieldSpacing),
          taxIdField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: businessNameField),
        const SizedBox(width: 12),
        Expanded(child: taxIdField),
      ],
    );
  }

  Widget buildContactFields({
    required bool useTwoColumns,
    required double fieldSpacing,
  }) {
    final phoneField = TextFormField(
      controller: _phoneMobileController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Teléfono',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
    );

    final cityField = TextFormField(
      controller: _cityController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Ciudad',
        prefixIcon: Icon(Icons.location_city_outlined),
      ),
    );

    if (!useTwoColumns) {
      return Column(
        children: [
          phoneField,
          SizedBox(height: fieldSpacing),
          cityField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: phoneField),
        const SizedBox(width: 12),
        Expanded(child: cityField),
      ],
    );
  }

  Widget _buildLegalAcceptance({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String prefix,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: _isLoading ? null : onChanged,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              children: [
                Text(prefix),
                InkWell(
                  onTap: onLinkTap,
                  child: Text(
                    linkText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;
    final bool useTwoColumns = screenWidth >= 480;

    final horizontalPadding = isSmallPhone
        ? 16.0
        : isTablet
            ? 32.0
            : 24.0;

    final contentMaxWidth = isTablet ? 600.0 : 480.0;
    final iconSize = isSmallPhone ? 48.0 : 56.0;
    final sectionSpacing = isSmallPhone ? 24.0 : 32.0;
    final fieldSpacing = isSmallPhone ? 12.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isSmallPhone ? 12.0 : 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight -
                          (isSmallPhone ? 24.0 : 32.0))
                      .clamp(0.0, double.infinity),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: iconSize,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Crea tu cuenta de Refugio',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              fontSize: isSmallPhone ? 21 : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'Regístrate como fundación o refugio para publicar y gestionar adopciones',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: sectionSpacing),

                          _buildSectionHeader(
                            context,
                            'Datos Institucionales',
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la Fundación/Refugio *',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                            validator: (v) =>
                                (v != null && v.trim().isNotEmpty)
                                    ? null
                                    : 'Requerido',
                          ),

                          SizedBox(height: fieldSpacing),
                          buildBusinessFields(useTwoColumns: useTwoColumns, fieldSpacing: fieldSpacing),

                          SizedBox(height: sectionSpacing),

                          _buildSectionHeader(context, 'Cuenta de Acceso'),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico institucional *',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'El correo es requerido';
                              }

                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );

                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Ingresa un correo válido';
                              }

                              return null;
                            },
                          ),

                          SizedBox(height: fieldSpacing),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Contraseña *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (!_hasMinLength ||
                                  !_hasLetter ||
                                  !_hasDigit) {
                                return 'La contraseña no cumple con todos los requisitos';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              bottom: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RequirementItem(
                                  isMet: _hasMinLength,
                                  text: 'Mínimo 8 caracteres',
                                ),
                                RequirementItem(
                                  isMet: _hasLetter,
                                  text: 'Al menos una letra',
                                ),
                                RequirementItem(
                                  isMet: _hasDigit,
                                  text: 'Al menos un número',
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: sectionSpacing),

                          _buildSectionHeader(
                            context,
                            'Contacto y Ubicación',
                          ),
                          const SizedBox(height: 12),

                          buildContactFields(useTwoColumns: useTwoColumns, fieldSpacing: fieldSpacing),

                          SizedBox(height: fieldSpacing),

                          TextFormField(
                            controller: _addressController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Dirección física',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                          ),

                          SizedBox(height: sectionSpacing),

                          _buildSectionHeader(
                            context,
                            'Información Adicional',
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _hoursController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Horario de atención',
                              hintText: 'Ej: Lun-Vie 9:00 - 17:00',
                              prefixIcon: Icon(Icons.access_time_outlined),
                            ),
                          ),

                          SizedBox(height: fieldSpacing),

                          TextFormField(
                            controller: _webController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitRegister(),
                            decoration: const InputDecoration(
                              labelText: 'Sitio Web / Red Social',
                              hintText: 'https://...',
                              prefixIcon: Icon(Icons.language_outlined),
                            ),
                          ),

                          SizedBox(height: sectionSpacing),

                          _buildLegalAcceptance(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            prefix: 'He leído y acepto los ',
                            linkText: 'Términos y Condiciones',
                            onLinkTap: () {
                              context.push('/legal/terms');
                            },
                          ),

                          _buildLegalAcceptance(
                            value: _acceptedPrivacy,
                            onChanged: (value) {
                              setState(() {
                                _acceptedPrivacy = value ?? false;
                              });
                            },
                            prefix: 'He leído la ',
                            linkText: 'Política de Privacidad',
                            onLinkTap: () {
                              context.push('/legal/privacy');
                            },
                          ),

                          FilledButton(
                            onPressed:
                                _isLoading ? null : _submitRegister,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallPhone ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Crear Cuenta',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta?',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AuthRoutes.login),
                                child: const Text('Inicia sesión'),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}