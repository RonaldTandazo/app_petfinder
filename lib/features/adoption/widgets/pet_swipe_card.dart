import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/enums/badge/badge_position.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';
import 'package:app_petfinder/widgets/badges/app_badge.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class PetSwipeCard extends StatelessWidget {
  final AdoptionPetListModel pet;
  final DismissDirectionCallback onDismissed;
  final VoidCallback? onTap;
  final String? distance;

  const PetSwipeCard({
    super.key,
    required this.pet,
    required this.onDismissed,
    this.onTap,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;

    final bool isMale = pet.genderTag == 'MALE';
    final bool hasImage = pet.picture.trim().isNotEmpty;

    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    final double cardRadius = isMobile ? 20 : 28;
    final double horizontalPadding = isSmallPhone ? 12 : isMobile ? 16 : 20;
    final double bottomPadding = isSmallPhone ? 14 : isMobile ? 18 : 24;

    final double nameFontSize = isSmallPhone
        ? 19
        : isMobile
            ? 22
            : 26;

    final double genderIconSize = isSmallPhone ? 22 : isMobile ? 24 : 28;
    final double distanceFontSize = isSmallPhone ? 11 : 13;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : screenSize.height * (isMobile ? 0.68 : 0.65);

        final double cardHeight = availableHeight
            .clamp(240.0, isMobile ? 600.0 : 680.0)
            .toDouble();

        return Dismissible(
           key: Key(pet.id.toString()),
          direction: DismissDirection.horizontal,
          onDismissed: onDismissed,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: cardHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: isMobile ? 12 : 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      Image.network(
                        pet.picture,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Container(
                            color: Colors.grey.shade900,
                            child: Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return AppImagePlaceholders.swipe(
                            icon: Icons.broken_image_outlined,
                            message: 'No se pudo obtener la imagen',
                          );
                        },
                      )
                    else
                      AppImagePlaceholders.swipe(
                        icon: Icons.pets,
                        message: 'Sin imagen disponible',
                      ),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),

                    if (pet.isUrgent)
                      AppBadge(
                        text: 'URGENTE',
                        icon: Icons.warning_amber_rounded,
                        position: BadgePosition.topLeft,
                        fontSize: isSmallPhone ? 9 : 11,
                        iconSize: isSmallPhone ? 12 : 15,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 6 : 8,
                          vertical: isSmallPhone ? 3 : 4,
                        ),
                      ),

                    Positioned(
                      bottom: bottomPadding,
                      left: horizontalPadding,
                      right: horizontalPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      pet.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: nameFontSize,
                                        height: 1.15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isMobile) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        pet.age,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isSmallPhone ? 12 : 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: isSmallPhone ? 4 : 8),
                              Icon(
                                genderIcon,
                                size: genderIconSize,
                                color: genderColor,
                              ),
                            ],
                          ),

                          if (!isMobile) ...[
                            const SizedBox(height: 4),
                            Text(
                              pet.age,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          if (distance != null) ...[
                            SizedBox(height: isSmallPhone ? 6 : 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: isSmallPhone ? 14 : 16,
                                  color: Colors.tealAccent,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '$distance de ti',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: distanceFontSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}