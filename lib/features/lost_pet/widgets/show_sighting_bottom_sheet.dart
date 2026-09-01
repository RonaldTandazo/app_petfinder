import 'package:flutter/material.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';

class ShowSightingBottomSheet {
  static Future<void> show(BuildContext context, SightReportModel sight) {
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
            Row(
              children: [
                const Icon(Icons.visibility, color: Colors.teal),
                const SizedBox(width: 8),
                Text('Avistamiento - ${sight.dateText}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Text('Dirección: ${sight.address}', style: const TextStyle(fontSize: 13)),
            if (sight.comment != null) ...[
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