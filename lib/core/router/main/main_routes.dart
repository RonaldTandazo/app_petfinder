import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/account/screens/account_screen.dart';
import 'package:app_petfinder/features/layout/screens/main_layout_screen.dart';
import 'package:app_petfinder/features/adoption/screens/adoption_main_screen.dart';
import 'package:app_petfinder/features/community/screens/feed_screen.dart';
import 'package:app_petfinder/features/lost_pet/screens/lost_pet_main_screen.dart';

class MainRoutes {
  static const String prefix = '/main';

  static const String adoptions = '$prefix/adoptions';
  static const String lostPets = '$prefix/lost-pets';
  static const String community = '$prefix/community';
  static const String account = '$prefix/profile';

  static RouteBase getRoutes() {
    return ShellRoute(
      builder: (context, state, child) {
        return MainLayoutScreen(child: child);
      },
      routes: [
        GoRoute(
          path: adoptions,
          builder: (context, state) => const AdoptionHomeScreen(),
        ),
        GoRoute(
          path: lostPets,
          builder: (context, state) => const LostPetHomeScreen(),
        ),
        GoRoute(
          path: community,
          builder: (context, state) => const CommunityFeedScreen(),
        ),
        GoRoute(
          path: account,
          builder: (context, state) => const AccountScreen(),
        ),
      ],
    );
  }
}