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
  final PetActionCallback? onTap;
  final PetActionCallback? onEdit;
  final PetActionCallback? onDelete;
  final PetActionCallback? onStatusChange;

  const AccountLostPetsGrid({
    super.key,
    required this.lostPets,
    required this.isMyProfile,
    required this.isLoadingMore,
    required this.emptyStateWidget,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final double gridPadding = isSmallPhone ? 8 : isMobile ? 10 : 12;
    final double gridSpacing = isSmallPhone ? 6 : 10;

    final double childAspectRatio = isSmallPhone
        ? 0.72
        : isMobile
            ? 0.75
            : 0.78;

    if (lostPets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: isSmallPhone ? 60 : 100,
          left: gridPadding,
          right: gridPadding,
        ),
        children: [
          emptyStateWidget,
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(gridPadding),
            itemCount: lostPets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              childAspectRatio: childAspectRatio,
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
                onTap: () => onTap?.call(lostPet.id, PetSource.lost),
                onEdit: () => onEdit?.call(lostPet.id, PetSource.lost),
                onDelete: () => onDelete?.call(lostPet.id, PetSource.lost),
                onStatusChange: () => onStatusChange?.call(lostPet.id, PetSource.lost),
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