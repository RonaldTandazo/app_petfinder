import 'package:app_petfinder/features/account/screens/change_password_screen.dart';
import 'package:go_router/go_router.dart';

class AccountRoutes {
  static const String prefix = '/account';

  static const String changePassword = '$prefix/change-password';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ];
  }
}