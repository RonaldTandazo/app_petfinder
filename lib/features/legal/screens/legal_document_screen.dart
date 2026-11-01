import 'dart:io';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:app_petfinder/enums/legal/legal_document_type.dart';
import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:app_petfinder/repository/legal/legal_repository.dart';

class LegalDocumentScreen extends StatefulWidget {
  final LegalDocumentType type;

  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  final LegalRepository _legalRepository = LegalRepository();

  String _content = '';

  bool _isLoading = true;
  bool _isDownloading = false;
  String? _error;

  String get _title {
    switch (widget.type) {
      case LegalDocumentType.terms:
        return 'Términos y Condiciones';
      case LegalDocumentType.privacy:
        return 'Política de Privacidad';
      case LegalDocumentType.unknown:
        return 'Documento Desconocido';
    }
  }

  String get _tag => widget.type.toTag();

  Map<String, String> get _payload => {
    'tag': _tag,
  };

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    if (widget.type == LegalDocumentType.unknown) {
      setState(() {
        _error = 'Tipo de documento no válido';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _legalRepository.getDocument(_payload);
      if (!mounted) return;

      final data = response.data;

      if(data != null){
        setState(() => _content = data['content']);

      }

      if (_content.isEmpty) {
        throw Exception('El documento no contiene contenido Markdown.');
      }
    } on ApiException catch (e) {
      setState(() {
        _error = 'No se pudo cargar el documento';
      });

      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) {
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final bytes = await _legalRepository.downloadPdf(_payload);

      final directory = await getApplicationDocumentsDirectory();

      final file = File('${directory.path}/${_title.toLowerCase()}.pdf');

      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      final result = await OpenFilex.open(file.path);

      if (!mounted) return;

      if (result.type != ResultType.done) {
        AppSnackBar.show(context, title: 'No se pudo abrir el documento PDF.');
      }
    } on ApiException catch (e) {
      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(theme),
      ),
      bottomNavigationBar: _buildDownloadButton(theme)
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadDocument,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_content.isEmpty) {
      return const Center(
        child: Text('Documento no disponible.'),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: Markdown(
                data: _content,
                selectable: true,
                padding: const EdgeInsets.all(20),
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  p: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  h1: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h2: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h3: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isDownloading ? null : _downloadPdf,
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
            label: Text(
              _isDownloading
                  ? 'Descargando...'
                  : 'Descargar',
            ),
          ),
        ),
      ),
    );
  }
}