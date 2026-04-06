import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/core/entities/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class GridRepository {
  LayoutData getLayout(int sheetId);
  @useResult
  ChangeSet adjustRowHeightAfterUpdate(int sheetId, IMap<String, UpdateUnit> updateData);
  double getRowHeight(int sheetId, int rowId);
  int minRows(int sheetId, int rowCount, double height);
  int minCols(int sheetId, int colCount, double width);
  double getTargetLeft(int sheetId, int colId);
  double getTargetTop(int sheetId, int rowId);
  void setLayout(int sheetId, LayoutData layoutData);
}
