
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<CellPosition, String> cells;
  Map<int, ColumnType> columnTypes;
  int lastRow;
  int lastCol;
  final Set<int> usedRows;
  final Set<int> usedCols;

  static int _idCounter = 0;

  CoreSheetContent({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.cells,
    required this.columnTypes,
    required this.lastRow,
    required this.lastCol,
    required this.usedRows,
    required this.usedCols,
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
      usedRows: {},
      usedCols: {},
    );
  }
}
