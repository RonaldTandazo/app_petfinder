import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/widgets/app_badge.dart';
import 'package:app_petfinder/widgets/app_image_placeholders.dart';

class PetGridCard extends StatelessWidget {
  final AdoptionPetModel pet;
  final VoidCallback? onTap;

  const PetGridCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = pet.picture.trim().isNotEmpty;
    final bool isMale = pet.genderTag == 'MALE';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImage
                      ? Image.network(
                          pet.picture,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return AppImagePlaceholders.light(
                              icon: Icons.broken_image_outlined,
                              message: 'No se pudo obtener\nla imagen',
                            );
                          },
                        )
                      : AppImagePlaceholders.light(
                          icon: Icons.pets,
                          message: 'Sin imagen disponible',
                        ),

                    if (pet.isUrgent)
                      const AppBadge(
                        text: 'URGENTE',
                        icon: Icons.warning_amber_rounded,
                        position: BadgePosition.topLeft,
                        fontSize: 9,
                        iconSize: 12,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        isMale ? Icons.male : Icons.female,
                        size: 20,
                        color: isMale ? Colors.blue : Colors.pink,
                      ),
                    ],
                  ),
                  if (pet.race != null && pet.race!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      pet.race!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    pet.age,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}