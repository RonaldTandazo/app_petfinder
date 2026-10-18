import 'package:flutter/material.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/models/pictures/picture_model.dart';
import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';

class ShowSightingBottomSheet {
  static void _openFullScreenViewer(
    BuildContext context,
    List<PictureModel> pictures,
    int initialIndex,
  ) {
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) {
        return AppFullScreenGallery(
          pictures: pictures,
          initialIndex: initialIndex,
        );
      },
    );
  }

  static Future<void> show(
    BuildContext context,
    SightReportModel sight,
  ) {
    final bool hasPictures = sight.pictures.isNotEmpty;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (modalContext) {
        final screenSize = MediaQuery.sizeOf(modalContext);
        final bool isSmallPhone = screenSize.width < 360;
        final bool isMobile = screenSize.width < 600;

        final horizontalPadding = isSmallPhone ? 12.0 : 16.0;
        final titleFontSize = isSmallPhone ? 14.0 : 16.0;
        final bodyFontSize = isSmallPhone ? 12.0 : 13.0;
        final photoSize = isSmallPhone ? 76.0 : 90.0;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador superior
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título y fecha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.teal,
                      size: isSmallPhone ? 20 : 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Avistamiento - ${formatDate(sight.eventDate)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Fotografías
                if (hasPictures) ...[
                  Text(
                    'Fotografías adjuntas:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: photoSize,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sight.pictures.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final photoUrl = sight.pictures[index].url;

                        return GestureDetector(
                          onTap: () => _openFullScreenViewer(
                            context,
                            sight.pictures,
                            index,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              photoUrl,
                              width: photoSize,
                              height: photoSize,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  width: photoSize,
                                  height: photoSize,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Dirección
                _buildInfo(
                  label: 'Dirección',
                  value: sight.eventAddress,
                  fontSize: bodyFontSize,
                ),

                // Comentario
                if (sight.comment != null &&
                    sight.comment!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfo(
                    label: 'Comentario',
                    value: sight.comment!.trim(),
                    fontSize: bodyFontSize,
                  ),
                ],

                SizedBox(height: isMobile ? 12 : 20),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildInfo({
    required String label,
    required String value,
    required double fontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.4,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
