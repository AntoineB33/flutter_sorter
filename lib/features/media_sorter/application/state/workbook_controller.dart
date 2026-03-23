import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
// Import AnalysisResult

class WorkbookController extends ChangeNotifier {
  // --- usecases ---
  final WorkbookUsecase workbookUseCase;
  final SortUsecase sortUseCase;
  final CalculationService calculationService = CalculationService();

  String get currentSheetId => workbookUseCase.currentSheetId;
  String get currentSheetName => workbookUseCase.currentSheetName;

  WorkbookController(
    this.workbookUseCase,
    this.sortUseCase,
  );

  Future<void> clearAllData() async {
    await workbookUseCase.clearAllData();
  }

  Future<void> loadRecentSheetIds() async {
    await workbookUseCase.loadRecentSheetIds();
    notifyListeners();
  }

  Future<void> loadLastSelections(bool success) async {
    await workbookUseCase.loadLastSelections(success);
    notifyListeners();
  }

  List<String> getRecentSheetIds() {
    return workbookUseCase.getRecentSheetIds();
  }

  Future<void> loadSheet(String name, bool init) async {
    workbookUseCase.loadSheet(name, init);
  }
}
