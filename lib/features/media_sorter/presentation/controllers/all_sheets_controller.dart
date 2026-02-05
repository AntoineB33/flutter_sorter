

import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart';

class AllSheetsController {
  List<String> sheetNames = [];

  final GetSheetDataUseCase _getDataUseCase;

  AllSheetsController(this._getDataUseCase) {
    init();
  }

  Future<void> init() async {
    try {
      sheetNames = await _getDataUseCase.getAllSheetNames();
    } catch (e) {
      debugPrint("Error initializing AllSheetsController: $e");
      sheetNames = [];
    }
  }
}