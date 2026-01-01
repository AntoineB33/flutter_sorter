import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';

class SheetModel {
  List<List<String>> table;
  List<String> columnTypes;
  List<int> rowsBottomPos;
  List<int> colRightPos;
  int colHeaderHeight;
  int rowHeaderWidth;

  SheetModel({
    required this.table,
    required this.columnTypes,
    required this.rowsBottomPos,
    required this.colRightPos,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
  });

  factory SheetModel.empty() {
    return SheetModel(
      table: [],
      columnTypes: [],
      rowsBottomPos: [],
      colRightPos: [],
      colHeaderHeight: PageConstants.defaultColHeaderHeight.toInt(),
      rowHeaderWidth: PageConstants.defaultRowHedaerWidth.toInt(),
    );
  }

  // This factory handles the ugly 'dynamic' parsing in one isolated place
  factory SheetModel.fromJson(Map<String, dynamic> json) {
    var rawTable = json['table'] as List? ?? [];

    // Safely convert the table, handling non-string values gracefully
    List<List<String>> parsedTable = rawTable.map((row) {
      if (row is List) {
        return row.map((cell) => cell.toString()).toList();
      }
      return <String>[]; // Handle malformed rows safely
    }).toList();

    var rawTypes = json['columnTypes'] as List? ?? [];
    List<String> parsedTypes = rawTypes.map((e) => e.toString()).toList();

    List<int> parsedHeight =
        (json['rowsBottomPos'] as List?)?.map((e) => e as int).toList() ?? [];
    List<int> parsedWidth =
        (json['colRightPos'] as List?)?.map((e) => e as int).toList() ?? [];

    return SheetModel(
      table: parsedTable,
      columnTypes: parsedTypes,
      rowsBottomPos: parsedHeight,
      colRightPos: parsedWidth,
      colHeaderHeight: json['colHeaderHeight'] as int? ?? PageConstants.defaultColHeaderHeight.toInt(),
      rowHeaderWidth: json['rowHeaderWidth'] as int? ?? PageConstants.defaultRowHedaerWidth.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {'table': table, 'columnTypes': columnTypes};
}
