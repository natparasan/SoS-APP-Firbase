import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles fetching the user's current GPS location, requesting
/// the required permissions, and producing a Google Maps link
/// that can be shared inside an SOS message.
class LocationService {
  /// Requests location permission if not already granted.
  /// Returns true if permission is granted.
  Future<bool> ensurePermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) return true;

    final result = await Permission.location.request();
    return result.isGranted;
  }

  /// Returns the current [Position], or null if location services
  /// are disabled or permission was denied.
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Builds a Google Maps URL from a [Position].
  String mapsLinkFor(Position position) {
    return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  }
}
