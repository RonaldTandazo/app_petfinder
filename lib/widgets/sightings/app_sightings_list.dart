import 'package:app_petfinder/core/utils/common_helpers.dart';
import 'package:app_petfinder/core/utils/session_info.dart';
import 'package:flutter/material.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';

class AppSightingsList extends StatelessWidget {
  final List<SightReportModel> sightings;
  final int? selectedSightId;
  final ValueChanged<SightReportModel> onSightingSelected;
  final ValueChanged<int> onSightingDeleted;

  const AppSightingsList({
    super.key,
    required this.sightings,
    required this.selectedSightId,
    required this.onSightingSelected,
    required this.onSightingDeleted
  });

  void _confirmDelete(BuildContext context, SightReportModel sight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar avistamiento?'),
        content: const Text('Esta acción quitará el reporte de avistamiento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              onSightingDeleted(sight.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? currentTutorId = SessionInfo.tutorId;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sightings.length,
      itemBuilder: (context, index) {
        final SightReportModel sight = sightings[index];
        
        final bool hasCoordinates = sight.latitude != null && sight.longitude != null;
        
        final bool isSelected = selectedSightId == sight.id;

        final bool isOwner = currentTutorId != null && sight.tutorId == currentTutorId;
        
        final String subtitle = sight.comment != null && sight.comment!.isNotEmpty
            ? '${formatDate(sight.eventDate)} • ${sight.comment}'
            : formatDate(sight.eventDate);

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
                hasCoordinates ? Icons.remove_red_eye : Icons.location_off,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 20,
              ),
            ),
            title: Text(sight.eventAddress, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
           trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono para enfocar/seleccionar en mapa
                IconButton(
                  icon: const Icon(Icons.my_location, size: 18, color: Colors.teal),
                  onPressed: () => onSightingSelected(sight),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                // Botón de eliminar visible ÚNICAMENTE si es el creador del reporte
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, sight),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
              ],
            ),
            onTap: () => onSightingSelected(sight),
          ),
        );
      },
    );
  }
}