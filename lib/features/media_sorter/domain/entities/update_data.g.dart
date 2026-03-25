// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateData _$UpdateDataFromJson(Map<String, dynamic> json) => UpdateData(
  (json['chronoId'] as num).toInt(),
  (json['sheetId'] as num).toInt(),
  (json['updates'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, UpdateUnit.fromJson(e as Map<String, dynamic>)),
  ),
  addOtherwiseRemove: json['addOtherwiseRemove'] as bool? ?? false,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$UpdateDataToJson(UpdateData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'chronoId': instance.chronoId,
      'sheetId': instance.sheetId,
      'updates': instance.updates.map((k, e) => MapEntry(k, e.toJson())),
      'addOtherwiseRemove': instance.addOtherwiseRemove,
    };

HistoryIndexChg _$HistoryIndexChgFromJson(Map<String, dynamic> json) =>
    HistoryIndexChg(
      (json['sheetId'] as num).toInt(),
      (json['historyIndex'] as num).toInt(),
    );

Map<String, dynamic> _$HistoryIndexChgToJson(HistoryIndexChg instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
      'historyIndex': instance.historyIndex,
    };

FindBestSortChg _$FindBestSortChgFromJson(Map<String, dynamic> json) =>
    FindBestSortChg(
      (json['sheetId'] as num).toInt(),
      json['findingBestSort'] as bool,
    );

Map<String, dynamic> _$FindBestSortChgToJson(FindBestSortChg instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
      'findingBestSort': instance.findingBestSort,
    };

AlwaysApplyBestSortChg _$AlwaysApplyBestSortChgFromJson(
  Map<String, dynamic> json,
) => AlwaysApplyBestSortChg(
  (json['sheetId'] as num).toInt(),
  json['toAlwaysApplyBestSort'] as bool,
);

Map<String, dynamic> _$AlwaysApplyBestSortChgToJson(
  AlwaysApplyBestSortChg instance,
) => <String, dynamic>{
  'sheetId': instance.sheetId,
  'toAlwaysApplyBestSort': instance.toAlwaysApplyBestSort,
};

SheetNameUpdate _$SheetNameUpdateFromJson(Map<String, dynamic> json) =>
    SheetNameUpdate(
      json['newName'] as String,
      previousName: json['previousName'] as String?,
    );

Map<String, dynamic> _$SheetNameUpdateToJson(SheetNameUpdate instance) =>
    <String, dynamic>{
      'newName': instance.newName,
      'previousName': instance.previousName,
    };

CellUpdate _$CellUpdateFromJson(Map<String, dynamic> json) => CellUpdate(
  (json['sheetId'] as num).toInt(),
  (json['rowId'] as num).toInt(),
  (json['colId'] as num).toInt(),
  json['newValue'] as String,
  prevValue: json['prevValue'] as String?,
);

Map<String, dynamic> _$CellUpdateToJson(CellUpdate instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
      'rowId': instance.rowId,
      'colId': instance.colId,
      'prevValue': instance.prevValue,
      'newValue': instance.newValue,
    };

ColumnTypeUpdate _$ColumnTypeUpdateFromJson(Map<String, dynamic> json) =>
    ColumnTypeUpdate(
      (json['colId'] as num).toInt(),
      $enumDecode(_$ColumnTypeEnumMap, json['newColumnType']),
      previousColumnType: $enumDecodeNullable(
        _$ColumnTypeEnumMap,
        json['previousColumnType'],
      ),
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
