import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
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

  CoreSheetContent getCurrentSheet() {
    return sheetDataUsecase.getSheet(currentSheetId);
  }

  Future<Either<Failure, Unit>> paste() {
    return sheetDataUsecase.paste();
  }

  Future<void> copyToClipboard() {
    return sheetDataUsecase.copyToClipboard();
  }

  String getCellContentCurrentSheet(int row, int col) {
    return sheetDataUsecase.getCellContent(row, col, currentSheetId);
  }

  void setColumnType(int colId, ColumnType newColumnType) {
    sheetDataUsecase.setColumnType(colId, newColumnType, currentSheetId);
  }

  void delete() {
    sheetDataUsecase.delete();
  }

  void applyUpdatesNoSort(int sheetId, bool isFromHistory, bool isFromEditing, bool sameHistIdFromLast) {
    sheetDataUsecase.applyUpdatesNoSort(sheetId, isFromHistory, isFromEditing, sameHistIdFromLast);
  }

  void setCellUpdate(String newValue) {
    sheetDataUsecase.setCellUpdate(newValue);
  }
}
