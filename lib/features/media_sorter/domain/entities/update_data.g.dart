// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateData _$UpdateDataFromJson(Map<String, dynamic> json) => UpdateData(
      json['id'] as String,
      DateTime.parse(json['timestamp'] as String),
      (json['updates'] as List<dynamic>)
          .map((e) =>
              const UpdateUnitConverter().fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateDataToJson(UpdateData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'updates':
          instance.updates.map(const UpdateUnitConverter().toJson).toList(),
    };

SheetNameUpdate _$SheetNameUpdateFromJson(Map<String, dynamic> json) =>
    SheetNameUpdate(
      json['newName'] as String,
      json['previousName'] as String?,
    );

Map<String, dynamic> _$SheetNameUpdateToJson(SheetNameUpdate instance) =>
    <String, dynamic>{
      'newName': instance.newName,
      'previousName': instance.previousName,
    };

CellUpdate _$CellUpdateFromJson(Map<String, dynamic> json) => CellUpdate(
      (json['rowId'] as num).toInt(),
      (json['colId'] as num).toInt(),
      json['newValue'] as String,
      json['prevValue'] as String,
    );

Map<String, dynamic> _$CellUpdateToJson(CellUpdate instance) =>
    <String, dynamic>{
      'rowId': instance.rowId,
      'colId': instance.colId,
      'prevValue': instance.prevValue,
      'newValue': instance.newValue,
    };

ColumnTypeUpdate _$ColumnTypeUpdateFromJson(Map<String, dynamic> json) =>
    ColumnTypeUpdate(
      (json['colId'] as num).toInt(),
      $enumDecode(_$ColumnTypeEnumMap, json['newColumnType']),
      $enumDecodeNullable(_$ColumnTypeEnumMap, json['previousColumnType']),
    );

Map<String, dynamic> _$ColumnTypeUpdateToJson(ColumnTypeUpdate instance) =>
    <String, dynamic>{
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
