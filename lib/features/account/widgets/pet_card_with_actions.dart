import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/enums/badge/badge_position.dart';
import 'package:app_petfinder/widgets/badges/app_badge.dart';
import 'package:app_petfinder/widgets/images/app_image_placeholders.dart';

class PetCardWithActions extends StatelessWidget {
  final String title;
  final String? picture;
  final String badgeLabel;
  final Color badgeColor;
  final IconData iconData;
  final String statusActionLabel;
  final bool showActions;
  final bool isUrgent;
  final String? genderTag;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatusChange;

  const PetCardWithActions({
    super.key,
    required this.title,
    this.picture,
    required this.badgeLabel,
    required this.badgeColor,
    required this.iconData,
    this.statusActionLabel = 'Marcar como Adoptada',
    this.showActions = true,
    this.isUrgent = false,
    this.genderTag,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isSmallPhone = screenWidth < 360;
    final bool isMobile = screenWidth < 600;

    final bool isMale = genderTag == 'MALE';
    final bool hasPicture = picture != null && picture!.trim().isNotEmpty;

    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    final double cardRadius = isMobile ? 10 : 12;
    final double contentPadding = isSmallPhone ? 6 : isMobile ? 7 : 8;
    final double badgeFontSize = isSmallPhone ? 9 : 10;
    final double titleFontSize = isSmallPhone ? 12 : isMobile ? 13 : 14;
    final double genderIconSize = isSmallPhone ? 14 : 16;
    final double menuRadius = isSmallPhone ? 14 : 16;
    final double menuIconSize = isSmallPhone ? 16 : 18;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPicture)
                    Image.network(
                      picture!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: isSmallPhone ? 28 : 36,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No se pudo obtener\nla imagen',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallPhone ? 9 : 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    AppImagePlaceholders.card(
                      icon: iconData,
                      message: 'Sin imagen disponible',
                    ),

                  if (isUrgent)
                    AppBadge(
                      text: 'URGENTE',
                      icon: Icons.warning_amber_rounded,
                      position: BadgePosition.topLeft,
                      fontSize: isSmallPhone ? 8 : 9,
                      iconSize: isSmallPhone ? 10 : 12,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallPhone ? 5 : 8,
                        vertical: isSmallPhone ? 3 : 4,
                      ),
                    ),

                  if (showActions)
                    Positioned(
                      top: isSmallPhone ? 3 : 4,
                      right: isSmallPhone ? 3 : 4,
                      child: CircleAvatar(
                        radius: menuRadius,
                        backgroundColor: Colors.black.withAlpha(100),
                        child: PopupMenuButton<String>(
                          tooltip: 'Acciones',
                          padding: EdgeInsets.zero,
                          iconSize: menuIconSize,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'status':
                                onStatusChange();
                                break;
                              case 'edit':
                                onEdit();
                                break;
                              case 'delete':
                                onDelete();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'status',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(statusActionLabel),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Información de la tarjeta
            Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 4 : 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallPhone ? 3 : 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallPhone ? 2 : 4),
                      Icon(
                        genderIcon,
                        size: genderIconSize,
                        color: genderColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}