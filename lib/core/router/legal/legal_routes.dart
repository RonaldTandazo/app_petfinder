import 'package:app_petfinder/enums/legal/legal_document_type.dart';
import 'package:app_petfinder/features/legal/screens/legal_acceptance_screen.dart';
import 'package:app_petfinder/models/legal/legal_document_model.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/legal/screens/legal_document_screen.dart';

class LegalRoutes {
  static const String prefix = '/legal';

  static const String terms = '$prefix/terms';
  static const String privacy = '$prefix/privacy';
  static const String acceptance = '$prefix/acceptance';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: terms,
        builder: (context, state) => const LegalDocumentScreen(
          type: LegalDocumentType.terms,
        ),
      ),
      GoRoute(
        path: privacy,
        builder: (context, state) => const LegalDocumentScreen(
          type: LegalDocumentType.privacy,
        ),
      ),
      GoRoute(
        path: acceptance,
        builder: (context, state) {
          final extra = state.extra;

          final List<LegalDocumentModel> legalDocuments = extra is List<LegalDocumentModel> ? extra : <LegalDocumentModel>[];

          return LegalAcceptanceScreen(legalDocuments: legalDocuments);
        },
      ),
    ];
  }
}