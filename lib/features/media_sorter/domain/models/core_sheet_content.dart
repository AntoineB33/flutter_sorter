import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';

part 'core_sheet_content.freezed.dart';

@freezed
abstract class CoreSheetContent with _$CoreSheetContent {
  factory CoreSheetContent({
    required int sheetId,
    required String title,
    required DateTime lastOpened,
    required Map<CellPosition, String> cells,
    required Map<int, ColumnType> columnTypes,
    required List<int> usedRows,
    required List<int> usedCols,
    required bool toAlwaysApplyCurrentBestSort,
  }) = _CoreSheetContent;

  factory CoreSheetContent.empty(String title, int sheetId) {
    return CoreSheetContent(
      sheetId: sheetId,
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
