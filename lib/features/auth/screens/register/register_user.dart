import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/repository/auth/auth_repository.dart';
import 'package:app_petfinder/widgets/requirements/requirement_item.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  final _firstNamesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasDigit = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordRequirements);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePasswordRequirements);
    _firstNamesController.dispose();
    _lastNamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
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

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'first_names': _firstNamesController.text.trim(),
      'last_names': _lastNamesController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      if (_phoneController.text.trim().isNotEmpty) 'telephone': _phoneController.text.trim(),
      if (_cityController.text.trim().isNotEmpty) 'city': _cityController.text.trim(),
      if (_addressController.text.trim().isNotEmpty) 'address': _addressController.text.trim(),
    };

    try {
      final response = await _authRepository.registerUser(payload);
      if (!mounted) return;

      ApiSuccessHandler.handle(context, title: response.message);
      context.go(AuthRoutes.login);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crea tu cuenta de Tutor',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Regístrate para comenzar a gestionar y adoptar mascotas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, 'Datos Personales'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNamesController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nombres *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v != null && v.trim().isNotEmpty) ? null : 'Requerido',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNamesController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Apellidos *',
                          ),
                          validator: (v) => (v != null && v.trim().isNotEmpty) ? null : 'Requerido',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader(context, 'Cuenta de Acceso'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico *',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'El correo es requerido';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v.trim())) return 'Ingresa un correo válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (!_hasMinLength || !_hasLetter || !_hasDigit) {
                        return 'La contraseña no cumple con todos los requisitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Lista dinámica de requisitos de contraseña
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
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

                  const SizedBox(height: 16),

                  _buildSectionHeader(context, 'Contacto y Ubicación'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Ciudad',
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _addressController,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitRegister(),
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: Icon(Icons.home_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _isLoading ? null : _submitRegister,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () => context.go(AuthRoutes.login),
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