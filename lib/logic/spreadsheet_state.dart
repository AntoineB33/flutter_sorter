import 'package:flutter/material.dart';
import '../data/models/cell.dart';

class SpreadsheetState extends ChangeNotifier {
  Cell? _selectedCell;

  Cell? get selectedCell => _selectedCell;

  void selectCell(Cell cell) {
    _selectedCell = cell;
    notifyListeners();
  }

  String get cellInfo {
    if (_selectedCell == null) return "No cell selected";

    return "Selected Cell:\n"
           "Row: ${_selectedCell!.row}\n"
           "Column: ${_selectedCell!.col}\n"
           "Value: ${_selectedCell!.value}";
  }
}
