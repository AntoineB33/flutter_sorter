
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<(int, int), String> cells;
  final Map<int, ColumnType> columnTypes;
  int lastRow;
  int lastCol;

  static int _idCounter = 0;

  CoreSheetContent({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.cells,
    required this.columnTypes,
    required this.lastRow,
    required this.lastCol,
  });

  factory CoreSheetContent.empty() {
    return CoreSheetContent(
      id: _idCounter++,
      title: SpreadsheetConstants.defaultSheetTitle,
      lastOpened: DateTime.now(),
      cells: {},
      columnTypes: {},
      lastRow: 0,
      lastCol: 0,
    );
  }
}
