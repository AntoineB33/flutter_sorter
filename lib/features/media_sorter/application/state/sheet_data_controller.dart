import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';

class SheetDataController extends ChangeNotifier {
  final SheetDataUsecase sheetDataUsecase;
  final WorkbookUsecase workbookUsecase;

  int get currentSheetId => workbookUsecase.currentSheetId;

  SheetDataController(this.sheetDataUsecase, this.workbookUsecase);

  CoreSheetContent getSheet(int sheetId) {
    return sheetDataUsecase.getSheet(sheetId);
  }

  Future<Either<Failure, Map<String, UpdateUnit>>> paste() {
    return sheetDataUsecase.paste();
  }

  Future<void> copyToClipboard() {
    return sheetDataUsecase.copyToClipboard();
  }

  String getCellContentCurrentSheet(int row, int col) {
    return sheetDataUsecase.getCellContent(row, col, currentSheetId);
  }

  void delete() {
    sheetDataUsecase.delete();
  }

  void applyUpdatesNoSort(
    Map<String, UpdateUnit> updates,
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

  void save(Map<String, UpdateUnit> updates) {
    sheetDataUsecase.save(updates);
  }
}
