import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AppImageTile extends StatelessWidget {
  final XFile image;
  final bool isMain;
  final bool enableMainSelection;
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  const AppImageTile({
    required this.image,
    required this.isMain,
    required this.enableMainSelection,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  border: isMain
                      ? Border.all(color: Colors.teal.shade600, width: 3)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
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
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          if (enableMainSelection)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isMain ? Colors.teal.shade600 : Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMain ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          Positioned(
            top: 6,
            right: 18,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),

          if (isMain)
            Positioned(
              bottom: 8,
              left: 6,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.shade600.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Principal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}