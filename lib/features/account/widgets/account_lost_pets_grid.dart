import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/account/pet_source.dart';
import 'package:app_petfinder/features/account/widgets/pet_card_with_actions.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_list_model.dart';

typedef PetActionCallback = void Function(int id, PetSource source);

class AccountLostPetsGrid extends StatelessWidget {
  final List<LostPetListModel> lostPets;
  final bool isMyProfile;
  final bool isLoadingMore;
  final Widget emptyStateWidget;
  final PetActionCallback? onEdit;
  final PetActionCallback? onDelete;
  final PetActionCallback? onStatusChange;

  const AccountLostPetsGrid({
    super.key,
    required this.lostPets,
    required this.isMyProfile,
    required this.isLoadingMore,
    required this.emptyStateWidget,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    if (lostPets.isEmpty) {
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
            itemCount: lostPets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final LostPetListModel lostPet = lostPets[index];

              return PetCardWithActions(
                title: lostPet.name,
                picture: lostPet.picture,
                genderTag: lostPet.genderTag,
                badgeLabel: 'Perdida',
                badgeColor: Colors.amber[800]!,
                iconData: Icons.warning_amber_rounded,
                statusActionLabel: 'Marcar como Encontrada',
                showActions: isMyProfile,
                onStatusChange: () => onStatusChange?.call(lostPet.id, PetSource.lost),
                onEdit: () => onEdit?.call(lostPet.id, PetSource.lost),
                onDelete: () => onDelete?.call(lostPet.id, PetSource.lost),
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