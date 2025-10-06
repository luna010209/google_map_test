import 'package:google_map_test/utils/map_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kmeans/kmeans.dart';

Future<Map<int, List<LatLng>>> kmeansClustering(int k) async{
  final List<LatLng> points = await fetchMapPoints();

  if (points.isEmpty){
    throw Exception("No points found for clustering.");
  }
  final List<List<double>> data =
      points.map((p)=> [p.latitude, p.longitude]).toList();

  final kmeans = KMeans(data);

  final result = kmeans.fit(
    k,
    maxIterations: 100,
    seed: 42,
  );

  final Map<int, List<LatLng>> clustersMap = {};
  for (int i=0; i < points.length; i++){
    final clusterIndex = result.clusters[i];
    clustersMap.putIfAbsent(clusterIndex, () => []);
    clustersMap[clusterIndex]!.add(points[i]);
  }

  return clustersMap;
}