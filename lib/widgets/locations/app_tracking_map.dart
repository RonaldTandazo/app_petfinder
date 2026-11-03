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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double initialLat = mainLatitude ?? -2.1894;
    final double initialLng = mainLongitude ?? -79.8891;

    final validSightings = sightings.where(
      (sight) => sight.latitude != null && sight.longitude != null,
    );

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
                ...validSightings.map((sight) {
                  final bool isSelected = selectedSightId == sight.id;
                  final double lat = sight.latitude!;
                  final double lng = sight.longitude!;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: isSelected ? 48 : 36,
                    height: isSelected ? 48 : 36,
                    child: GestureDetector(
                      onTap: () => onSightTap(sight),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.visibility,
                          color: isSelected ? colorScheme.secondary : colorScheme.primary,
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