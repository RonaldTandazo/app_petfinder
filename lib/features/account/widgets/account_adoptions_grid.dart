import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/account/pet_source.dart';
import 'package:app_petfinder/features/account/widgets/pet_card_with_actions.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';

typedef PetActionCallback = void Function(int id, PetSource source);

class AccountAdoptionsGrid extends StatelessWidget {
  final List<AdoptionPetListModel> pets;
  final bool isMyProfile;
  final bool isLoadingMore;
  final Widget emptyStateWidget;
  final PetActionCallback? onTap;
  final PetActionCallback? onEdit;
  final PetActionCallback? onDelete;
  final PetActionCallback? onStatusChange;

  const AccountAdoptionsGrid({
    super.key,
    required this.pets,
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

    if (pets.isEmpty) {
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
            itemCount: pets.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
              childAspectRatio: childAspectRatio,
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
                onTap: () => onTap?.call(pet.id, PetSource.adoption),
                onEdit: () => onEdit?.call(pet.id, PetSource.adoption),
                onDelete: () => onDelete?.call(pet.id, PetSource.adoption),
                onStatusChange: () => onStatusChange?.call(pet.id, PetSource.adoption),
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