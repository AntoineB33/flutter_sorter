// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetDataUpdate _$SheetDataUpdateFromJson(
  Map<String, dynamic> json,
) => SheetDataUpdate(
  (json['sheetId'] as num).toInt(),
  json['addOtherwiseRemove'] as bool,
  newName: json['newName'] as String?,
  prevName: json['prevName'] as String?,
  lastOpened: json['lastOpened'] == null
      ? null
      : DateTime.parse(json['lastOpened'] as String),
  usedRows: (json['usedRows'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  usedCols: (json['usedCols'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  historyIndex: (json['historyIndex'] as num?)?.toInt(),
  colHeaderHeight: (json['colHeaderHeight'] as num?)?.toDouble(),
  prevColHeaderHeight: (json['prevColHeaderHeight'] as num?)?.toDouble(),
  rowHeaderWidth: (json['rowHeaderWidth'] as num?)?.toDouble(),
  prevRowHeaderWidth: (json['prevRowHeaderWidth'] as num?)?.toDouble(),
  primSelHistory: (json['primSelHistory'] as List<dynamic>?)
      ?.map((e) => CellPosition.fromJson(e as Map<String, dynamic>))
      .toList(),
  primSelHistoryId: (json['primSelHistoryId'] as num?)?.toInt(),
  scrollOffsetX: (json['scrollOffsetX'] as num?)?.toDouble(),
  scrollOffsetY: (json['scrollOffsetY'] as num?)?.toDouble(),
  selectedCells: (json['selectedCells'] as List<dynamic>?)
      ?.map((e) => CellPosition.fromJson(e as Map<String, dynamic>))
      .toSet(),
  bestSortFound: (json['bestSortFound'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  bestDistFound: (json['bestDistFound'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  cursors: (json['cursors'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  possibleInts: (json['possibleInts'] as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  validAreas: (json['validAreas'] as List<dynamic>?)
      ?.map(
        (e) => (e as List<dynamic>)
            .map(
              (e) =>
                  (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
            )
            .toList(),
      )
      .toList(),
  sortIndex: (json['sortIndex'] as num?)?.toInt(),
  analysisResult: json['analysisResult'] as String?,
  validSortIsImpossible: json['validSortIsImpossible'] as bool?,
  isFindingBestSort: json['isFindingBestSort'] as bool?,
  sortedWithValidSort: json['sortedWithValidSort'] as bool?,
  sortedWithCurrentBestSort: json['sortedWithCurrentBestSort'] as bool?,
  bestSortPossibleFound: json['bestSortPossibleFound'] as bool?,
  sortInProgress: json['sortInProgress'] as bool?,
  toApplyNextBestSort: json['toApplyNextBestSort'] as bool?,
  toAlwaysApplyCurrentBestSort: json['toAlwaysApplyCurrentBestSort'] as bool?,
  analysIsDone: json['analysIsDone'] as bool?,
);

Map<String, dynamic> _$SheetDataUpdateToJson(SheetDataUpdate instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
      'addOtherwiseRemove': instance.addOtherwiseRemove,
      'newName': instance.newName,
      'prevName': instance.prevName,
      'lastOpened': instance.lastOpened?.toIso8601String(),
      'usedRows': instance.usedRows,
      'usedCols': instance.usedCols,
      'colHeaderHeight': instance.colHeaderHeight,
      'prevColHeaderHeight': instance.prevColHeaderHeight,
      'rowHeaderWidth': instance.rowHeaderWidth,
      'prevRowHeaderWidth': instance.prevRowHeaderWidth,
      'scrollOffsetX': instance.scrollOffsetX,
      'scrollOffsetY': instance.scrollOffsetY,
      'primSelHistory': instance.primSelHistory,
      'primSelHistoryId': instance.primSelHistoryId,
      'historyIndex': instance.historyIndex,
      'selectedCells': instance.selectedCells?.toList(),
      'bestSortFound': instance.bestSortFound,
      'bestDistFound': instance.bestDistFound,
      'cursors': instance.cursors,
      'possibleInts': instance.possibleInts,
      'validAreas': instance.validAreas,
      'sortIndex': instance.sortIndex,
      'analysisResult': instance.analysisResult,
      'validSortIsImpossible': instance.validSortIsImpossible,
      'isFindingBestSort': instance.isFindingBestSort,
      'sortedWithValidSort': instance.sortedWithValidSort,
      'sortedWithCurrentBestSort': instance.sortedWithCurrentBestSort,
      'bestSortPossibleFound': instance.bestSortPossibleFound,
      'sortInProgress': instance.sortInProgress,
      'toApplyNextBestSort': instance.toApplyNextBestSort,
      'toAlwaysApplyCurrentBestSort': instance.toAlwaysApplyCurrentBestSort,
      'analysIsDone': instance.analysIsDone,
    };

CellUpdate _$CellUpdateFromJson(Map<String, dynamic> json) => CellUpdate(
  (json['sheetId'] as num).toInt(),
  (json['rowId'] as num).toInt(),
  (json['colId'] as num).toInt(),
  json['newValue'] as String,
)..prevValue = json['prevValue'] as String?;

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
        (json['sheetId'] as num).toInt(),
        (json['colId'] as num).toInt(),
        $enumDecode(_$ColumnTypeEnumMap, json['newColumnType']),
      )
      ..previousColumnType = $enumDecodeNullable(
        _$ColumnTypeEnumMap,
        json['previousColumnType'],
      );

Map<String, dynamic> _$ColumnTypeUpdateToJson(ColumnTypeUpdate instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
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

UpdateData _$UpdateDataFromJson(Map<String, dynamic> json) => UpdateData(
  (json['chronoId'] as num).toInt(),
  (json['sheetId'] as num).toInt(),
  (json['updates'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, UpdateUnit.fromJson(e as Map<String, dynamic>)),
  ),
  json['addOtherwiseRemove'] as bool,
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

RowsBottomPosUpdate _$RowsBottomPosUpdateFromJson(Map<String, dynamic> json) =>
    RowsBottomPosUpdate(
      (json['sheetId'] as num).toInt(),
      json['addOtherwiseRemove'] as bool,
      (json['rowIndex'] as num).toInt(),
      (json['newBottomPos'] as num).toDouble(),
      prevBottomPos: (json['prevBottomPos'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RowsBottomPosUpdateToJson(
  RowsBottomPosUpdate instance,
) => <String, dynamic>{
  'sheetId': instance.sheetId,
  'addOtherwiseRemove': instance.addOtherwiseRemove,
  'rowIndex': instance.rowIndex,
  'newBottomPos': instance.newBottomPos,
  'prevBottomPos': instance.prevBottomPos,
};

ColRightPosUpdate _$ColRightPosUpdateFromJson(Map<String, dynamic> json) =>
    ColRightPosUpdate(
      (json['sheetId'] as num).toInt(),
      json['addOtherwiseRemove'] as bool,
      (json['colIndex'] as num).toInt(),
      (json['newRightPos'] as num).toDouble(),
      prevRightPos: (json['prevRightPos'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ColRightPosUpdateToJson(ColRightPosUpdate instance) =>
    <String, dynamic>{
      'sheetId': instance.sheetId,
      'addOtherwiseRemove': instance.addOtherwiseRemove,
      'colIndex': instance.colIndex,
      'newRightPos': instance.newRightPos,
      'prevRightPos': instance.prevRightPos,
    };

RowsManuallyAdjustedHeightUpdate _$RowsManuallyAdjustedHeightUpdateFromJson(
  Map<String, dynamic> json,
) => RowsManuallyAdjustedHeightUpdate(
  (json['sheetId'] as num).toInt(),
  json['addOtherwiseRemove'] as bool,
  (json['rowIndex'] as num).toInt(),
  json['manuallyAdjusted'] as bool,
  prevManuallyAdjusted: json['prevManuallyAdjusted'] as bool?,
);

Map<String, dynamic> _$RowsManuallyAdjustedHeightUpdateToJson(
  RowsManuallyAdjustedHeightUpdate instance,
) => <String, dynamic>{
  'sheetId': instance.sheetId,
  'addOtherwiseRemove': instance.addOtherwiseRemove,
  'rowIndex': instance.rowIndex,
  'manuallyAdjusted': instance.manuallyAdjusted,
  'prevManuallyAdjusted': instance.prevManuallyAdjusted,
};

ColsManuallyAdjustedWidthUpdate _$ColsManuallyAdjustedWidthUpdateFromJson(
  Map<String, dynamic> json,
) => ColsManuallyAdjustedWidthUpdate(
  (json['sheetId'] as num).toInt(),
  json['addOtherwiseRemove'] as bool,
  (json['colIndex'] as num).toInt(),
  json['manuallyAdjusted'] as bool,
  prevManuallyAdjusted: json['prevManuallyAdjusted'] as bool?,
);

Map<String, dynamic> _$ColsManuallyAdjustedWidthUpdateToJson(
  ColsManuallyAdjustedWidthUpdate instance,
) => <String, dynamic>{
  'sheetId': instance.sheetId,
  'addOtherwiseRemove': instance.addOtherwiseRemove,
  'colIndex': instance.colIndex,
  'manuallyAdjusted': instance.manuallyAdjusted,
  'prevManuallyAdjusted': instance.prevManuallyAdjusted,
};
