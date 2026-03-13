import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
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

  SelectionUsecase(
    this.selectionRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
    this.workbookRepository,
  );

  SelectionData getSelectionData(String sheetId) {
    return selectionRepository.getSelectionData(sheetId);
  }

  void stopEditing(String prevValue, bool updateHistory) {
    selectionRepository.stopEditing();
    if (updateHistory) {
      historyRepository.stopEditing(prevValue);
    }
  }

  void saveLastSelection() {
    selectionRepository.saveLastSelection();
  }

  Future<void> saveSelection({String? sheetId}) async {
    if (sheetId != null && workbookRepository.currentSheetId == sheetId) {
      selectionRepository.saveLastSelection();
    } else {
      selectionRepository.sheetSwitch();
    }
  }

  Future<SelectionData> getLastSelection() async {
    return selectionRepository.getSelectionData(workbookRepository.currentSheetId);
  }

}
