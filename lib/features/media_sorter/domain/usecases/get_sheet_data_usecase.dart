import 'package:crypto/crypto.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<SelectionData> getLastSelection() {
    return repository.getLastSelection();
  }

  Future<String?> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<List<String>> getAllSheetNames() {
    return repository.getAllSheetNames();
  }

  Future<Map<String, SelectionData>> getAllLastSelected() async {
    return await repository.getAllLastSelected();
  }

  Future<SheetData> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
