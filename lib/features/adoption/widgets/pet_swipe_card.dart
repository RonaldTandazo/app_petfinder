import 'package:flutter/material.dart';
import 'package:app_petfinder/models/adoption/adoption_pet_model.dart';

class PetSwipeCard extends StatelessWidget {
  final AdoptionPetModel pet;
  final DismissDirectionCallback onDismissed;

  const PetSwipeCard({
    super.key,
    required this.pet,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(pet.id.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: onDismissed,
      child: Container(
        height: 480,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.teal.shade700, // Background provisorio mientras se integra la imagen
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            // Descomentar cuando exista imageUrl
            /*
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                pet.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            */
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Text(
                    '${pet.name}, ${pet.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    pet.genderTag == 'MALE' ? Icons.male : Icons.female,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}