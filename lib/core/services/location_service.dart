import 'dart:async';

import 'package:dart_geohash/dart_geohash.dart';
import 'package:geolocator/geolocator.dart';

import 'logger_service.dart';

class LocationCapture {
  const LocationCapture({
    required this.latitude,
    required this.longitude,
    required this.geohash,
  });

  final double latitude;
  final double longitude;
  final String geohash;
}

enum LocationCaptureStatus {
  captured,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  failed,
}

class LocationCaptureResult {
  const LocationCaptureResult._({
    required this.status,
    this.capture,
  });

  factory LocationCaptureResult.captured(LocationCapture capture) =>
      LocationCaptureResult._(
        status: LocationCaptureStatus.captured,
        capture: capture,
      );
  factory LocationCaptureResult.serviceDisabled() =>
      const LocationCaptureResult._(
        status: LocationCaptureStatus.serviceDisabled,
      );
  factory LocationCaptureResult.permissionDenied() =>
      const LocationCaptureResult._(
        status: LocationCaptureStatus.permissionDenied,
      );
  factory LocationCaptureResult.permissionDeniedForever() =>
      const LocationCaptureResult._(
        status: LocationCaptureStatus.permissionDeniedForever,
      );
  factory LocationCaptureResult.timeout() =>
      const LocationCaptureResult._(status: LocationCaptureStatus.timeout);
  factory LocationCaptureResult.failed() =>
      const LocationCaptureResult._(status: LocationCaptureStatus.failed);

  final LocationCaptureStatus status;
  final LocationCapture? capture;

  bool get isCaptured => status == LocationCaptureStatus.captured;
}

class LocationService {
  const LocationService({
    this.geohashPrecision = 9,
    this.timeout = const Duration(seconds: 15),
    this.accuracy = LocationAccuracy.medium,
  });

  final int geohashPrecision;
  final Duration timeout;
  final LocationAccuracy accuracy;

  Future<LocationCaptureResult> capture() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationCaptureResult.serviceDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return LocationCaptureResult.permissionDenied();
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationCaptureResult.permissionDeniedForever();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );

      final geohash = GeoHasher().encode(
        position.longitude,
        position.latitude,
        precision: geohashPrecision,
      );

      return LocationCaptureResult.captured(
        LocationCapture(
          latitude: position.latitude,
          longitude: position.longitude,
          geohash: geohash,
        ),
      );
    } on LocationServiceDisabledException {
      return LocationCaptureResult.serviceDisabled();
    } on PermissionDeniedException {
      return LocationCaptureResult.permissionDenied();
    } on TimeoutException {
      return LocationCaptureResult.timeout();
    } catch (error, stack) {
      const AppLogger().log(
        'location_capture_failed',
        level: AppLogLevel.warning,
        error: error,
        stackTrace: stack,
      );
      return LocationCaptureResult.failed();
    }
  }
}
