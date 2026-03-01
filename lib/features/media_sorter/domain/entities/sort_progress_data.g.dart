// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_progress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortProgressData _$SortProgressDataFromJson(Map<String, dynamic> json) =>
    SortProgressData(
      cursors: (json['choicesMade'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      bestDistFound: (json['bestDistFound'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SortProgressDataToJson(SortProgressData instance) =>
    <String, dynamic>{
      'choicesMade': instance.cursors,
      'bestDistFound': instance.bestDistFound,
    };
