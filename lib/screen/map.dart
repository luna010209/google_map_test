import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_test/components/distance_tracking.dart';
import 'package:google_map_test/utils/camera_focus.dart';
import 'package:google_map_test/utils/map_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _isTracking = false;
  final DistanceTracker _distanceTracker = DistanceTracker();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _currentLocation();
    _initializeMarkers(); // setup static markers
  }

  void _currentLocation() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,  // minimum movement (meters) to trigger update
      ),
    ).listen((Position position) async {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      // Load the icon first
      final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        "assets/images/navigation/image.png",
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == const MarkerId("currentLocation"));
        _markers.add(
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentLatLng,
            icon: icon,
            infoWindow: const InfoWindow(title: 'You are here'),
            rotation: position.heading, // ✅ rotate marker based on user heading
            flat: true,                 // ✅ allows rotation effect
            anchor: const Offset(0.5, 0.5),
          ),
        );
      });
    });
  }

  void _initializeMarkers() {
    final staticMarkers = MapPoints.points
        .map(
          (point) => Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        onTap: () => _launchMapUrl(point),
      ),
    )
        .toSet();

    setState(() {
      _markers.addAll(staticMarkers);
    });
  }


  void _launchMapUrl(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void toggleTracking() async {
    if (_isTracking) {
      // Stop tracking
      _distanceTracker.stopDistanceTracking();
      setState(() {
        _isTracking = false;
      });
    } else {
      print("start tracking");
      // Start tracking
      await _distanceTracker.startDistanceTracking(
        currentMarkers: _markers,
        updateMarkers: (newMarkers) {
          setState(() {
            _markers = newMarkers;
          });
        },
      );
      setState(() {
        _isTracking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map with Points')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: MapPoints.points[0], // Focus on the first point
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                cameraFocus(MapPoints.points, _mapController);
              });
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: toggleTracking,
              label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }
}
