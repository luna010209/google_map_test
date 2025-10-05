import 'package:google_map_test/data/models/map_points_model.dart';

import '../entity/map_points_entity.dart';

class MapPointsMapper {
  static MapPointsEntity toEntity(MapPointsModel model){
    return MapPointsEntity(
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  static MapPointsModel toModel(MapPointsEntity entity){
    return MapPointsModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  static MapPointsEntity fromJson(Map<String, dynamic> json){
    final model = MapPointsModel.fromJson(json);
    return toEntity(model);
  }
}