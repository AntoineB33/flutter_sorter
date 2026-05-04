import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';

class GridUsecase {
  final GridRepository gridRepository;
  final TreeRepository treeRepository;
  final HistoryRepository historyRepository;

  GridUsecase(this.gridRepository, this.treeRepository, this.historyRepository);

  LayoutData getLayout(int sheetId) {
    return gridRepository.getLayout(sheetId);
  }

  double getRowHeight(int sheetId, int rowId) {
    return gridRepository.getRowHeight(sheetId, rowId);
  }

  int minRows(int sheetId, int rowCount, double height) {
    return gridRepository.minRows(sheetId, rowCount, height);
  }

  int minCols(int sheetId, int colCount, double width) {
    return gridRepository.minCols(sheetId, colCount, width);
  }

  double getTargetLeft(int sheetId, int colId) {
    return gridRepository.getTargetLeft(sheetId, colId);
  }

  double getTargetTop(int sheetId, int rowId) {
    return gridRepository.getTargetTop(sheetId, rowId);
  }

  void adjustRowHeightAfterUpdate(int sheetId) {
    gridRepository.adjustRowHeightAfterUpdate(sheetId);
    historyRepository.scheduleCommit();
  }

  bool isRowValid(int rowId) {
    return treeRepository.isRowValid(rowId);
  }
}
