import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  static const Distance _distanceCalculator = Distance();

  static Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  static String calculateFormattedDistance({
    required LatLng userLocation,
    required double targetLat,
    required double targetLng,
  }) {
    final double distanceInMeters = _distanceCalculator.as(
      LengthUnit.Meter,
      userLocation,
      LatLng(targetLat, targetLng),
    );

    if (distanceInMeters < 1000) {
      return 'A ${distanceInMeters.round()} m';
    } else {
      final double distanceInKm = distanceInMeters / 1000;
      return 'A ${distanceInKm.toStringAsFixed(1)} km';
    }
  }
}