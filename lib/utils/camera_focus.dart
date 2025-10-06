import 'package:google_maps_flutter/google_maps_flutter.dart';

void cameraFocus(List<LatLng> points, GoogleMapController? mapController) {
  if (points.isEmpty || mapController == null) return;

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (LatLng point in points) {
    if (point.latitude < minLat) minLat = point.latitude;
    if (point.latitude > maxLat) maxLat = point.latitude;
    if (point.longitude < minLng) minLng = point.longitude;
    if (point.longitude > maxLng) maxLng = point.longitude;
  }

  final southwest = LatLng(minLat, minLng);
  final northeast = LatLng(maxLat, maxLng);

  final bounds = LatLngBounds(
    southwest: southwest,
    northeast: northeast,
  );

  // Animate camera to fit the bounds with padding
  mapController.animateCamera(
    CameraUpdate.newLatLngBounds(bounds, 50),
  );
}
