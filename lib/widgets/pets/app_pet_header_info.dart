import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';

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
    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    final bool showReward = hasReward && (rewardAmount ?? 0) > 0;

    final String quickInfoText = race != null && race!.isNotEmpty
      ? '$species • $race • Tamaño $size'
      : '$species • Tamaño $size';

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isSmallPhone = width < 360;
        final bool isMobile = width < 600;

        final double nameFontSize = isSmallPhone
          ? 21
          : isMobile
            ? 23
            : 26;

        final double genderIconSize = isSmallPhone ? 22 : 26;
        final double infoFontSize = isSmallPhone ? 12 : 14;
        final double chipSpacing = isSmallPhone ? 5 : 8;
        final double sectionSpacing = isSmallPhone ? 6 : 8;

        final bool showTopSection = _hasStatus || isUrgent || showReward;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado + urgencia + recompensa
            if (showTopSection) ...[
              Wrap(
                spacing: chipSpacing,
                runSpacing: chipSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (_hasStatus)
                    _buildStatusChip(isSmallPhone: isSmallPhone),
                  if (isUrgent)
                    _buildUrgentChip(isSmallPhone: isSmallPhone),
                  if (showReward)
                    _buildReward(isSmallPhone: isSmallPhone),
                ],
              ),
              SizedBox(height: sectionSpacing + 2),
            ],

            // Nombre + género
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(width: isSmallPhone ? 5 : 8),
                Icon(
                  genderIcon,
                  size: genderIconSize,
                  color: genderColor,
                ),
              ],
            ),

            SizedBox(height: isSmallPhone ? 3 : 4),

            // Información secundaria
            Text(
              quickInfoText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: infoFontSize,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip({bool isSmallPhone = false}) {
    return Chip(
      label: Text(
        reportStatus!.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmallPhone ? 9 : 11,
        ),
      ),
      backgroundColor: reportStatusTag == 'ACTIVE'
        ? Colors.redAccent
        : Colors.teal,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 2 : 4,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 4 : 6,
      ),
    );
  }

  Widget _buildUrgentChip({bool isSmallPhone = false}) {
    return Chip(
      avatar: Icon(
        Icons.warning_amber_rounded,
        color: Colors.white,
        size: isSmallPhone ? 13 : 16,
      ),
      label: Text(
        'URGENTE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmallPhone ? 9 : 11,
        ),
      ),
      backgroundColor: Colors.deepOrangeAccent,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.only(
        right: isSmallPhone ? 4 : 6,
      ),
    );
  }

  Widget _buildReward({bool isSmallPhone = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 4 : 6,
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
            size: isSmallPhone ? 15 : 18,
          ),

          SizedBox(width: isSmallPhone ? 3 : 4),

          Text(
            'Recompensa: \$${rewardAmount!.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
              fontSize: isSmallPhone ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}