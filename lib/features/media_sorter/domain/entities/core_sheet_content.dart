
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';

class CoreSheetContent {
  final int id;
  String title;
  DateTime lastOpened;
  final Map<(int, int), String> cells;
  final Map<int, ColumnType> columnTypes;

  CoreSheetContent({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.cells,
    required this.columnTypes,
  });

  factory CoreSheetContent.empty({required int id}) {
    return CoreSheetContent(
      id: id,
      title: PageConstants.defaultSheetTitle,
      lastOpened: DateTime.now(),
      cells: {},
      columnTypes: {},
    );
  }
}
