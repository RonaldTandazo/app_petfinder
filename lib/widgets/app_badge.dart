import 'package:flutter/material.dart';

enum BadgeType {
  error,
  information,
  success,
  warning,
}

enum BadgePosition {
  topLeft,
  topRight,
}

class AppBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final BadgeType type;
  final BadgePosition position;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.text,
    this.icon,
    this.type = BadgeType.warning,
    this.position = BadgePosition.topLeft,
    this.fontSize = 11,
    this.iconSize = 14,
    this.padding,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.error:
        return Colors.red.shade700;
      case BadgeType.warning:
        return Colors.amber.shade900;
      case BadgeType.information:
        return Colors.blue.shade800;
      case BadgeType.success:
        return Colors.teal.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topOffset = 12;
    final double horizontalOffset = 12;

    return Positioned(
      top: topOffset,
      left: position == BadgePosition.topLeft ? horizontalOffset : null,
      right: position == BadgePosition.topRight ? horizontalOffset : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
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
                color: Colors.white,
                size: iconSize,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
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