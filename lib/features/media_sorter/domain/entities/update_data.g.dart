// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetNameUpdate _$SheetNameUpdateFromJson(Map<String, dynamic> json) =>
    SheetNameUpdate(
      DateTime.parse(json['timestamp'] as String),
      json['newName'] as String,
      json['previousName'] as String?,
    );

Map<String, dynamic> _$SheetNameUpdateToJson(SheetNameUpdate instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'newName': instance.newName,
      'previousName': instance.previousName,
    };

CellUpdate _$CellUpdateFromJson(Map<String, dynamic> json) => CellUpdate(
      DateTime.parse(json['timestamp'] as String),
      (json['rowId'] as num).toInt(),
      (json['colId'] as num).toInt(),
      json['newValue'] as String,
      previousValue: json['previousValue'] as String? ?? "",
    );

Map<String, dynamic> _$CellUpdateToJson(CellUpdate instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'rowId': instance.rowId,
      'colId': instance.colId,
      'previousValue': instance.previousValue,
      'newValue': instance.newValue,
    };

ColumnTypeUpdate _$ColumnTypeUpdateFromJson(Map<String, dynamic> json) =>
    ColumnTypeUpdate(
      DateTime.parse(json['timestamp'] as String),
      (json['colId'] as num).toInt(),
      $enumDecode(_$ColumnTypeEnumMap, json['newColumnType']),
      $enumDecodeNullable(_$ColumnTypeEnumMap, json['previousColumnType']),
    );

Map<String, dynamic> _$ColumnTypeUpdateToJson(ColumnTypeUpdate instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'colId': instance.colId,
      'newColumnType': _$ColumnTypeEnumMap[instance.newColumnType]!,
      'previousColumnType': _$ColumnTypeEnumMap[instance.previousColumnType],
    };

const _$ColumnTypeEnumMap = {
  ColumnType.names: 'names',
  ColumnType.dependencies: 'dependencies',
  ColumnType.sprawl: 'sprawl',
  ColumnType.attributes: 'attributes',
  ColumnType.filePath: 'filePath',
  ColumnType.urls: 'urls',
};
