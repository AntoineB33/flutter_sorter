import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<SelectionModel> getLastSelection() {
    return repository.getLastSelection();
  }

  Future<String> getLastOpenedSheetName() {
    return repository.getLastOpenedSheetName();
  }

  Future<List<String>> getAllSheetNames() {
    return repository.getAllSheetNames();
  }

  Future<Map<String, SelectionModel>> getAllLastSelected() async {
    return await repository.getAllLastSelected();
  }

  Future<SheetModel> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
