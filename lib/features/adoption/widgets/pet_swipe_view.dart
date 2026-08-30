import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_card.dart';

class PetSwipeView extends StatelessWidget {
  final List<AdoptionPetModel> pets;
  final Function(int) onDismissed;
  final Widget emptyStateWidget;
  final void Function(AdoptionPetModel) onTap;

  const PetSwipeView({
    super.key,
    required this.pets,
    required this.onDismissed,
    required this.emptyStateWidget,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return emptyStateWidget;

    final currentPet = pets.first;

    return Center(
      key: const ValueKey('swipe_view'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: PetSwipeCard(
          pet: currentPet,
          onDismissed: (direction) => onDismissed(0),
          onTap: () => onTap(currentPet)
        ),
      ),
    );
  }
}