import 'dart:convert';
import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'dart:io';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_message.dart';

class CalculationService {
  Future<AnalysisResult> runCalculation(SheetContent sheetContent) async {
    return compute(
      _isolateHandler,
      getMessage(sheetContent),
    );
  }
  
  IsolateMessage getMessage(SheetContent sheetContent) {
    if (sheetContent.table.length < 5000) {
      return IsolateMessage(Right(sheetContent.table), sheetContent.columnTypes, sheetContent.sourceColIndices);
    } else {
      final String combined = jsonEncode(sheetContent.table);
      final Uint8List bytes = utf8.encode(combined);
      final transferable = TransferableTypedData.fromList([bytes]);
      return IsolateMessage(Left(transferable), sheetContent.columnTypes, sheetContent.sourceColIndices);
    }
  }

  static AnalysisResult _isolateHandler(IsolateMessage message) {
    sleep(Duration(milliseconds: SpreadsheetConstants.debugDelayMs));
    final worker = CalculateUsecase(message);
    return worker.run();
  }
}