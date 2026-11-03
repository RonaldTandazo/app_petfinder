import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/locations/app_location_picker.dart';
import 'package:latlong2/latlong.dart';

class AppLocationPickerTile extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final ValueChanged<LatLng> onLocationSelected;
  final bool isRequired;
  final String title;
  final String? customHint;

  const AppLocationPickerTile({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onLocationSelected,
    this.isRequired = false,
    this.title = 'Marcar ubicación en el mapa',
    this.customHint,
  });

  bool get _hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color backgroundColor = _hasLocation
      ? colorScheme.primaryContainer
      : colorScheme.surfaceContainer;

    final Color foregroundColor = _hasLocation
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final Color borderColor = _hasLocation
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final String labelTag = isRequired ? '*' : '(Opcional)';
    final String defaultHint = _hasLocation
        ? 'Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}'
        : (customHint ?? 'Abre el mapa para seleccionar un punto');

    return InkWell(
      onTap: () async {
        final LatLng? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppLocationPicker(
              initialPosition: _hasLocation
                  ? LatLng(latitude!, longitude!)
                  : null,
            ),
          ),
        );

        if (result != null) {
          onLocationSelected(result);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              _hasLocation ? Icons.pin_drop_rounded : Icons.map_rounded,
              color: _hasLocation ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasLocation
                        ? 'Punto de referencia marcado'
                        : '$title $labelTag',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: foregroundColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    defaultHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}