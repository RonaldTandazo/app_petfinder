import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePickerBottomSheet {
  static Future<ImageSource?> show(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return showModalBottomSheet<ImageSource>(
      backgroundColor: colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Seleccionar Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: colorScheme.primary),
              title: Text(
                'Tomar foto con la Cámara',
                style: TextStyle(color: colorScheme.onSurface)
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            
            Divider(color: colorScheme.outlineVariant),
            
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: colorScheme.primary),
              title: Text(
                'Elegir de la Galería',
                style: TextStyle(color: colorScheme.onSurface)
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}