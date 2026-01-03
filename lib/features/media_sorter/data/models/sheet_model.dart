import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class SheetModel {
  List<List<String>> table;
  List<String> columnTypes;
  List<double> rowsBottomPos;
  List<double> colRightPos;
  List<bool> rowsManuallyAdjustedHeight;
  List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;

  SheetModel({
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

      // Safely convert the table, handling non-string values gracefully
      List<List<String>> parsedTable = rawTable.map((row) {
        if (row is List) {
          return row.map((cell) => cell.toString()).toList();
        }
        return <String>[]; // Handle malformed rows safely
      }).toList();

      var rawTypes = json['columnTypes'] as List;
      List<String> parsedTypes = rawTypes.map((e) => e.toString()).toList();

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
      'table': table,
      'columnTypes': columnTypes,
      'rowsBottomPos': rowsBottomPos,
      'colRightPos': colRightPos,
      'rowsManuallyAdjustedHeight': rowsManuallyAdjustedHeight,
      'colsManuallyAdjustedWidth': colsManuallyAdjustedWidth,
      'colHeaderHeight': colHeaderHeight,
      'rowHeaderWidth': rowHeaderWidth,
    };
  }
}
