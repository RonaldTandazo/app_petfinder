import 'package:flutter/material.dart';

class MetricItem extends StatelessWidget {
  final String label;
  final String count;
  final VoidCallback onTap;

  const MetricItem({
    super.key, 
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final double horizontalPadding = isSmallPhone
        ? 2
        : isMobile
            ? 4
            : 12;

    final double countFontSize = isSmallPhone
        ? 19
        : isMobile
            ? 21
            : 23;

    final double labelFontSize = isSmallPhone
        ? 10
        : isMobile
            ? 11
            : 12;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmallPhone ? 3 : 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: countFontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              SizedBox(height: isSmallPhone ? 1 : 2),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: labelFontSize,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
              ),
            ],
          ),
        ),
      )
    );
  }
}