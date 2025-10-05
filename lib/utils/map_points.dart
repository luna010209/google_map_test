import 'dart:convert';

import 'package:google_map_test/data/mapper/map_points_mapper.dart';
import 'package:google_map_test/secrets/api_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<List<LatLng>> fetchMapPoints() async {
  final response = await http.get(
    Uri.parse("${ApiConfig.baseUrl}/"),
    headers: {
      "Authorization": "Bearer ${ApiConfig.apiToken}",
      "Content-Type": "application/json"
    },
  );

  if (response.statusCode!=200){
    throw Exception("Fail to fetch map points: ${response.statusCode}");
  }

  final List<dynamic> data = jsonDecode(response.body);

  final List<LatLng> latLngPoints = data
    .map((json)=> MapPointsMapper.fromJson(json))
    .take(200)
    .map((e) => LatLng(e.latitude, e.longitude))
    .toList();

  return latLngPoints;
}



