// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortStatus _$SortStatusFromJson(Map<String, dynamic> json) => SortStatus(
  json['toApplyNextBestSort'] as bool,
  json['toAlwaysApplyCurrentBestSort'] as bool,
  json['analysisDone'] as bool,
);

Map<String, dynamic> _$SortStatusToJson(SortStatus instance) =>
    <String, dynamic>{
      'toApplyNextBestSort': instance.toApplyNextBestSort,
      'toAlwaysApplyCurrentBestSort': instance.toAlwaysApplyCurrentBestSort,
      'analysisDone': instance.analysisDone,
    };
