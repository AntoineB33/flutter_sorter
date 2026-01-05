import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class SheetModel {
  List<UpdateHistory> updateHistories;
  int historyIndex;
  List<List<String>> table;
  List<ColumnType> columnTypes;
  List<double> rowsBottomPos;
  List<double> colRightPos;
  List<bool> rowsManuallyAdjustedHeight;
  List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;

  SheetModel({
    required this.updateHistories,
    required this.historyIndex,
    required this.table,
    required this.columnTypes,
    required this.rowsBottomPos,
    required this.colRightPos,
    required this.rowsManuallyAdjustedHeight,
    required this.colsManuallyAdjustedWidth,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
  });

  factory SheetModel.empty() {
    return SheetModel(
      updateHistories: [],
      historyIndex: -1,
      table: [],
      columnTypes: [],
      rowsBottomPos: [],
      colRightPos: [],
      rowsManuallyAdjustedHeight: [],
      colsManuallyAdjustedWidth: [],
      colHeaderHeight: PageConstants.defaultColHeaderHeight,
      rowHeaderWidth: PageConstants.defaultRowHeaderWidth,
    );
  }

  // This factory handles the ugly 'dynamic' parsing in one isolated place
  factory SheetModel.fromJson(Map<String, dynamic> json) {
    try {
      var rawTable = json['table'] as List;

      var rawUpdateHistories = json['updateHistories'] as List;
      List<UpdateHistory> parsedUpdateHistories = rawUpdateHistories.map((uh) {
        var updatedCellsRaw = uh['updatedCells'] as List;
        List<CellUpdateHistory> parsedUpdatedCells = updatedCellsRaw.map((uch) {
          var cellPoint = uch['cell'] as Map<String, dynamic>;
          return CellUpdateHistory(
            cell: Point<int>(
              cellPoint['x'] as int,
              cellPoint['y'] as int,
            ),
            previousValue: uch['previousValue'] as String,
            newValue: uch['newValue'] as String,
          );
        }).toList();

        return UpdateHistory(
          key: uh['key'] as String,
          timestamp: DateTime.parse(uh['timestamp'] as String),
        )..updatedCells?.addAll(parsedUpdatedCells);
      }).toList();

      // Safely convert the table, handling non-string values gracefully
      List<List<String>> parsedTable = rawTable.map((row) {
        if (row is List) {
          return row.map((cell) => cell.toString()).toList();
        }
        return <String>[]; // Handle malformed rows safely
      }).toList();

      var rawTypes = json['columnTypes'] as List;
      List<ColumnType> parsedTypes = rawTypes.map((e) => ColumnType.values.firstWhere((ct) => ct.toString() == e.toString())).toList();

      List<double> parsedHeight =
          (json['rowsBottomPos'] as List).map((e) => e as double).toList();
      List<double> parsedWidth =
          (json['colRightPos'] as List).map((e) => e as double).toList();
      List<bool> parsedRowsManuallyAdjustedHeight =
          (json['rowsManuallyAdjustedHeight'] as List)
              .map((e) => e as bool)
              .toList();
      List<bool> parsedColsManuallyAdjustedWidth =
          (json['colsManuallyAdjustedWidth'] as List)
              .map((e) => e as bool)
              .toList();

      return SheetModel(
        updateHistories: parsedUpdateHistories,
        historyIndex: json['historyIndex'] as int,
        table: parsedTable,
        columnTypes: parsedTypes,
        rowsBottomPos: parsedHeight,
        colRightPos: parsedWidth,
        rowsManuallyAdjustedHeight: parsedRowsManuallyAdjustedHeight,
        colsManuallyAdjustedWidth: parsedColsManuallyAdjustedWidth,
        colHeaderHeight:
            json['colHeaderHeight'] as double,
        rowHeaderWidth:
            json['rowHeaderWidth'] as double,
      );
    } catch (e) {
      debugPrint("Error parsing SheetModel from JSON: $e");
      return SheetModel.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'updateHistories': updateHistories.map((uh) {
        return {
          'key': uh.key,
          'timestamp': uh.timestamp.toIso8601String(),
          'updatedCells': uh.updatedCells?.map((uch) {
            return {
              'cell': {'x': uch.cell.x, 'y': uch.cell.y},
              'previousValue': uch.previousValue,
              'newValue': uch.newValue,
            };
          }).toList(),
        };
      }).toList(),
      'historyIndex': historyIndex,
      'table': table,
      'columnTypes': columnTypes.map((ct) => ct.toString()).toList(),
      'rowsBottomPos': rowsBottomPos,
      'colRightPos': colRightPos,
      'rowsManuallyAdjustedHeight': rowsManuallyAdjustedHeight,
      'colsManuallyAdjustedWidth': colsManuallyAdjustedWidth,
      'colHeaderHeight': colHeaderHeight,
      'rowHeaderWidth': rowHeaderWidth,
    };
  }
}
