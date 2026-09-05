import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/adoption/screens/publish_adoption_pet_screen.dart';
import 'package:app_petfinder/features/adoption/screens/adoption_pet_screen.dart';

class AdoptionRoutes {
  static const String prefix = '/adoption';

  static const String publish = '$prefix/publish';
  static const String adoptionPet = '$prefix/pet';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: publish,
        builder: (context, state) => const PublishAdoptionPetScreen(),
      ),
      GoRoute(
        path: adoptionPet,
        builder: (context, state) {
          final int petId = state.extra as int;
          return AdoptionPetScreen(petId: petId);
        },
      ),
    ];
  }
}