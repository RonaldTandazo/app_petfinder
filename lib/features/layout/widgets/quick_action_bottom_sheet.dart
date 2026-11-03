import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:app_petfinder/core/helpers/color_helper.dart';

class QuickActionBottomSheet {
  static Future<void> show(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final double horizontalPadding = isSmallPhone
      ? 12
      : isMobile
          ? 16
          : 24;

    final double verticalPadding = isSmallPhone ? 12 : 20;
    final double titleFontSize = isSmallPhone ? 16 : 18;
    final double iconRadius = isSmallPhone ? 20 : 24;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (modalContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              isSmallPhone ? 8 : 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(
                    bottom: isSmallPhone ? 12 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Text(
                  '¿Qué deseas publicar?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: isSmallPhone ? 8 : 16),

                _buildActionTile(
                  context: modalContext,
                  icon: Icons.pets,
                  type: StatusType.success,
                  title: 'Dar en Adopción',
                  subtitle: 'Publica una mascota que busca hogar',
                  iconRadius: iconRadius,
                  isSmallPhone: isSmallPhone,
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    context.push(AdoptionRoutes.publish);
                  },
                ),

                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant,
                ),

                _buildActionTile(
                  context: modalContext,
                  icon: Icons.warning_amber_rounded,
                  type: StatusType.error,
                  title: 'Reportar Mascota Perdida',
                  subtitle: 'Avisa a la comunidad sobre un animal extraviado',
                  iconRadius: iconRadius,
                  isSmallPhone: isSmallPhone,
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    context.push(LostPetRoutes.publish);
                  },
                ),

                SizedBox(height: isSmallPhone ? 4 : 12),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required StatusType type,
    required String title,
    required String subtitle,
    required double iconRadius,
    required bool isSmallPhone,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final colors = getSemanticColors(colorScheme, type);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 2 : 8,
        vertical: isSmallPhone ? 2 : 4,
      ),
      minLeadingWidth: iconRadius * 2,
      leading: CircleAvatar(
        radius: iconRadius,
        backgroundColor: colors.background,
        child: Icon(
          icon,
          color: colors.foreground,
          size: isSmallPhone ? 20 : 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: isSmallPhone ? 14 : 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: isSmallPhone ? 11 : 13,
          height: 1.25,
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmallPhone ? 14 : 16,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}