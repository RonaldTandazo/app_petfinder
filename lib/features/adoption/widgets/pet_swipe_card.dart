import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';
import 'package:app_petfinder/widgets/badges/app_badge.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class PetSwipeCard extends StatelessWidget {
  final AdoptionPetModel pet;
  final DismissDirectionCallback onDismissed;
  final VoidCallback? onTap;

  const PetSwipeCard({
    super.key,
    required this.pet,
    required this.onDismissed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = pet.picture.trim().isNotEmpty;
    final bool isMale = pet.genderTag == 'MALE';

    return Dismissible(
      key: Key(pet.id.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: onDismissed,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 480,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.teal.shade700,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                    ? Image.network(
                        pet.picture,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
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
                    : AppImagePlaceholders.swipe(
                        icon: Icons.pets,
                        message: 'Sin imagen disponible',
                      ),
                ),

                Positioned.fill(
                  child: DecoratedBox(
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
                ),

                if (pet.isUrgent)
                  const AppBadge(
                    text: 'URGENTE',
                    icon: Icons.warning_amber_rounded,
                    position: BadgePosition.topLeft,
                    fontSize: 11,
                    iconSize: 15,
                  ),

                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${pet.name}, ${pet.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isMale ? Icons.male : Icons.female,
                        color: Colors.white,
                        size: 28,
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