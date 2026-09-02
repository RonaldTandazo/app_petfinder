import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/features/pet/styles/pet_form_styles.dart';
import 'package:app_petfinder/repository/account/account_repository.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final AccountRepository? repository;

  const ChangePasswordScreen({super.key, this.repository});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final AccountRepository _repository = widget.repository ?? AccountRepository();

  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSubmitting = false;
  Map<String, dynamic> _fieldErrors = {};

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    final clean = value?.trim() ?? '';
    if (clean.isEmpty) return message;
    return null;
  }

  String? _newPasswordValidator(String? value) {
    final clean = value ?? '';
    if (clean.isEmpty) return 'Ingresa la nueva contraseña';
    if (clean.length < 8) return 'Mínimo 8 caracteres';
    final hasLetter = clean.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = clean.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasDigit) return 'Debe incluir letras y números';
    return null;
  }

  String? _confirmValidator(String? value) {
    final clean = value ?? '';
    if (clean.isEmpty) return 'Repite la nueva contraseña';
    if (clean != _newController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon, String field) {
    final errors = _fieldErrors[field];
    if (errors is List && errors.isNotEmpty) {
      return PetFormStyles.inputDecoration(label, icon).copyWith(errorText: errors.first.toString());
    }

    return PetFormStyles.inputDecoration(label, icon);
  }

  void _clearFieldError(String field) {
    if (_fieldErrors.containsKey(field)) {
      setState(() {
        _fieldErrors.remove(field);
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _fieldErrors = {};
    });

    final Map<String, dynamic> payload = {
      'current_password': _currentController.text,
      'new_password': _newController.text,
      'new_password_confirmation': _confirmController.text,
    };

    try {
      await _repository.updatePassword(payload);
      if (!mounted) return;

      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      setState(() {});

      ApiSuccessHandler.handle(
        context,
        title: 'Contraseña actualizada',
        description: 'Tu contraseña se cambió correctamente.',
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
            PetFormStyles.buildSectionHeader('Seguridad', 'Usa una contraseña que no uses en otros sitios'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentController,
              obscureText: true,
              onChanged: (_) => _clearFieldError('current_password'),
              decoration: _inputDecoration('Contraseña actual', Icons.lock_outline_rounded, 'current_password'),
              validator: (value) => _requiredValidator(value, 'Ingresa tu contraseña actual'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _newController,
              obscureText: true,
              onChanged: (_) => _clearFieldError('new_password'),
              decoration: _inputDecoration('Nueva contraseña', Icons.lock_reset_rounded, 'new_password'),
              validator: _newPasswordValidator,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              onChanged: (_) => _clearFieldError('new_password_confirmation'),
              decoration: _inputDecoration('Repite la nueva contraseña', Icons.lock_rounded, 'new_password_confirmation'),
              validator: _confirmValidator,
            ),
            const SizedBox(height: 24),
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