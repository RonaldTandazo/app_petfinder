import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/requirements/requirement_item.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/adoption/styles/pet_form_styles.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final AccountRepository _accountRepository =  AccountRepository();

  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasDigit = false;

  bool _isSubmitting = false;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _newController.addListener(_validatePasswordRequirements);
  }

  @override
  void dispose() {
    _newController.removeListener(_validatePasswordRequirements);
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validatePasswordRequirements() {
    final text = _newController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasLetter = text.contains(RegExp(r'[A-Za-z]'));
      _hasDigit = text.contains(RegExp(r'[0-9]'));
    });
  }

  String? _requiredValidator(String? value, String message) {
    if ((value?.trim() ?? '').isEmpty) return message;
    return null;
  }

  String? _newPasswordValidator(String? value) {
    final clean = value ?? '';
    if (clean.isEmpty) return 'Ingresa la nueva contraseña';
    if (!_hasMinLength || !_hasLetter || !_hasDigit) {
      return 'La contraseña no cumple con todos los requisitos';
    }
    return null;
  }

  String? _confirmValidator(String? value) {
    final clean = value ?? '';
    if (clean.isEmpty) return 'Repite la nueva contraseña';
    if (clean != _newController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required String field,
    required bool obscureText,
    required VoidCallback onToggleObscure,
  }) {
    InputDecoration baseDecoration = PetFormStyles.inputDecoration(label, icon).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey.shade600,
        ),
        onPressed: onToggleObscure,
      ),
    );

    final errors = _fieldErrors[field];
    if (errors is List && errors.isNotEmpty) {
      return baseDecoration.copyWith(errorText: errors.first.toString());
    }

    return baseDecoration;
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() => _fieldErrors.remove(field));
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _fieldErrors = {};
    });

    final payload = {
      'current_password': _currentController.text,
      'new_password': _newController.text,
      'new_password_confirmation': _confirmController.text,
    };

    try {
      await _accountRepository.updatePassword(payload);
      if (!mounted) return;

      _currentController.clear();
      _newController.clear();
      _confirmController.clear();

      ApiSuccessHandler.handle(
        context,
        title: 'Contraseña actualizada',
        description: 'Tu contraseña se cambió correctamente.',
      );
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            PetFormStyles.buildSectionHeader(
              'Seguridad',
              'Usa una contraseña que no uses en otros sitios',
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _currentController,
              obscureText: _obscureCurrent,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFieldError('current_password'),
              decoration: _inputDecoration(
                label: 'Contraseña actual',
                icon: Icons.lock_outline_rounded,
                field: 'current_password',
                obscureText: _obscureCurrent,
                onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
              validator: (value) => _requiredValidator(value, 'Ingresa tu contraseña actual'),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _newController,
              obscureText: _obscureNew,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFieldError('new_password'),
              decoration: _inputDecoration(
                label: 'Nueva contraseña',
                icon: Icons.lock_reset_rounded,
                field: 'new_password',
                obscureText: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: _newPasswordValidator,
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Column(
                children: [
                  RequirementItem(isMet: _hasMinLength, text: 'Mínimo 8 caracteres'),
                  RequirementItem(isMet: _hasLetter, text: 'Al menos una letra'),
                  RequirementItem(isMet: _hasDigit, text: 'Al menos un número'),
                ],
              ),
            ),

            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => _clearFieldError('new_password_confirmation'),
              decoration: _inputDecoration(
                label: 'Repite la nueva contraseña',
                icon: Icons.lock_rounded,
                field: 'new_password_confirmation',
                obscureText: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: _confirmValidator,
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
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
                        'Actualizar contraseña',
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