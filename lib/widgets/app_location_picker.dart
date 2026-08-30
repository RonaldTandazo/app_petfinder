import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/core/services/location_service.dart';

class AppLocationPicker extends StatefulWidget {
  final LatLng? initialPosition;

  const AppLocationPicker({super.key, this.initialPosition});

  @override
  State<AppLocationPicker> createState() => _AppLocationPickerState();
}

class _AppLocationPickerState extends State<AppLocationPicker> {
  late MapController _mapController;
  
  static const LatLng _defaultFallbackLatLng = LatLng(-2.1894, -79.8891);
  
  LatLng _selectedLatLng = _defaultFallbackLatLng;
  bool _isInitializing = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initPosition();
  }

  Future<void> _initPosition() async {
    if (widget.initialPosition != null) {
      _selectedLatLng = widget.initialPosition!;
      return;
    }

    setState(() => _isInitializing = true);

    final userLatLng = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (userLatLng != null) {
      setState(() {
        _selectedLatLng = userLatLng;
      });
      _mapController.move(userLatLng, 16.0);
    }

    setState(() => _isInitializing = false);
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLocating = true);

    final userLatLng = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (userLatLng != null) {
      setState(() {
        _selectedLatLng = userLatLng;
      });
      _mapController.move(userLatLng, 16.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la ubicación. Verifica los permisos de GPS.'),
        ),
      );
    }

    setState(() => _isLocating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mueve el mapa para fijar el punto', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _isInitializing ? null : () => Navigator.pop(context, _selectedLatLng),
            child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _selectedLatLng = position.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_petfinder',
              ),
            ],
          ),

          // Pin Fijo en el centro de la pantalla
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Icon(Icons.location_on_rounded, size: 45, color: Colors.redAccent),
            ),
          ),

          // Indicador de carga inicial si está obteniendo el GPS por primera vez
          if (_isInitializing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Obteniendo ubicación...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Botón GPS Ubicación Actual
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: (_isLocating || _isInitializing) ? null : _fetchCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.my_location, color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }
}