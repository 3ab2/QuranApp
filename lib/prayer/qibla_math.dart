import 'dart:math' as math;

const double kKaabaLatitude = 21.422487;
const double kKaabaLongitude = 39.826206;

double qiblaHaversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthKm = 6371.0;
  final p1 = lat1 * math.pi / 180;
  final p2 = lat2 * math.pi / 180;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLon = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(p1) * math.cos(p2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthKm * c;
}

/// Bearing from [lat]/[lon] to the Kaaba, degrees clockwise from true north (0–360).
double qiblaBearingDegrees(double lat, double lon) {
  final lat1 = lat * math.pi / 180;
  const lat2 = kKaabaLatitude * math.pi / 180;
  final dLon = (kKaabaLongitude - lon) * math.pi / 180;
  final y = math.sin(dLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  final deg = math.atan2(y, x) * 180 / math.pi;
  return (deg + 360) % 360;
}

String formatQiblaBearing(double degrees) {
  final rounded = degrees.round();
  return '$rounded°';
}
