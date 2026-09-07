import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/account/screens/edit_user_screen.dart';
import 'package:app_petfinder/features/account/screens/edit_shelter_screen.dart';
import 'package:app_petfinder/features/account/screens/change_password_screen.dart';

class AccountRoutes {
  static const String prefix = '/account';

  static const String editUser = '$prefix/edit-user';
  static const String editShelter = '$prefix/edit-shelter';
  static const String changePassword = '$prefix/change-password';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: editUser,
        builder: (context, state) => const EditUserScreen(),
      ),
      GoRoute(
        path: editShelter,
        builder: (context, state) => const EditShelterScreen(),
      ),
      GoRoute(
        path: changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ];
  }
}