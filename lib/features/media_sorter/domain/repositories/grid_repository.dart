import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class GridRepository {
  bool adjustRowHeightAfterUpdate(String sheetId, List<UpdateUnit> updateData);
  int minRows(String sheetId, int rowCount, double height);
  int minCols(String sheetId, int colCount, double width);
  bool isRowValid(
    int rowId,
  );
  double getTargetLeft(String sheetId, int colId);
  double getTargetTop(String sheetId, int rowId);
}