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

        final double verticalPadding = isSmallPhone ? 6 : 8;

        final double gridSpacing = isSmallPhone
            ? 8
            : isMobile
                ? 10
                : 14;

        final double childAspectRatio = isSmallPhone
            ? 0.62
            : isMobile
                ? 0.68
                : 0.72;

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

        return CustomScrollView(
          key: const ValueKey('grid_view'),
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final pet = pets[index];

                    return PetGridCard(
                      pet: pet,
                      distance: getDistance(pet),
                      onTap: () => onTap(pet),
                    );
                  },
                  childCount: pets.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                ),
              ),
            ),
            if (isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isShortScreen ? 12 : 16,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    );
  }
}