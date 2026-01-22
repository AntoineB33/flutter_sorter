import 'dart:async';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';

class SpreadsheetStreamController {
  // --- Scroll Stream Controller ---
  final StreamController<SpreadsheetScrollRequest> _scrollController =
      StreamController<SpreadsheetScrollRequest>.broadcast();
  Stream<SpreadsheetScrollRequest> get scrollStream => _scrollController.stream;

  SpreadsheetStreamController();

  void dispose() {
    _scrollController.close();
  }

  void triggerScrollTo(int row, int col) {
    _scrollController.add(SpreadsheetScrollRequest.toCell(Point(row, col)));
  }

  void scrollToOffset({double? x, double? y, bool animate = false}) {
    _scrollController.add(
      SpreadsheetScrollRequest.toOffset(
        offsetX: x,
        offsetY: y,
        animate: animate,
      ),
    );
  }
}