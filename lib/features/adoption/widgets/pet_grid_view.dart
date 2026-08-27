import 'package:flutter/material.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_grid_card.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';

class PetGridView extends StatelessWidget {
  final List<AdoptionPetModel> pets;
  final Widget emptyStateWidget;

  const PetGridView({
    super.key,
    required this.pets,
    required this.emptyStateWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return emptyStateWidget;

    return GridView.builder(
      key: const ValueKey('grid_view'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return PetGridCard(pet: pets[index]);
      },
    );
  }
}