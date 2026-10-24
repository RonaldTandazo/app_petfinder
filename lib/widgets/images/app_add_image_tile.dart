import 'package:flutter/material.dart';

class AppAddImageTile extends StatelessWidget {
  final int currentCount;
  final int maxImages;
  final VoidCallback onTap;

  const AppAddImageTile({
    super.key,
    required this.currentCount,
    required this.maxImages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final double tileWidth = isSmallPhone
        ? 105.0
        : isTablet
            ? 150.0
            : 130.0;

    final double iconSize = isSmallPhone
        ? 26.0
        : isTablet
            ? 36.0
            : 32.0;

    final double counterFontSize = isSmallPhone ? 12.0 : 13.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: tileWidth,
          decoration: BoxDecoration(
            color: Colors.teal.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.teal.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                color: Colors.teal.shade700,
                size: iconSize,
              ),
              const SizedBox(height: 6),
              Text(
                '$currentCount/$maxImages',
                style: TextStyle(
                  fontSize: counterFontSize,
                  color: Colors.teal.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}