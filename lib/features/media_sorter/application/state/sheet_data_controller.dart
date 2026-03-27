import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';

class SheetDataController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;
  final WorkbookUsecase workbookUsecase;

  int get currentSheetId => workbookUsecase.currentSheetId;
  SheetContent get sheetContent =>
      sheetDataUsecase.getSheet(currentSheetId).sheetContent;

  SheetDataController(this.sheetDataUsecase, this.workbookUsecase);

  Future<Either<Failure, Map<Record, UpdateUnit>>> paste() {
    return sheetDataUsecase.paste();
  }

  Future<void> copyToClipboard() {
    return sheetDataUsecase.copyToClipboard();
  }

  bool isLoaded(int sheetId) {
    return sheetDataUsecase.containsSheetId(sheetId);
  }

  String getCellContentCurrentSheet(int row, int col) {
    return sheetDataUsecase.getCellContent(row, col, currentSheetId);
  }

  Map<Record, UpdateUnit> delete() {
    return sheetDataUsecase.delete();
  }

  void applyUpdatesNoSort(
    Map<Record, UpdateUnit> updates,
    int sheetId,
    bool isFromHistory,
    bool isFromEditing,
  ) {
    sheetDataUsecase.applyUpdatesNoSort(
      updates,
      sheetId,
      isFromHistory,
      isFromEditing,
    );
  }

  void save(Map<Record, UpdateUnit> updates) {
    sheetDataUsecase.save(updates);
  }
}
