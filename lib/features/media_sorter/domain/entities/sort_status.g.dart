// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SortStatus _$SortStatusFromJson(Map<String, dynamic> json) => SortStatus(
      resultCalculated: json['resultCalculated'] as bool,
      validSortFound: json['validSortFound'] as bool,
      toSort: json['toSort'] as bool,
      isFindingBestSort: json['isFindingBestSort'] as bool,
      sortWhileFindingBestSort: json['sortWhileFindingBestSort'] as bool,
    );

Map<String, dynamic> _$SortStatusToJson(SortStatus instance) =>
    <String, dynamic>{
      'resultCalculated': instance.resultCalculated,
      'validSortFound': instance.validSortFound,
      'toSort': instance.toSort,
      'isFindingBestSort': instance.isFindingBestSort,
      'sortWhileFindingBestSort': instance.sortWhileFindingBestSort,
    };
