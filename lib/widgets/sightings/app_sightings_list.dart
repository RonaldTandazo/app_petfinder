import 'package:flutter/material.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';

class AppSightingsList extends StatelessWidget {
  final List<SightReportModel> sightings;
  final int? selectedSightId;
  final ValueChanged<SightReportModel> onSightingSelected;

  const AppSightingsList({
    super.key,
    required this.sightings,
    required this.selectedSightId,
    required this.onSightingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sightings.length,
      itemBuilder: (context, index) {
        final sight = sightings[index];
        final isSelected = selectedSightId == sight.id;

        return Card(
          elevation: isSelected ? 3 : 1,
          color: isSelected ? Colors.teal.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.teal : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.teal : Colors.grey.shade200,
              child: Icon(
                Icons.remove_red_eye,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
            title: Text(sight.address, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(
              '${sight.dateText}${sight.comment != null ? ' • ${sight.comment}' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.my_location, size: 18, color: Colors.teal),
            onTap: () => onSightingSelected(sight),
          ),
        );
      },
    );
  }
}