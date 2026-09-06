import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/account/pet_source.dart';
import 'package:app_petfinder/features/account/widgets/pet_card_with_actions.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';

typedef PetActionCallback = void Function(int id, PetSource source);

class AdoptionPetsGrid extends StatelessWidget {
  final List<AdoptionPetListModel> pets;
  final bool isMyProfile;
  final bool isLoadingMore;
  final Widget emptyStateWidget;
  final PetActionCallback? onEdit;
  final PetActionCallback? onDelete;
  final PetActionCallback? onStatusChange;

  const AdoptionPetsGrid({
    super.key,
    required this.pets,
    required this.isMyProfile,
    required this.isLoadingMore,
    required this.emptyStateWidget,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
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

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final AdoptionPetListModel pet = pets[index];

              return PetCardWithActions(
                title: pet.name,
                picture: pet.picture,
                genderTag: pet.genderTag,
                isUrgent: pet.isUrgent,
                badgeLabel: 'En adopción',
                badgeColor: Colors.blue,
                iconData: Icons.pets,
                showActions: isMyProfile,
                onStatusChange: () => onStatusChange?.call(pet.id, PetSource.adoption),
                onEdit: () => onEdit?.call(pet.id, PetSource.adoption),
                onDelete: () => onDelete?.call(pet.id, PetSource.adoption),
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator.adaptive(),
          ),
      ],
    );
  }
}