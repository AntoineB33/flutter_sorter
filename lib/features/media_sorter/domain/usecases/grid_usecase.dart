import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';

class GridUsecase {
  final GridRepository gridRepository;
  final TreeRepository treeRepository;

  GridUsecase(this.gridRepository, this.treeRepository);

  int minRows(String sheetId, int rowCount, double height) {
    return gridRepository.minRows(sheetId, rowCount, height);
  }

  int minCols(String sheetId, int colCount, double width) {
    return gridRepository.minCols(sheetId, colCount, width);
  }

  double getTargetLeft(String sheetId, int colId) {
    return gridRepository.getTargetLeft(sheetId, colId);
  }

  double getTargetTop(String sheetId, int rowId) {
    return gridRepository.getTargetTop(sheetId, rowId);
  }

  void adjustRowHeightAfterUpdate(String sheetId, List<UpdateUnit> updateData) {
    gridRepository.adjustRowHeightAfterUpdate(sheetId, updateData);
  }
  
  bool isRowValid(
    String sheetId,
    int rowId,
  ) {
    return treeRepository.isRowValid(
    sheetId,
    rowId,
  );
  }

}