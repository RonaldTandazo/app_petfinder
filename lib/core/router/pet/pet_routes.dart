import 'package:app_petfinder/features/pet/screens/detail/pet_detail_screen.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/pet/screens/publish/publish_pet_screen.dart';

class PetRoutes {
  static const String prefix = '/pet';

  static const String publish = '$prefix/publish';
  static const String petDetail = '$prefix/detail';

  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: publish,
        builder: (context, state) => const PublishPetScreen(),
      ),
      GoRoute(
        path: petDetail,
        builder: (context, state) {
          final pet = state.extra as AdoptionPetModel?;
          return PetDetailScreen(pet: pet);
        },
      ),
    ];
  }
}