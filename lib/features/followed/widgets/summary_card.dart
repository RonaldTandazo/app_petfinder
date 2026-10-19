import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmall = width < 100;
        final bool isCompact = width < 125;

        final double horizontalPadding = isSmall ? 4 : 8;
        final double verticalPadding = isSmall ? 10 : 14;
        final double iconSize = isSmall ? 18 : isCompact ? 20 : 22;
        final double countFontSize = isSmall ? 18 : isCompact ? 20 : 24;
        final double titleFontSize = isSmall ? 10 : 12;
        final double spacing = isSmall ? 5 : 8;

        return Material(
          color: selected
              ? color.withValues(alpha: 0.10)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? color
                      : colorScheme.outlineVariant,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),

                  SizedBox(height: spacing),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count',
                      maxLines: 1,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: countFontSize,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: titleFontSize,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}