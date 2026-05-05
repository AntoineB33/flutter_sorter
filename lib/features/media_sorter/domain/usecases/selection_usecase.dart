import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SelectionUsecase {
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;
  final WorkbookRepository workbookRepository;

  int get primarySelectedCellX => selectionRepository.primarySelectedCellX;
  int get primarySelectedCellY => selectionRepository.primarySelectedCellY;
  int get currentSheetId => workbookRepository.currentSheetId;
  Set<CellPosition> get selectedCells =>
      selectionRepository.selectedCells;

  SelectionUsecase(
    this.selectionRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
    this.workbookRepository,
  );

  void selectAll() {
    selectionRepository.selectAll();
  }

  void setPrimarySelection(int row, int col, bool keepSelection) {
    selectionRepository.setPrimarySelection(row, col, keepSelection);
    historyRepository.scheduleCommit();
  }
}
