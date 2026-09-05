import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AppLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final MapController mapController;

  const AppLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.mapController,
  });

  @override
  State<AppLocationMap> createState() => _AppLocationMapState();
}

class _AppLocationMapState extends State<AppLocationMap> {
  bool _isMoved = false;

  void _recenterMap() {
    final LatLng point = LatLng(widget.latitude, widget.longitude);
    widget.mapController.move(point, 14.0);
    setState(() {
      _isMoved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(widget.latitude, widget.longitude);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: point,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && !_isMoved) {
                    setState(() {
                      _isMoved = true;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.app.petfinder',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (_isMoved)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'recenter_map_btn',
                  onPressed: _recenterMap,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text(
                    'Centrar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}