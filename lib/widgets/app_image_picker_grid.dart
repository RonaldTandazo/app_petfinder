import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePickerGrid extends StatelessWidget {
  final List<XFile> images;
  final int maxImages;
  final VoidCallback onAddPressed;
  final ValueChanged<int> onRemovePressed;

  const AppImagePickerGrid({
    super.key,
    required this.images,
    this.maxImages = 5,
    required this.onAddPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length < maxImages ? images.length + 1 : maxImages,
        itemBuilder: (context, index) {
          if (index == images.length && images.length < maxImages) {
            return GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 95,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_rounded, color: Colors.teal.shade700, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${images.length}/$maxImages',
                      style: TextStyle(fontSize: 12, color: Colors.teal.shade800, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          final image = images[index];
          return Stack(
            children: [
              Container(
                width: 95,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(File(image.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 16,
                child: GestureDetector(
                  onTap: () => onRemovePressed(index),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}