import 'package:app_petfinder/core/helpers/color_helper.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/core/helpers/gender_helper.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    _buildStatusChip(colorScheme: colorScheme, isSmallPhone: isSmallPhone),
                  if (isUrgent)
                    _buildUrgentChip(colorScheme: colorScheme, isSmallPhone: isSmallPhone),
                  if (showReward)
                    _buildReward(colorScheme: colorScheme, isSmallPhone: isSmallPhone),
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
                      color: colorScheme.onSurface
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
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip({required ColorScheme colorScheme, bool isSmallPhone = false}) {
    final StatusType type = reportStatusTag == 'ACTIVE' ? StatusType.error : StatusType.information;
    final colors = getSemanticColors(colorScheme, type);

    return Chip(
      label: Text(
        reportStatus!.toUpperCase(),
        style: TextStyle(
          color: colors.foreground,
          fontWeight: FontWeight.bold,
          fontSize: isSmallPhone ? 9 : 11,
        ),
      ),
      backgroundColor: colors.background,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 2 : 4,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 4 : 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colors.background,
        ),
      ),
    );
  }

  Widget _buildUrgentChip({required ColorScheme colorScheme, bool isSmallPhone = false}) {
    final colors = getSemanticColors(colorScheme, StatusType.warning);

    return Chip(
      avatar: Icon(
        Icons.warning_amber_rounded,
        color: colors.foreground,
        size: isSmallPhone ? 13 : 16,
      ),
      label: Text(
        'URGENTE',
        style: TextStyle(
          color: colors.foreground,
          fontWeight: FontWeight.bold,
          fontSize: isSmallPhone ? 9 : 11,
        ),
      ),
      backgroundColor: colors.background,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 2 : 4,
      ),
      labelPadding: EdgeInsets.only(
        right: isSmallPhone ? 4 : 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: colors.background,
        ),
      ),
    );
  }

  Widget _buildReward({required ColorScheme colorScheme, bool isSmallPhone = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 12,
        vertical: isSmallPhone ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.25),
        border: Border.all(
          color: colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: colorScheme.tertiary,
            size: isSmallPhone ? 15 : 18,
          ),

          SizedBox(width: isSmallPhone ? 3 : 4),

          Text(
            'Recompensa: \$${rewardAmount!.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.tertiary,
              fontWeight: FontWeight.bold,
              fontSize: isSmallPhone ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}