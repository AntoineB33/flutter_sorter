import 'dart:math';

import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';

class SheetData {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<(int, int), String> cells;
  final Map<int, ColumnType> columnTypes;
  List<UpdateData> updateHistories;
  int historyIndex;
  final List<double> rowsBottomPos;
  final List<double> colRightPos;
  final List<bool> rowsManuallyAdjustedHeight;
  final List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;
  final List<Point<int>> selectedCells;
  int primarySelectedCellX;
  int primarySelectedCellY;
  double scrollOffsetX;
  double scrollOffsetY;
  final List<int> bestSortFound;
  final List<int> cursors;
  final List<List<int>> possibleIntsById;
  final List<List<List<int>>> validAreasById;
  final List<int> bestDistFound;
  int sortIndex;

  SheetData({
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
