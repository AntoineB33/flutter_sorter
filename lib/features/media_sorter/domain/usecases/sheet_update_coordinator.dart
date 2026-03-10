import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/grid_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SheetUpdateCoordinator {
  final SheetDataRepository _sheetDataRepository;
  final GridRepository _gridRepository;
  final HistoryRepository _historyRepository;
  final SortRepository _sortRepository;

  SheetUpdateCoordinator(
    this._sheetDataRepository,
    this._gridRepository,
    this._historyRepository,
    this._sortRepository,
  );

  void applyUpdates(List<UpdateUnit> updates, String sheetId, bool isFromHistory, bool isFromSort) {
    _sheetDataRepository.update(updates, sheetId);
    _gridRepository.adjustRowHeightAfterUpdate(sheetId, updates);
    if (!isFromHistory) {
      _historyRepository.commitHistory(updates, sheetId);
    }
    if (!isFromSort) {
      _sortRepository.calculateOnChange();
    }
  }
}