import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_card.dart';

class PetSwipeView extends StatelessWidget {
  final List<AdoptionPetListModel> pets;
  final Function(int) onDismissed;
  final Widget emptyStateWidget;
  final void Function(AdoptionPetListModel) onTap;
  final String? Function(AdoptionPetListModel) getDistance;

  const PetSwipeView({
    super.key,
    required this.pets,
    required this.onDismissed,
    required this.emptyStateWidget,
    required this.onTap,
    required this.getDistance,
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          emptyStateWidget,
        ],
      );
    }

    final currentPet = pets.first;
    final distance = getDistance(currentPet);

    return LayoutBuilder(
      key: const ValueKey('swipe_view'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PetSwipeCard(
                  pet: currentPet,
                  distance: distance,
                  onDismissed: (direction) => onDismissed(0),
                  onTap: () => onTap(currentPet),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}