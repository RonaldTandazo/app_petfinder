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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final bool isSmallPhone = width < 360;
        final bool isMobile = width < 600;
        final bool isShortScreen = height < 650;

        final double horizontalPadding = isSmallPhone
            ? 8
            : isMobile
                ? 12
                : 20;

        final double verticalPadding = isSmallPhone
            ? 6
            : isShortScreen
                ? 8
                : isMobile
                    ? 12
                    : 20;

        if (pets.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: isSmallPhone ? 40 : isMobile ? 60 : 100,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: emptyStateWidget,
              ),
            ],
          );
        }

        final currentPet = pets.first;
        final distance = getDistance(currentPet);

        return SingleChildScrollView(
          key: const ValueKey('swipe_view'),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
            ),
            child: SizedBox(
              height: height,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: PetSwipeCard(
                    pet: currentPet,
                    distance: distance,
                    onDismissed: (direction) => onDismissed(0),
                    onTap: () => onTap(currentPet),
                  ),
                ),
              ),
            ),
          )
        );
      }
    );
  }
}