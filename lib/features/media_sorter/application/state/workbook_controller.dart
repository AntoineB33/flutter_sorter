import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/calculation_service.dart';
// Import AnalysisResult

class WorkbookController extends ChangeNotifier {
  // --- usecases ---
  final WorkbookUsecase workbookUseCase;
  final SortUsecase sortUseCase;
  final CalculationService calculationService = CalculationService();

  int get currentSheetId => workbookUseCase.currentSheetId;
  String get currentSheetName => workbookUseCase.currentSheetName;

  WorkbookController(this.workbookUseCase, this.sortUseCase);

  Future<void> clearAllData() async {
    await workbookUseCase.clearAllData();
  }

  Future<void> loadRecentSheetIds() async {
    await workbookUseCase.loadRecentSheetIds();
  }

  List<int> getRecentSheetIds() {
    return workbookUseCase.getRecentSheetIds();
  }

  Future<Either<Failure, Unit>> loadSheet(int sheetId, bool init) async {
    return workbookUseCase.loadSheet(sheetId, init);
  }

  Future<void> createSheetByName(String name) async {
    workbookUseCase.createSheetByName(name);
  }
}
