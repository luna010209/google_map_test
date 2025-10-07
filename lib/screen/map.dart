import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_test/components/distance_tracking.dart';
import 'package:google_map_test/screen/widget/point_cluster.dart';
import 'package:google_map_test/utils/camera_focus.dart';
import 'package:google_map_test/utils/k_means.dart';
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
  LatLng? _initialPosition;
  Map<int, List<LatLng>> clustersMap = {};
  int k=5;
  int activeCluster = 5;
  bool _isTracking = false;
  final DistanceTracker _distanceTracker = DistanceTracker();
  StreamSubscription<Position>? _positionStreamSubscription;

  final List<BitmapDescriptor> clusterColors = [
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
  ];

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

  void _launchMapUrl(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _initializeMarkers() async {
    try {
      clustersMap = await kmeansClustering(k);

      print("All points: $clustersMap");

      if (clustersMap.isEmpty) return;

      final Set<Marker> newMarkers = {};

      clustersMap.forEach((index, points) {
        final color = clusterColors[index % clusterColors.length];
        for (LatLng point in points){
          newMarkers.add(
            Marker(
              markerId: MarkerId(point.toString()),
              position: point,
              icon: color,
              onTap: () => _launchMapUrl(point)
            )
          );
        }
      });

      setState(() {
        _markers.addAll(newMarkers);
        _initialPosition = clustersMap[0]!.first;
      });

      if (_mapController != null && clustersMap.isNotEmpty){
        final allPoints = clustersMap.values.expand((e) => e).toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cameraFocus(allPoints, _mapController);
        });
      }
    } catch (e){
      print("❌ Failed to initialize markers: $e");
    }
  }

  void _setClusterMarkers(int clusterIndex) {
    final clusterPoints;
    if (clusterIndex==-1) clusterPoints = clustersMap;
    else clusterPoints = clustersMap[clusterIndex] ?? [];

    setState(() {
      if (clusterPoints.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cameraFocus(clusterPoints, _mapController);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map with Points')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition ?? const LatLng(37.5665, 126.9780), // Focus on the first point
              zoom: 16,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                cameraFocus(_markers.map((m)=> m.position).toList(), _mapController);
              });
            },
          ),
          PointCluster(
            k: k,
            clusterMap: clustersMap,
            onClusterSelected: (index) {
              _setClusterMarkers(index);
            }
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
