import 'package:app_petfinder/enums/legal/legal_document_type.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/legal/screens/legal_document_screen.dart';

class LegalRoutes {
  static const String prefix = '/legal';

  static const String terms = '$prefix/terms';
  static const String privacy = '$prefix/privacy';

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
    ];
  }
}