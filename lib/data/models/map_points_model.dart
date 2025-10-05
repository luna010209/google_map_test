import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_points_model.freezed.dart';
part 'map_points_model.g.dart';

@freezed
abstract class MapPointsModel with _$MapPointsModel {
  const factory MapPointsModel({
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
  }) = _MapPointsModel;

  factory MapPointsModel.fromJson(Map<String, dynamic> json) =>
      _$MapPointsModelFromJson(json);
}