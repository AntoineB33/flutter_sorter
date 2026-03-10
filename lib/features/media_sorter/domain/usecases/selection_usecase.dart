import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/utils_services.dart';

class SelectionUsecase {
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;

  SelectionUsecase(
    this.selectionRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
  );

  void stopEditing(String prevValue, {bool updateHistory = true}) {
    selectionRepository.stopEditing();
    if (updateHistory) {
      historyRepository.commitHistory(
        UpdateData(DateTime.now(), [
          CellUpdate(
            selectionUsecase.primarySelectedCell.x,
            selectionUsecase.primarySelectedCell.y,
            loadedSheetsDataStore.getCellContent(
              selectionUsecase.primarySelectedCell.x,
              selectionUsecase.primarySelectedCell.y,
            ),
            prevValue,
          ),
        ]),
      );
    }
  }

  void saveLastSelection() {
    selectionRepository.saveLastSelection();
  }

  Future<void> saveSelection({String? sheetId}) async {
    if (sheetId != null && sheetDataRepository.currentSheetId == sheetId) {
      selectionRepository.saveLastSelection();
    } else {
      selectionRepository.sheetSwitch();
    }
  }

  Future<void> getLastSelection() {
    return repository.getLastSelection();
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool scrollTo,
  ) {
    selectionRepository.setPrimarySelection(row, col, keepSelection);
    if (scrollTo) {
      gridRepository.scrollToCell(row, col);
    }
  }
}
