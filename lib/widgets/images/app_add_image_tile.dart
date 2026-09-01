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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.shade200, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, color: Colors.teal.shade700, size: 32),
            const SizedBox(height: 6),
            Text(
              '$currentCount/$maxImages',
              style: TextStyle(
                fontSize: 13,
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}