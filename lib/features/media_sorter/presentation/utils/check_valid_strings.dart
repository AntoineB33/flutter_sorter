import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';

class CheckValidStrings {
  static bool isValidSheetName(String name) {
    return name.isNotEmpty &&
        !name.contains(RegExp(r'[\\/:*?"<>|]')) &&
        name != SpreadsheetConstants.noSPNameFound;
  }
}