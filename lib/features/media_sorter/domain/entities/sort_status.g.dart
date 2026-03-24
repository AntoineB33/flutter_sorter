// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortStatus _$SortStatusFromJson(Map<String, dynamic> json) => SortStatus(
  toApplyNextBestSort: json['toApplyNextBestSort'] as bool? ?? false,
  toAlwaysApplyCurrentBestSort:
      json['toAlwaysApplyCurrentBestSort'] as bool? ?? false,
  analysisDone: json['analysisDone'] as bool? ?? true,
);

Map<String, dynamic> _$SortStatusToJson(SortStatus instance) =>
    <String, dynamic>{
      'toApplyNextBestSort': instance.toApplyNextBestSort,
      'toAlwaysApplyCurrentBestSort': instance.toAlwaysApplyCurrentBestSort,
      'analysisDone': instance.analysisDone,
    };
