import 'package:flutter/material.dart';

class AppPetHeaderInfo extends StatelessWidget {
  final String name;
  final String species;
  final String? race;
  final String size;
  final String animalGenderTag;
  final String? reportStatus;
  final String? reportStatusTag;
  final bool hasReward;
  final double? rewardAmount;

  const AppPetHeaderInfo({
    super.key,
    required this.name,
    required this.species,
    this.race,
    required this.size,
    required this.animalGenderTag,
    this.reportStatus,
    this.reportStatusTag,
    required this.hasReward,
    this.rewardAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = animalGenderTag == 'MALE';
    final showReward = hasReward && (rewardAmount ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(reportStatus != null && reportStatusTag != null && reportStatus!.isNotEmpty && reportStatusTag!.isNotEmpty)
              Chip(
                label: Text(
                  reportStatus!.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                backgroundColor: reportStatusTag == 'ACTIVE' ? Colors.redAccent : Colors.teal,
                visualDensity: VisualDensity.compact,
              ),
            if (showReward)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber.shade700),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber.shade800, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Recompensa: \$${rewardAmount!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(
              isMale ? Icons.male : Icons.female,
              color: isMale ? Colors.blue : Colors.pink,
              size: 26,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$species • ${race ?? 'Raza desconocida'} • Tamaño $size',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}