import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:flutter/material.dart';
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
    final bool hasImage = lostPet.picture.trim().isNotEmpty;
    final bool isLost = lostPet.reportStatusTag == 'ACTIVE';
    final Color badgeColor = isLost ? Colors.redAccent : Colors.teal;
    final String badgeText = lostPet.reportStatus;
    
    // Identificación de género
    final bool isMale = lostPet.genderTag == 'MALE';
    final bool hasGender = lostPet.genderTag.isNotEmpty;

    // Sublínea: Raza • Especie (o solo Especie)
    final String description = (lostPet.race != null && lostPet.race!.trim().isNotEmpty)
      ? '${lostPet.species} • ${lostPet.race}'
      : lostPet.species;

    // Ubicación: Dirección + Ciudad (o fallback a solo Ciudad)
    final String location = (lostPet.eventAddress != null && lostPet.eventAddress!.trim().isNotEmpty)
      ? '${lostPet.eventAddress}, ${lostPet.city}'
      : lostPet.city;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen con Badge de Estado
                Stack(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasImage
                            ? Image.network(
                                lostPet.picture,
                                width: 100,
                                height: 100,
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
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Información Principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + Icono de Género + Fecha
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    lostPet.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasGender) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    isMale ? Icons.male : Icons.female,
                                    size: 18,
                                    color: isMale ? Colors.blue : Colors.pink,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDate(lostPet.eventDate),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Raza • Especie
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Ubicación (Dirección + Ciudad)
                      Row(
                        children: [
                          if (location.trim().isNotEmpty) ...[
                            const Icon(Icons.location_on, size: 14, color: Colors.teal),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          
                          // Badge de Distancia
                          if (distance != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.teal.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    distance!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                ],
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
      ),
    );
  }
}