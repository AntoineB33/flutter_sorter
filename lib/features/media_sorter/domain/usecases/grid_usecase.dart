import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/layout_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';

class GridUsecase {
  final GridRepository gridRepository;
  final TreeRepository treeRepository;
  final SaveRepository saveRepository;

  GridUsecase(this.gridRepository, this.treeRepository, this.saveRepository);

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

  void adjustRowHeightAfterUpdate(
    int sheetId,
    IMap<String, UpdateUnit> updateData,
  ) {
    saveRepository.save(
      gridRepository.adjustRowHeightAfterUpdate(sheetId, updateData),
    );
  }

  bool isRowValid(int rowId) {
    return treeRepository.isRowValid(rowId);
  }
}
