import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/enums/badge/badge_position.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_list_model.dart';
import 'package:app_petfinder/widgets/badges/app_badge.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class PetGridCard extends StatelessWidget {
  final AdoptionPetListModel pet;
  final VoidCallback? onTap;
  final String? distance;

  const PetGridCard({
    super.key,
    required this.pet,
    this.onTap,
    this.distance
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final bool isMale = pet.genderTag == 'MALE';
    final bool hasImage = pet.picture.trim().isNotEmpty;

    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    final double cardRadius = isMobile ? 12 : 20;
    final double contentPadding = isSmallPhone ? 6 : isMobile ? 8 : 12;
    final double nameFontSize = isSmallPhone ? 10 : isMobile ? 12 : 16;
    final double raceFontSize = isSmallPhone ? 9 : isMobile ? 10 : 12;
    final double detailFontSize = isSmallPhone ? 9 : isMobile ? 10 : 11;
    final double genderIconSize = isSmallPhone ? 16 : isMobile ? 18 : 20;
    final double locationIconSize = isSmallPhone ? 10 : 12;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: isMobile ? 6 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(cardRadius),
                  ),
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
                              color: Colors.grey.shade100,
                              child: Center(
                                child: SizedBox(
                                  width: isSmallPhone ? 18 : 24,
                                  height: isSmallPhone ? 18 : 24,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return AppImagePlaceholders.card(
                              icon: Icons.broken_image_outlined,
                              message: 'No se pudo obtener\nla imagen',
                            );
                          },
                        )
                      else
                        AppImagePlaceholders.card(
                          icon: Icons.pets,
                          message: 'Sin imagen disponible',
                        ),

                      if (pet.isUrgent)
                        AppBadge(
                          text: 'URGENTE',
                          icon: Icons.warning_amber_rounded,
                          position: BadgePosition.topLeft,
                          fontSize: isSmallPhone ? 7 : isMobile ? 8 : 9,
                          iconSize: isSmallPhone ? 9 : 12,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 4 : 8,
                            vertical: isSmallPhone ? 2 : 4,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: nameFontSize,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: isSmallPhone ? 2 : 4),
                        Icon(
                          genderIcon,
                          size: genderIconSize,
                          color: genderColor,
                        ),
                      ],
                    ),

                    if (pet.race != null && pet.race!.isNotEmpty) ...[
                      SizedBox(height: isSmallPhone ? 1 : 2),
                      Text(
                        pet.race!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: raceFontSize,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: isSmallPhone ? 4 : 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.age,
                            style: TextStyle(
                              fontSize: detailFontSize,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (distance != null) ...[
                          SizedBox(width: isSmallPhone ? 2 : 4),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallPhone ? 3 : 6,
                                vertical: isSmallPhone ? 1 : 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: locationIconSize,
                                    color: Colors.teal.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      distance!,
                                      style: TextStyle(
                                        fontSize: detailFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}