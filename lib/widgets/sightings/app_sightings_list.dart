import 'package:flutter/material.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';
import 'package:app_petfinder/models/pictures/picture_model.dart';
import 'package:app_petfinder/widgets/dialog/app_confirm_dialog.dart';

class AppSightingsList extends StatelessWidget {
  final List<SightReportModel> sightings;
  final int? selectedSightId;
  final int? currentTutorId;
  final ValueChanged<SightReportModel> onSightingSelected;
  final ValueChanged<int> onSightingDeleted;

  const AppSightingsList({
    super.key,
    this.currentTutorId,
    required this.sightings,
    required this.selectedSightId,
    required this.onSightingSelected,
    required this.onSightingDeleted
  });

  void _openFullScreenViewer(BuildContext context, List<PictureModel> pictures) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return AppFullScreenGallery(
          pictures: pictures,
          initialIndex: 0,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, SightReportModel sight) async {
    final bool? confirm = await AppConfirmDialog.show(
      context: context,
      title: 'Eliminar Avistamiento',
      message: 'Esta acción eliminará el reporte de avistamiento. \n¿Desea continuar?'
    );

    if (confirm == true) onSightingDeleted(sight.id);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallPhone = constraints.maxWidth < 360;
        final bool isMobile = constraints.maxWidth < 600;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: sightings.length,
          itemBuilder: (context, index) {
            final SightReportModel sight = sightings[index];

            final bool hasCoordinates =
                sight.latitude != null && sight.longitude != null;

            final bool hasPictures = sight.pictures.isNotEmpty;

            final bool isSelected = selectedSightId == sight.id;

            final bool isOwner = currentTutorId != null &&
                sight.tutorId == currentTutorId;

            final String subtitle =
                sight.comment != null && sight.comment!.isNotEmpty
                    ? '${formatDate(sight.eventDate)} • ${sight.comment}'
                    : formatDate(sight.eventDate);

            final double iconSize = isSmallPhone ? 18 : 20;
            final double actionPadding = isSmallPhone ? 5 : 8;

            final List<Widget> actions = [
              if (hasPictures)
                IconButton(
                  icon: Badge(
                    label: Text('${sight.pictures.length}'),
                    isLabelVisible: sight.pictures.length > 1,
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: iconSize,
                      color: Colors.teal,
                    ),
                  ),
                  tooltip: 'Ver fotos',
                  onPressed: () => _openFullScreenViewer(
                    context,
                    sight.pictures,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.all(actionPadding),
                  visualDensity: VisualDensity.compact,
                ),
              if (hasCoordinates)
                IconButton(
                  icon: Icon(
                    Icons.my_location,
                    size: iconSize,
                    color: Colors.teal,
                  ),
                  tooltip: 'Ver en mapa',
                  onPressed: () => onSightingSelected(sight),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.all(actionPadding),
                  visualDensity: VisualDensity.compact,
                ),
              if (isOwner)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: iconSize,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Eliminar Reporte',
                  onPressed: () => _confirmDelete(context, sight),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.all(actionPadding),
                  visualDensity: VisualDensity.compact,
                ),
            ];

            return Card(
              margin: EdgeInsets.only(
                bottom: isSmallPhone ? 8 : 10,
              ),
              elevation: isSelected ? 3 : 1,
              color: isSelected ? Colors.teal.shade50 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? Colors.teal
                      : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSightingSelected(sight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallPhone ? 8 : 10,
                    vertical: isSmallPhone ? 8 : 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: isSmallPhone ? 17 : 20,
                        backgroundColor: isSelected
                            ? Colors.teal
                            : Colors.grey.shade200,
                        child: Icon(
                          hasCoordinates
                              ? Icons.remove_red_eye
                              : Icons.location_off,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          size: iconSize,
                        ),
                      ),
                      SizedBox(width: isSmallPhone ? 8 : 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sight.eventAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallPhone ? 12 : 13,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: isMobile ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isSmallPhone ? 10 : 12,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),

                            if (isMobile && actions.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 2,
                                  runSpacing: 0,
                                  children: actions,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (!isMobile && actions.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}