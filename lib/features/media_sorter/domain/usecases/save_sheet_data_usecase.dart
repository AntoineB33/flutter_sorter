import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

import '../repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';

class SaveSheetDataUseCase {
  final SheetRepository repository;

  SaveSheetDataUseCase(this.repository);

  Future<void> initialize() async {
    for (String fileName in [
      SpreadsheetConstants.sheetsIndexFileName,
      SpreadsheetConstants.allLastSelectedFileName,
    ]) {
      await repository.createFile(fileName);
    }
  }

  Future<void> saveLastSelection(SelectionModel selection) {
    return repository.saveLastSelection(selection);
  }

  Future<void> saveSheet(String sheetName, SheetModel sheet) {
    return repository.updateSheet(sheetName, sheet);
  }

  Future<void> saveLastOpenedSheetName(String sheetName) {
    // Assuming the repository has a method to save the last opened sheet name
    return repository.saveLastOpenedSheetName(sheetName);
  }

  Future<void> saveAllSheetNames(List<String> sheetNames) {
    // Assuming the repository has a method to save all sheet names
    // You might need to implement this method in the repository if it doesn't exist
    return repository.saveAllSheetNames(sheetNames);
  }

  Future<void> saveAllLastSelected(Map<String, SelectionModel> cells) {
    return repository.saveAllLastSelected(cells);
  }

  Future<void> clearAllData() {
    return repository.clearAllData();
  }
}
