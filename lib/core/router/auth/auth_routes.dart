import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/auth/screens/login/check_auth_screen.dart';
import 'package:app_petfinder/features/auth/screens/login/login_screen.dart';
import 'package:app_petfinder/features/auth/screens/register/register_shelter.dart';
import 'package:app_petfinder/features/auth/screens/register/register_user.dart';

class AuthRoutes {
  static const String prefix = '/auth';

  static const String checkAuth = '$prefix/check-auth';
  static const String login = '$prefix/login';
  static const String registerTutor = '$prefix/register-user';
  static const String registerShelter = '$prefix/register-shelter';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: checkAuth,
        builder: (context, state) => const CheckAuthScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerTutor,
        builder: (context, state) => const RegisterUserScreen(),
      ),
      GoRoute(
        path: registerShelter,
        builder: (context, state) => const RegisterShelterScreen(),
      ),
    ];
  }
}