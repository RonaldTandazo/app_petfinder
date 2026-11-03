import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  final String? title;
  final String description;
  final IconData icon;

  const AppEmptyState({
    super.key,
    this.title,
    this.description = 'No hay información disponible',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final bool isSmallPhone = width < 360;
        final bool isCompact = width < 400 || height < 300;

        final double iconSize = isSmallPhone
            ? 44
            : isCompact
                ? 52
                : 64;

        final double titleFontSize = isCompact ? 16 : 18;
        final double descriptionFontSize = isCompact ? 12 : 14;
        final double horizontalPadding = isSmallPhone ? 12 : 24;
        final double verticalPadding = isCompact ? 16 : 24;

        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: isCompact ? 8 : 12),
                if (title != null && title!.trim().isNotEmpty) ...[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}