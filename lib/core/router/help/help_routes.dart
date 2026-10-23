import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/help/screens/help_screen.dart';
import 'package:app_petfinder/features/help/screens/help_form_screen.dart';
import 'package:app_petfinder/enums/help/help_form_type.dart';

class HelpRoutes {
  static const String prefix = '/help';

  static const String index = '$prefix/index';
  static const String support = '$prefix/support';
  static const String feedback = '$prefix/feedback';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: index,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: HelpRoutes.support,
        builder: (context, state) => const HelpFormScreen(
          type: HelpFormType.support,
        ),
      ),
      GoRoute(
        path: HelpRoutes.feedback,
        builder: (context, state) => const HelpFormScreen(
          type: HelpFormType.feedback,
        ),
      ),
    ];
  }
}