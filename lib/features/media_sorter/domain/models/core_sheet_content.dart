
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<CellPosition, String> cells;
  Map<int, ColumnType> columnTypes;
  final List<int> usedRows;
  final List<int> usedCols;
  final bool toAlwaysApplyCurrentBestSort;

  static int _idCounter = 0;

  CoreSheetContent({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.cells,
    required this.columnTypes,
    required this.usedRows,
    required this.usedCols,
    required this.toAlwaysApplyCurrentBestSort,
  });

  factory CoreSheetContent.empty(String title) {
    return CoreSheetContent(
      id: _idCounter++,
      title: title,
      lastOpened: DateTime.now(),
      cells: {},
      columnTypes: {},
      usedRows: [],
      usedCols: [],
      toAlwaysApplyCurrentBestSort: false,
    );
  }
}
