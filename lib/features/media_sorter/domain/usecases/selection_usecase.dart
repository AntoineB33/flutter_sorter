import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';

class SelectionUsecase {
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;

  Stream<String> get updateData => selectionRepository.updateData;

  SelectionUsecase(this.selectionRepository, this.sheetDataRepository);
  
  Future<void> saveSelection(String sheetId) async {
    if (sheetDataRepository.currentSheetId == sheetId) {
      selectionRepository.saveLastSelection();
    } else {
      selectionRepository.saveAllLastSelected();
    }
  }
}