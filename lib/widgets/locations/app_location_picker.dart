import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_petfinder/enums/status/status_type.dart';
import 'package:app_petfinder/widgets/snackbars/app_snackbar.dart';
import 'package:app_petfinder/core/services/location_service.dart';
import 'package:app_petfinder/core/helpers/number_helper.dart';

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
      AppSnackBar.show(
        context,
        type: StatusType.error,
        title: 'No se pudo obtener la ubicación. Verifica los permisos de GPS.'
      );
    }

    setState(() => _isLocating = false);
  }

  LatLng _formatLatLng(LatLng point) {
    return LatLng(
      truncateDecimals(point.latitude, 8),
      truncateDecimals(point.longitude, 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fija la ubicación',
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: _isInitializing
              ? null 
              : () {
                final LatLng result = _formatLatLng(_selectedLatLng);
                Navigator.pop(context, result);
              },
            child: Text(
              'Confirmar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
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
              child: Icon(
                Icons.location_on_rounded,
                size: 45,
                color: Colors.redAccent,
              ),
            ),
          ),

          // Indicador de carga inicial si está obteniendo el GPS por primera vez
          if (_isInitializing)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  color: colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Obteniendo Ubicación...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onPressed: (_isLocating || _isInitializing)
                ? null
                : _fetchCurrentLocation,
              child: _isLocating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}