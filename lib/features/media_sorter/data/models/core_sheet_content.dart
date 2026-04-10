
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/data/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<CellPosition, String> cells;
  Map<int, ColumnType> columnTypes;
  final List<int> usedRows;
  final List<int> usedCols;

  static int _idCounter = 0;

  CoreSheetContent({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.cells,
    required this.columnTypes,
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
      usedRows: [],
      usedCols: [],
    );
  }
}
