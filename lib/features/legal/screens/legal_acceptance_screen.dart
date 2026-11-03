import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:app_petfinder/repository/legal/legal_repository.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/legal/legal_routes.dart';
import 'package:app_petfinder/models/legal/legal_document_model.dart';
import 'package:app_petfinder/enums/legal/legal_document_type.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';

class LegalAcceptanceScreen extends StatefulWidget {
  final List<LegalDocumentModel> legalDocuments;

  const LegalAcceptanceScreen({
    super.key,
    required this.legalDocuments,
  });

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  final LegalRepository _legalRepository = LegalRepository();
  final Map<int, bool> _accepted = {};

  bool _isLoading = false;

  bool get _allAccepted =>
    widget.legalDocuments.isNotEmpty &&
    widget.legalDocuments.every(
      (document) => document.tag != LegalDocumentType.unknown && _accepted[document.id] == true,
    );

  String _getDocumentRoute(LegalDocumentType tag) {
    switch (tag) {
      case LegalDocumentType.terms:
        return LegalRoutes.terms;
      case LegalDocumentType.privacy:
        return LegalRoutes.privacy;
      case LegalDocumentType.unknown:
        return LegalRoutes.acceptance;
    }
  }

  Widget _buildLegalAcceptance(ThemeData theme, LegalDocumentModel document) {
    return CheckboxListTile(
      value: _accepted[document.id] ?? false,
      activeColor: theme.colorScheme.primary,
      onChanged: _isLoading
        ? null
        : (value) {
          setState(() {
            _accepted[document.id] = value ?? false;
          });
        },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Wrap(
        children: [
          Text(
            'He leído y acepto los ',
            style: theme.textTheme.bodyMedium,
          ),
          InkWell(
            onTap: document.tag == LegalDocumentType.unknown
              ? null
              : () => context.push(_getDocumentRoute(document.tag)),
            child: Text(
              document.name,
              style: TextStyle(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Versión ${document.version}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _submitAcceptances() async {
    if (!_allAccepted || _isLoading) return;

    setState(() => _isLoading = true);
    
    final acceptedDocuments = widget.legalDocuments
      .map((document) => document.tag)
      .where((tag) => tag != LegalDocumentType.unknown)
      .map((tag) => tag.toTag())
      .toList();

    final Map<String, dynamic> payload = {
      'accepted_documents': acceptedDocuments
    };

    try {
      final response = await _legalRepository.acceptance(payload);
      if (!mounted) return;

      if(!response.ok){
        AppSnackBar.show(
          context,
          title: response.message.isNotEmpty
            ? response.message
            : 'No se pudieron aceptar los documentos legales.',
          type: StatusType.error
        );
      }

      ApiSuccessHandler.handle(context, title: response.message);
        
      context.go(MainRoutes.adoptions);
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              final bool isSmallPhone = width < 360;
              final bool isTablet = width >= 600;

              final double horizontalPadding = isTablet ? 40.0 : 24.0;

              final double iconSize = isSmallPhone
                ? 64.0
                : isTablet
                    ? 104.0
                    : 88.0;

              final double sectionSpacing = isSmallPhone ? 20.0 : 24.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 480,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.gpp_good_outlined,
                            size: iconSize,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Actualizamos nuestros documentos legales',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Para continuar usando PetFinder, '
                            'revisa y acepta los siguientes documentos.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          
                          SizedBox(height: sectionSpacing),

                          if (widget.legalDocuments.isEmpty)
                            const Text(
                              'No se pudieron cargar los documentos '
                              'pendientes. Intenta nuevamente.',
                              textAlign: TextAlign.center,
                            )
                          else
                            ...widget.legalDocuments.map(
                              (document) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: _buildLegalAcceptance(theme, document),
                              ),
                            ),

                          SizedBox(height: sectionSpacing),
                          
                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _allAccepted && !_isLoading ? _submitAcceptances : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
                                disabledForegroundColor: colorScheme.onPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline_rounded),
                              label: Text(
                                _isLoading ? 'Procesando...' : 'Aceptar y continuar',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}