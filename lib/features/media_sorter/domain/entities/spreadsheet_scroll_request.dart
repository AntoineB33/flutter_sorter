
import 'dart:math';

class SpreadsheetScrollRequest {
  final Point<int>? cell;
  final double? offsetX;
  final double? offsetY;
  final bool animate;

  SpreadsheetScrollRequest.toCell(this.cell)
      : offsetX = null,
        offsetY = null,
        animate = true;

  SpreadsheetScrollRequest.toOffset({this.offsetX, this.offsetY, this.animate = false})
      : cell = null;
}
