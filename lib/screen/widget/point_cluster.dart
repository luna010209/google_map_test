import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PointCluster extends StatefulWidget{
  final int k;
  final Map<int, List<LatLng>> clusterMap;
  final Function(int) onClusterSelected;

  const PointCluster({
    super.key,
    required this.k,
    required this.clusterMap,
    required this.onClusterSelected,
  });

  @override
  State<StatefulWidget> createState() => _PointClusterState();
}
class _PointClusterState extends State<PointCluster>{
  int activeCluster = -1;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 10,
        left: 10,
        right: 10,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Button "All Clusters"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeCluster==-1?
                      Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        activeCluster = -1;
                        // _setClusterMarkers(activeCluster);
                      });
                      widget.onClusterSelected(-1);
                    },
                    child: Text('All Clusters'),
                  ),
                ),
                Row(
                  children: List.generate(widget.k , (index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeCluster==index?
                          Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            activeCluster = index;
                            // _setClusterMarkers(activeCluster);
                          });
                          widget.onClusterSelected(index);
                        },
                        child: Text('Cluster ${index+1}'),
                      ),
                    );
                  }),
                ),
              ],
            )

        )
    );
  }

}