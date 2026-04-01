import 'dart:async';

import 'package:path/path.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SelectionUsecase {
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;
  final GridRepository gridRepository;
  final HistoryRepository historyRepository;
  final WorkbookRepository workbookRepository;
  final SaveRepository saveRepository;

  int get primarySelectedCellX => selectionRepository.primarySelectedCellX;
  int get primarySelectedCellY => selectionRepository.primarySelectedCellY;
  int get currentSheetId => workbookRepository.currentSheetId;

  SelectionUsecase(
    this.selectionRepository,
    this.sheetDataRepository,
    this.gridRepository,
    this.historyRepository,
    this.workbookRepository,
    this.saveRepository,
  );

  void selectAll() {
    final update = selectionRepository.selectAll();
    saveRepository.saveUpdate(update);
  }

  SelectionData getSelectionData(int sheetId) {
    return selectionRepository.getSelectionData(sheetId);
  }

  Future<SelectionData> getLastSelection() async {
    return selectionRepository.getSelectionData(
      workbookRepository.currentSheetId,
    );
  }
}
