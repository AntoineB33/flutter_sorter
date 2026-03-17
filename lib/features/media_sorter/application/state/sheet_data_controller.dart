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
  
    String get currentSheetId => workbookUsecase.currentSheetId;
  SheetContent get sheetContent => sheetDataUsecase.getSheet(currentSheetId).sheetContent;

  SheetDataController(this.sheetDataUsecase, this.workbookUsecase);

  Future<Either<Failure, List<CellUpdate>>> paste() {
    return sheetDataUsecase.paste();
  }

  Future<void> copyToClipboard() {
    return sheetDataUsecase.copyToClipboard();
  }

  bool isLoaded(String sheetId) {
    return sheetDataUsecase.containsSheetId(sheetId);
  }

  String getCellContentCurrentSheet(int row, int col) {
    return sheetDataUsecase.getCellContent(row, col, currentSheetId);
  }

  List<CellUpdate> delete() {
    return sheetDataUsecase.delete();
  }

  void applyUpdatesNoSort(
    List<UpdateUnit> updates,
    String sheetId,
    bool isFromHistory,
      bool isFromEditing,
  ) {
    sheetDataUsecase.applyUpdatesNoSort(updates, sheetId, isFromHistory, isFromEditing);
  }
}
