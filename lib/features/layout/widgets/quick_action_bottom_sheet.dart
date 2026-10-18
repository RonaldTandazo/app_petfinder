import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/core/router/adoption/adoption_routes.dart';
import 'package:app_petfinder/core/router/lost_pet/lost_pet_routes.dart';

class QuickActionBottomSheet {
  static Future<void> show(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isSmallPhone = screenSize.width < 360;
    final bool isMobile = screenSize.width < 600;

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
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Text(
                  '¿Qué deseas publicar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: isSmallPhone ? 8 : 16),

                _buildActionTile(
                  icon: Icons.pets,
                  iconColor: Colors.teal,
                  title: 'Dar en Adopción',
                  subtitle: 'Publica una mascota que busca hogar',
                  iconRadius: iconRadius,
                  isSmallPhone: isSmallPhone,
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    context.push(AdoptionRoutes.publish);
                  },
                ),

                const Divider(height: 1),

                _buildActionTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Reportar Mascota Perdida',
                  subtitle:
                      'Avisa a la comunidad sobre un animal extraviado',
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double iconRadius,
    required bool isSmallPhone,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 2 : 8,
        vertical: isSmallPhone ? 2 : 4,
      ),
      minLeadingWidth: iconRadius * 2,
      leading: CircleAvatar(
        radius: iconRadius,
        backgroundColor: iconColor,
        child: Icon(
          icon,
          color: Colors.white,
          size: isSmallPhone ? 20 : 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmallPhone ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: isSmallPhone ? 11 : 13,
          height: 1.25,
          color: Colors.grey.shade600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: isSmallPhone ? 14 : 16,
        color: Colors.grey.shade600,
      ),
      onTap: onTap,
    );
  }
}