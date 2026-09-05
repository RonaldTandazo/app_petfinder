import 'package:flutter/material.dart';
import 'package:app_petfinder/features/adoption/widgets/pet_grid_card.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';

class PetGridView extends StatelessWidget {
  final List<AdoptionPetListModel> pets;
  final bool isLoadingMore;
  final Widget emptyStateWidget;
  final void Function(AdoptionPetListModel) onTap;
  final String? Function(AdoptionPetListModel) getDistance;
  final ScrollController controller;

  const PetGridView({
    super.key,
    required this.pets,
    this.isLoadingMore = false,
    required this.emptyStateWidget,
    required this.onTap,
    required this.getDistance,
    required this.controller,
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

    return CustomScrollView(
      key: const ValueKey('grid_view'),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pet = pets[index];
                final distance = getDistance(pet);

                return PetGridCard(
                  pet: pet,
                  distance: distance,
                  onTap: () => onTap(pet),
                );
              },
              childCount: pets.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
          ),
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
          ),
      ],
    );
  }
}