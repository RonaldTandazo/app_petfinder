import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/lost_pet/screens/publish_lost_pet_screen.dart';
import 'package:app_petfinder/features/lost_pet/screens/lost_pet_screen.dart';

class LostPetRoutes {
  static const String prefix = '/lost-pet';

  static const String publish = '$prefix/publish';
  static const String lostPetDetail = '$prefix/detail';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: publish,
        builder: (context, state) => const PublishLostPetScreen(),
      ),
      GoRoute(
        path: lostPetDetail,
        builder: (context, state) {
          final int lostPetId = state.extra as int;
          return LostPetScreen(lostPetId: lostPetId);
        },
      ),
    ];
  }
}