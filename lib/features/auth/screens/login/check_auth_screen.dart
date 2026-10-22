import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/main/main_routes.dart';
import 'package:app_petfinder/core/router/auth/auth_routes.dart';
import 'package:app_petfinder/repository/auth/auth_repository.dart';
import 'package:app_petfinder/core/router/legal/legal_routes.dart';
import 'package:app_petfinder/models/legal/legal_document_model.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {  
      final response = await _authRepository.checkAuthStatus();
      if (!mounted) return;

      if (!response.ok) {
        context.go(AuthRoutes.login);
      }

      final data = response.data;

      if (data == null) {
        context.go(MainRoutes.adoptions);
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

      context.go(MainRoutes.adoptions);
    } catch (e) {
      if (!mounted) return;

      context.go(AuthRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Cargando PetFinder...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}