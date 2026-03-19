import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:drift/drift.dart';

class SheetData {
  final int id;
  String title;
  final Map<(int, int), String> cells;
  final Map<int, ColumnType> columnTypes;
  List<UpdateData> updateHistories;
  int historyIndex;
  List<double> rowsBottomPos;
  List<double> colRightPos;
  List<bool> rowsManuallyAdjustedHeight;
  List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;
  List<Point<int>> selectedCells;
  Point<int> primarySelectedCell;
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
