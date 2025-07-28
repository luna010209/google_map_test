import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DistanceTracker {
  final List<Position> _positionList = [];
  double _totalDistance = 0.0;
  StreamSubscription<Position>? _positionStream;

  double get totalDistance => _totalDistance;

  Future<void> startDistanceTracking({
    required Set<Marker> currentMarkers,
    required void Function(Set<Marker>) updateMarkers,
  }) async {
    // Step 1: Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Step 2: Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    // Step 3: Start listening to position stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters
      ),
    ).listen((Position position) async {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        "assets/images/navigation/image.png",
      );

      final updatedMarkers = Set<Marker>.from(currentMarkers)
        ..removeWhere((m) => m.markerId == const MarkerId("currentLocation"))
        ..add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLatLng,
            icon: icon,
            flat: true,
            anchor: const Offset(0.5, 0.5),
          ),
        );

      updateMarkers(updatedMarkers);

      if (_positionList.isNotEmpty) {
        final last = _positionList.last;
        double distance = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          position.latitude,
          position.longitude,
        );
        print('Distance between last and current: $distance meters');
        _totalDistance += distance;
      }

      _positionList.add(position);
      print('Total Distance Travelled: ${_totalDistance.toStringAsFixed(2)} meters');
    });
  }

  void stopDistanceTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    print('Final Distance Travelled: ${_totalDistance.toStringAsFixed(2)} meters');
  }

  void reset() {
    _positionList.clear();
    _totalDistance = 0.0;
  }
}
