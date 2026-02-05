

import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';

class SheetController extends ChangeNotifier {
  final WorkbookController _workbook;

  SheetController(this._workbook) {
    // When the workbook switches sheets, this sub-controller 
    // also needs to notify its UI listeners to repaint.
    _workbook.addListener(notifyListeners);
  }
}