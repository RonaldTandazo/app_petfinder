import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_swipe_card.dart';

class PetSwipeView extends StatelessWidget {
  final List<AdoptionPetModel> pets;
  final Function(int) onDismissed;
  final Widget emptyStateWidget;

  const PetSwipeView({
    super.key,
    required this.pets,
    required this.onDismissed,
    required this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return emptyStateWidget;

    return Center(
      key: const ValueKey('swipe_view'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: PetSwipeCard(
          pet: pets.first,
          onDismissed: (direction) => onDismissed(0),
        ),
      ),
    );
  }
}