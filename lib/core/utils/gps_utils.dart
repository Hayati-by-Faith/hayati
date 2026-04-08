class GpsUtils {
  const GpsUtils._();

  static String geohashFromCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(5)}:${longitude.toStringAsFixed(5)}';
  }
}

