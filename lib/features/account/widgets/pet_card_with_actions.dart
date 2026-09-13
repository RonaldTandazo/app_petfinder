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
    final bool isMale = genderTag == 'MALE';
    final bool hasPicture = picture != null && picture!.trim().isNotEmpty;
    final IconData genderIcon = getGenderIcon(isMale);
    final Color genderColor = getGenderColor(isMale);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hasPicture
                        ? Image.network(
                            picture!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey[400]),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No se pudo obtener\nla imagen',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : AppImagePlaceholders.card(
                            icon: iconData,
                            message: 'Sin imagen disponible',
                          ),
                  ),

                  // Badge flotante de Urgente (esquina superior izquierda)
                  if (isUrgent)
                    const AppBadge(
                      text: 'URGENTE',
                      icon: Icons.warning_amber_rounded,
                      position: BadgePosition.topLeft,
                      fontSize: 9,
                      iconSize: 12,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),

                  // Menú de acciones (esquina superior derecha)
                  if (showActions)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black.withAlpha(100),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.white),
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
                                    const Icon(Icons.check_circle_outline, size: 20),
                                    const SizedBox(width: 8),
                                    Text(statusActionLabel),
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
                                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Información de la tarjeta
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        genderIcon,
                        size: 16,
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