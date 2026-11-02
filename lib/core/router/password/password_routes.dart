import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/password/screens/forgot_password_screen.dart';

class PasswordRoutes {
  static const String prefix = '/password';

  static const String forgotPassword = '$prefix/forgot';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ];
  }
}