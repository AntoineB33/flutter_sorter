import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';

abstract class GridRepository {
  LayoutData getLayout(int sheetId);
  
  List<SyncRequest> adjustRowHeightAfterUpdate(
    int sheetId,
    List<SyncRequest> updateData,
  );
  double getRowHeight(int sheetId, int rowId);
  int minRows(int sheetId, int rowCount, double height);
  int minCols(int sheetId, int colCount, double width);
  double getTargetLeft(int sheetId, int colId);
  double getTargetTop(int sheetId, int rowId);
  
  List<SyncRequest> setLayout(int sheetId, LayoutData layoutData);
}
