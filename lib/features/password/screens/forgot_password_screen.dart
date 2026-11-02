
import 'package:flutter/material.dart';
import 'package:app_petfinder/repository/password/password_repository.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/features/auth/widgets/account_selection_bottom_sheet.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PasswordRepository _passwordRepository = PasswordRepository();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _accountType;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showAccountSelectionModal() async {
    final String? type = await AccountSelectionBottomSheet.show(context);
    if (type == null) return;

    setState(() => _accountType = type);

    _submit();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'email': _emailController.text.trim(),
      if (_accountType != null) 'account_type': _accountType,
    };

    try {
      final response = await _passwordRepository.forgotPassword(payload);
      if (!mounted) return;

      final data = response.data;

      if (data == null) {
        setState(() => _emailSent = true);
        return;
      }

      if (data['requires_account_selection'] == true) {
        _showAccountSelectionModal();
        return;
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _accountType = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isSmallPhone
        ? 16.0
        : isTablet
            ? 32.0
            : 24.0;

    final double contentMaxWidth = isTablet ? 420.0 : 480.0;

    final double iconSize = isSmallPhone ? 52.0 : 64.0;
    final double titleSize = isSmallPhone ? 24.0 : 28.0;
    final double sectionSpacing = isSmallPhone ? 24.0 : 32.0;
    final double fieldSpacing = isSmallPhone ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: _emailSent
                      ? _buildSuccessContent(
                          theme,
                          isSmallPhone,
                          iconSize,
                          titleSize,
                          sectionSpacing,
                        )
                      : _buildFormContent(
                          theme,
                          isSmallPhone,
                          iconSize,
                          titleSize,
                          sectionSpacing,
                          fieldSpacing,
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

  Widget _buildFormContent(
    ThemeData theme,
    bool isSmallPhone,
    double iconSize,
    double titleSize,
    double sectionSpacing,
    double fieldSpacing,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_reset_rounded,
            size: iconSize,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '¿Olvidaste tu contraseña?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No te preocupes. Ingresa el correo electrónico asociado '
            'a tu cuenta y te enviaremos instrucciones para '
            'restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sectionSpacing),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa tu correo';
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
          SizedBox(height: isSmallPhone ? 22.0 : 28.0),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isSmallPhone ? 14.0 : 16.0,
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
                    'Enviar Instrucciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(
    ThemeData theme,
    bool isSmallPhone,
    double iconSize,
    double titleSize,
    double sectionSpacing,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: iconSize + 8,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Revisa tu correo',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Si existe una cuenta asociada al correo ingresado, '
          'recibirás instrucciones para restablecer tu contraseña. '
          'Revisa también tu carpeta de spam o correo no deseado.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        )
      ],
    );
  }
}