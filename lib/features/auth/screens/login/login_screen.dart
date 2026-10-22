import 'package:app_petfinder/core/router/legal/legal_routes.dart';
import 'package:app_petfinder/models/legal/legal_document_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/repository/auth/auth_repository.dart';
import 'package:app_petfinder/features/auth/widgets/account_selection_bottom_sheet.dart';
import 'package:app_petfinder/features/auth/widgets/register_type_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin([String? accountType]) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      if (accountType != null) 'account_type': accountType,
    };

    try {
      final response = await _authRepository.login(payload);
      if (!mounted) return;

      final data = response.data;

      if (data == null) {
        context.go(MainRoutes.adoptions);
        return;
      }

      if (data['requires_account_selection'] == true) {
        _showAccountSelectionModal();
        return;
      }

      final legalDocumentsJson = data['legal_documents'];

      final List<LegalDocumentModel> legalDocuments =
          legalDocumentsJson is List
              ? legalDocumentsJson
                  .map((e) => LegalDocumentModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : <LegalDocumentModel>[];

      if (data['requires_legal_acceptances'] == true && legalDocuments.isNotEmpty) {
        context.go(LegalRoutes.acceptance, extra: legalDocuments);
        return;
      }

      ApiSuccessHandler.handle(context, title: response.message);

      context.go(MainRoutes.adoptions);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAccountSelectionModal() async {
    final type = await AccountSelectionBottomSheet.show(context);
    if (type == null) return;

    _submitLogin(type);
  }

  void _showRegisterTypeModal(BuildContext context) async {
    await RegisterTypeBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final horizontalPadding = isSmallPhone
        ? 16.0
        : isTablet
            ? 32.0
            : 24.0;

    final contentMaxWidth = isTablet ? 420.0 : 480.0;

    final iconSize = isSmallPhone ? 52.0 : 64.0;
    final titleSize = isSmallPhone ? 26.0 : 30.0;
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
                  minHeight: constraints.maxHeight -
                      (isSmallPhone ? 24.0 : 32.0),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentMaxWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: iconSize,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'PetFinder',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: titleSize,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bienvenido de vuelta',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: sectionSpacing),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
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
                          SizedBox(height: fieldSpacing),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitLogin(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
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
                              return (v != null && v.length >= 8)
                                  ? null
                                  : 'Mínimo 8 caracteres';
                            },
                          ),

                          SizedBox(height: isSmallPhone ? 22.0 : 28.0),

                          FilledButton(
                            onPressed: _isLoading ? null : () => _submitLogin(),
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
                                    'Iniciar Sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                          SizedBox(height: isSmallPhone ? 12.0 : 20.0),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showRegisterTypeModal(context),
                                child: const Text('Regístrate aquí'),
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
}