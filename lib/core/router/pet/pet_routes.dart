import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/pet/screens/publish_pet_screen.dart';

class PetRoutes {
  static const String prefix = '/pet';

  static const String publish = '$prefix/publish';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: publish,
        builder: (context, state) => const PublishPetScreen(),
      ),
    ];
  }
}