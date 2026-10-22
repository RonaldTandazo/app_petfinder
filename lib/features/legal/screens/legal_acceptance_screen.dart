import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/core/utils/api_success_handler.dart';
import 'package:app_petfinder/enums/snackbar/snackbar_type.dart';
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

  Widget _buildLegalAcceptance(LegalDocumentModel document) {
    return CheckboxListTile(
      value: _accepted[document.id] ?? false,
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
          const Text('He leído y acepto los '),
          InkWell(
            onTap: document.tag == LegalDocumentType.unknown
              ? null
              : () => context.push(_getDocumentRoute(document.tag)),
            child: Text(
              document.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text('Versión ${document.version}'),
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
          type: SnackBarType.error
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final isSmallPhone = width < 360;
              final isTablet = width >= 600;

              final horizontalPadding =
                  isTablet ? 40.0 : 24.0;

              final iconSize = isSmallPhone
                  ? 64.0
                  : isTablet
                      ? 104.0
                      : 88.0;

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
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Actualizamos nuestros documentos legales',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Para continuar usando PetFinder, '
                            'revisa y acepta los siguientes documentos.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
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
                                child: _buildLegalAcceptance(document),
                              ),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed:
                                _allAccepted && !_isLoading
                                    ? _submitAcceptances
                                    : null,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Aceptar y continuar',
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