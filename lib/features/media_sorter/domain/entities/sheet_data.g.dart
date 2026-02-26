// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sheet_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SheetData _$SheetDataFromJson(Map<String, dynamic> json) => SheetData(
      sheetContent:
          SheetContent.fromJson(json['sheetContent'] as Map<String, dynamic>),
      updateHistories: (json['updateHistories'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => UpdateData.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      historyIndex: (json['historyIndex'] as num).toInt(),
      rowsBottomPos: (json['rowsBottomPos'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      colRightPos: (json['colRightPos'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      rowsManuallyAdjustedHeight:
          (json['rowsManuallyAdjustedHeight'] as List<dynamic>)
              .map((e) => e as bool)
              .toList(),
      colsManuallyAdjustedWidth:
          (json['colsManuallyAdjustedWidth'] as List<dynamic>)
              .map((e) => e as bool)
              .toList(),
      colHeaderHeight: (json['colHeaderHeight'] as num).toDouble(),
      rowHeaderWidth: (json['rowHeaderWidth'] as num).toDouble(),
    );

Map<String, dynamic> _$SheetDataToJson(SheetData instance) => <String, dynamic>{
      'sheetContent': instance.sheetContent.toJson(),
      'updateHistories': instance.updateHistories
          .map((e) => e.map((e) => e.toJson()).toList())
          .toList(),
      'historyIndex': instance.historyIndex,
      'rowsBottomPos': instance.rowsBottomPos,
      'colRightPos': instance.colRightPos,
      'rowsManuallyAdjustedHeight': instance.rowsManuallyAdjustedHeight,
      'colsManuallyAdjustedWidth': instance.colsManuallyAdjustedWidth,
      'colHeaderHeight': instance.colHeaderHeight,
      'rowHeaderWidth': instance.rowHeaderWidth,
    };
