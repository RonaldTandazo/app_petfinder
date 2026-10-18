import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImageTile extends StatelessWidget {
  final XFile? image;
  final String? url;
  final bool isMain;
  final bool enableMainSelection;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  const AppImageTile({
    super.key,
    required this.image,
    required this.url,
    required this.isMain,
    required this.enableMainSelection,
    required this.onTap,
    required this.onRemove,
  });

  Widget _buildImage() {
    if (image != null) {
      return Image.file(
        File(image!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }

          return _loadingImage();
        },
        errorBuilder: (context, error, stackTrace) {
          return _errorImage();
        },
      );
    }

    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: Colors.teal.shade50,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.teal.shade600,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _errorImage();
        },
      );
    }

    return _errorImage();
  }

  Widget _loadingImage() {
    return Container(
      color: Colors.teal.shade50,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.teal.shade600,
          ),
        ),
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.broken_image_rounded,
        color: Colors.grey,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isTablet = screenWidth >= 600;

    final tileWidth = isSmallPhone
        ? 105.0
        : isTablet
            ? 150.0
            : 130.0;

    final iconSize = isSmallPhone ? 14.0 : 16.0;
    final iconPadding = isSmallPhone ? 4.0 : 5.0;
    final badgeFontSize = isSmallPhone ? 9.0 : 10.0;
    final borderRadius = isSmallPhone ? 12.0 : 16.0;
    final badgeBottom = isSmallPhone ? 6.0 : 8.0;

    return SizedBox(
      width: tileWidth,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: isMain
                    ? Border.all(
                        color: Colors.teal.shade600,
                        width: 3,
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  borderRadius - 2,
                ),
                child: _buildImage(),
              ),
            ),

            if (enableMainSelection)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: isMain
                        ? Colors.teal.shade600
                        : Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMain
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),

            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(iconPadding),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ),

            if (isMain)
              Positioned(
                bottom: badgeBottom,
                left: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Principal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}