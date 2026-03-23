import 'dart:math';

import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<(int, int), String> cells;
  final Map<int, ColumnType> columnTypes;

  CoreSheetContent({
    required this.sheetContent,
    required this.updateHistories,
    required this.historyIndex,
    required this.rowsBottomPos,
    required this.colRightPos,
    required this.rowsManuallyAdjustedHeight,
    required this.colsManuallyAdjustedWidth,
    required this.sheetName,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
  });

  factory SheetData.empty() {
    return SheetData(
      sheetContent: SheetContent(table: [], columnTypes: [ColumnType.names]),
      updateHistories: [],
      historyIndex: -1,
      rowsBottomPos: [],
      colRightPos: [],
      rowsManuallyAdjustedHeight: [],
      colsManuallyAdjustedWidth: [],
      sheetName: '',
      colHeaderHeight: PageConstants.defaultColHeaderHeight,
      rowHeaderWidth: PageConstants.defaultRowHeaderWidth,
    );
  }

  factory SheetData.fromJson(Map<String, dynamic> json) => _$SheetDataFromJson(json);

  Map<String, dynamic> toJson() => _$SheetDataToJson(this);
}
