import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/account/screens/edit_user_screen.dart';
import 'package:app_petfinder/features/account/screens/edit_shelter_screen.dart';
import 'package:app_petfinder/features/account/screens/management_screen.dart';
import 'package:app_petfinder/features/followed/screens/followed_pets_screen.dart';

class AccountRoutes {
  static const String prefix = '/account';

  static const String editUser = '$prefix/edit-user';
  static const String editShelter = '$prefix/edit-shelter';
  static const String management = '$prefix/management';
  static const String followedPets = '$prefix/followed-pets';

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
        path: management,
        builder: (context, state) => const ManagementScreen(),
      ),
      GoRoute(
        path: followedPets,
        builder: (context, state) => const FollowedPetsScreen(),
      ),
    ];
  }
}