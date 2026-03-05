import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data/sheet_save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class WorkbookUseCase {
  final WorkbookRepository workbookRepository;
  final SheetSaveRepository saveSheetRepository;
  final SelectionRepository selectionRepository;

  WorkbookUseCase(this.workbookRepository, this.saveSheetRepository, this.selectionRepository);

  void init() {
    workbookRepository.init();
    saveSheetRepository.getAllLastSelected();
    selectionRepository.init();
  }
}