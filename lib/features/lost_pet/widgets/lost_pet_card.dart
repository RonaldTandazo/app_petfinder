import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';
import 'package:app_petfinder/models/lost_pet/lost_pet_list_model.dart';

class LostPetCard extends StatelessWidget {
  final LostPetListModel lostPet;
  final String? distance;
  final void Function(LostPetListModel) onTap;

  const LostPetCard({
    super.key,
    required this.lostPet,
    this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isTablet = screenSize.width >= 600;

    final double imageSize = isSmallPhone
        ? 80
        : isTablet
            ? 120
            : 100;

    final double cardPadding = isSmallPhone ? 8 : 12;
    final double imageSpacing = isSmallPhone ? 8 : 12;
    final double nameFontSize = isSmallPhone ? 14 : isTablet ? 18 : 16;
    final double descriptionFontSize = isSmallPhone ? 11 : 13;
    final double locationFontSize = isSmallPhone ? 10 : 12;

    final bool hasImage = lostPet.picture.trim().isNotEmpty;
    final bool isLost = lostPet.reportStatusTag == 'ACTIVE';

    final Color badgeColor = isLost ? Colors.redAccent : Colors.teal;
    final String badgeText = lostPet.reportStatus;

    final bool isMale = lostPet.genderTag == 'MALE';
    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    final String description =
        lostPet.race != null && lostPet.race!.trim().isNotEmpty
            ? '${lostPet.species} • ${lostPet.race}'
            : lostPet.species;

    final String location =
        lostPet.eventAddress != null &&
                lostPet.eventAddress!.trim().isNotEmpty
            ? '${lostPet.eventAddress}, ${lostPet.city}'
            : lostPet.city;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 10 : 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap(lostPet),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y estado
                Stack(
                  children: [
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasImage
                            ? Image.network(
                                lostPet.picture,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return AppImagePlaceholders.card(
                                    icon: Icons.broken_image_outlined,
                                    message: 'No se pudo obtener\nla imagen',
                                  );
                                },
                              )
                            : AppImagePlaceholders.card(
                                icon: Icons.pets,
                                message: 'Sin imagen disponible',
                              ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: imageSize - 10,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 4 : 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallPhone ? 8 : 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: imageSpacing),

                // Información de la mascota
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y género
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lostPet.name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            genderIcon,
                            size: isSmallPhone ? 16 : 18,
                            color: genderColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Fecha
                      Text(
                        formatDate(lostPet.eventDate),
                        style: TextStyle(
                          fontSize: isSmallPhone ? 10 : 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 5),

                      // Especie y raza
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Ubicación
                      if (location.trim().isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: isSmallPhone ? 13 : 14,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: locationFontSize,
                                  color: Colors.black54,
                                ),
                                maxLines: isSmallPhone ? 2 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      // Distancia debajo de la ubicación
                      if (distance != null &&
                          distance!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 5 : 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_outlined,
                                size: isSmallPhone ? 11 : 13,
                                color: Colors.teal.shade700,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  distance!,
                                  style: TextStyle(
                                    fontSize: isSmallPhone ? 10 : 11,
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
}