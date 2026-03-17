// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_progress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortProgressData _$SortProgressDataFromJson(Map<String, dynamic> json) =>
    SortProgressData(
      bestSortFound: (json['bestSortFound'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      possibleIntsById: (json['possibleIntsById'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
      cursors: (json['cursors'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      bestDistFound: (json['bestDistFound'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      validAreasById: (json['validAreasById'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) =>
                  (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
              .toList())
          .toList(),
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$SortProgressDataToJson(SortProgressData instance) =>
    <String, dynamic>{
      'bestSortFound': instance.bestSortFound,
      'cursors': instance.cursors,
      'possibleIntsById': instance.possibleIntsById,
      'validAreasById': instance.validAreasById,
      'bestDistFound': instance.bestDistFound,
      'id': instance.id,
    };
