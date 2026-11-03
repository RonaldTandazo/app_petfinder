import 'package:flutter/material.dart';
import 'package:app_petfinder/enums/badge/badge_position.dart';
import 'package:app_petfinder/core/helpers/color_helper.dart';
import 'package:app_petfinder/enums/status/status_type.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final StatusType type;
  final BadgePosition position;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.text,
    this.icon,
    this.type = StatusType.warning,
    this.position = BadgePosition.topLeft,
    this.fontSize = 11,
    this.iconSize = 14,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeColors = getSemanticColors(colorScheme, type);

    final bool isTop = [BadgePosition.topLeft, BadgePosition.topRight].contains(position);
    final bool isLeft = [BadgePosition.topLeft, BadgePosition.bottomLeft].contains(position);

    final double verticalOffset = 12;
    final double horizontalOffset = 12;

    return Positioned(
      top: isTop ? verticalOffset : null,
      bottom: !isTop ? verticalOffset : null,
      left: isLeft ? horizontalOffset : null,
      right: !isLeft ? horizontalOffset : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: badgeColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: badgeColors.foreground,
                size: iconSize,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: badgeColors.foreground,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}