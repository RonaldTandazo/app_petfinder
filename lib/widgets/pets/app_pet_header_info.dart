import 'package:flutter/material.dart';

class AppPetHeaderInfo extends StatelessWidget {
  final String name;
  final String species;
  final String? race;
  final String size;
  final String genderTag;
  final String? reportStatus;
  final String? reportStatusTag;
  final bool hasReward;
  final double? rewardAmount;
  final bool isUrgent;

  const AppPetHeaderInfo({
    super.key,
    required this.name,
    required this.species,
    this.race,
    required this.size,
    required this.genderTag,
    this.reportStatus,
    this.reportStatusTag,
    this.hasReward = false,
    this.rewardAmount,
    this.isUrgent = false,
  });

  bool get _hasStatus => reportStatus != null && reportStatusTag != null && reportStatus!.isNotEmpty && reportStatusTag!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bool isMale = genderTag == 'MALE';
    final bool showReward = hasReward && (rewardAmount ?? 0) > 0;

    final String quickInfoText = race != null && race!.isNotEmpty
      ? '$species • $race • Tamaño $size'
      : '$species • Tamaño $size';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 500;
        final bool showTopSection = _hasStatus || isUrgent || showReward;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado + recompensa
            if (showTopSection)
              if (isSmallScreen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (_hasStatus) _buildStatusChip(),
                        if (isUrgent) _buildUrgentChip(),
                      ],
                    ),
                    if ((_hasStatus || isUrgent) && showReward)
                      const SizedBox(height: 8),
                    if (showReward) _buildReward(),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (_hasStatus) _buildStatusChip(),
                        if (isUrgent) _buildUrgentChip(),
                      ],
                    ),
                    if (showReward) _buildReward(),
                  ],
                ),

            if (showTopSection) const SizedBox(height: 8),

            // Nombre + género
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

            // Información secundaria
            Text(
              quickInfoText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        reportStatus!.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: reportStatusTag == 'ACTIVE' ? Colors.redAccent : Colors.teal,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildUrgentChip() {
    return Chip(
      avatar: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: 16,
      ),
      label: const Text(
        'URGENTE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildReward() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(
          color: Colors.amber.shade700,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: Colors.amber.shade800,
            size: 18,
          ),
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
    );
  }
}