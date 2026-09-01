import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/models/lost_pet/sight_report_model.dart';

class AppTrackingMap extends StatelessWidget {
  final double? mainLatitude;
  final double? mainLongitude;
  final List<SightReportModel> sightings;
  final int? selectedSightId;
  final MapController mapController;
  final ValueChanged<SightReportModel> onSightTap;

  const AppTrackingMap({
    super.key,
    this.mainLatitude,
    this.mainLongitude,
    required this.sightings,
    required this.selectedSightId,
    required this.mapController,
    required this.onSightTap,
  });

  @override
  Widget build(BuildContext context) {
    final double initialLat = mainLatitude ?? -2.1894;
    final double initialLng = mainLongitude ?? -79.8891;

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(initialLat, initialLng),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.app.petfinder',
            ),
            MarkerLayer(
              markers: [
                if (mainLatitude != null && mainLongitude != null)
                  Marker(
                    point: LatLng(mainLatitude!, mainLongitude!),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ...sightings.map((sight) {
                  final isSelected = selectedSightId == sight.id;
                  return Marker(
                    point: LatLng(sight.latitude, sight.longitude),
                    width: isSelected ? 48 : 36,
                    height: isSelected ? 48 : 36,
                    child: GestureDetector(
                      onTap: () => onSightTap(sight),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.visibility,
                          color: isSelected ? Colors.orange.shade800 : Colors.teal,
                          size: isSelected ? 40 : 28,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}