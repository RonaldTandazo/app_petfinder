import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/management/screens/change_password_screen.dart';
import 'package:app_petfinder/features/management/screens/delete_account_screen.dart';

class ManagementRoutes {
  static const String prefix = '/management';

  static const String changePassword = '$prefix/change-password';
  static const String deleteAccount = '$prefix/delete-account';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
    ];
  }
}