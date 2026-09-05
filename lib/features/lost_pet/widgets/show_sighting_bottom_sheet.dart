import 'package:app_petfinder/widgets/images/app_full_screen_gallery.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';
import 'package:app_petfinder/core/utils/common_helpers.dart';

class ShowSightingBottomSheet {
  static void _openFullScreenViewer(BuildContext context, List<String> pictures, int initialIndex) {
    showDialog(
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

  static Future<void> show(BuildContext context, SightReportModel sight) {
    final bool hasPictures = sight.pictures.isNotEmpty;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.visibility, color: Colors.teal),
                const SizedBox(width: 8),
                Text('Avistamiento - ${formatDate(sight.eventDate)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(),

            if (hasPictures) ...[
              const Text('Fotografías adjuntas:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sight.pictures.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final photoUrl = sight.pictures[index];
                    return GestureDetector(
                      onTap: () => _openFullScreenViewer(context, sight.pictures, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          photoUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            Text('Dirección: ${sight.eventAddress}', style: const TextStyle(fontSize: 13)),
            if (sight.comment != null && sight.comment!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Comentario: ${sight.comment}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}