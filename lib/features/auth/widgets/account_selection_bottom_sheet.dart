import 'package:flutter/material.dart';
import 'package:app_petfinder/core/helpers/color_helper.dart';
import 'package:app_petfinder/enums/status/status_type.dart';

class AccountSelectionBottomSheet {
  static Future<String?> show(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
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
              'Selecciona Perfil',
              style: Theme.of(modalContext).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: _buildAvatar(
                colorScheme,
                Icons.person,
                StatusType.success,
              ),
              title: const Text('Personal'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pop(modalContext, 'user'),
            ),
            Divider(color: colorScheme.outlineVariant),
            ListTile(
              leading: _buildAvatar(
                colorScheme,
                Icons.pets,
                StatusType.information,
              ),
              title: const Text('Refugio / Fundación'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pop(modalContext, 'shelter'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _buildAvatar(
    ColorScheme colorScheme,
    IconData icon,
    StatusType type,
  ) {
    final colors = getSemanticColors(colorScheme, type);

    return CircleAvatar(
      backgroundColor: colors.background,
      child: Icon(
        icon,
        color: colors.foreground,
      ),
    );
  }
}