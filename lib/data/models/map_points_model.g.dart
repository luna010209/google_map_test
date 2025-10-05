// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_points_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MapPointsModel _$MapPointsModelFromJson(Map<String, dynamic> json) =>
    _MapPointsModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MapPointsModelToJson(_MapPointsModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
