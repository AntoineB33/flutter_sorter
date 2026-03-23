import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class SelectionData {
  final List<Point<int>> selectedCells;
  int primarySelectedCellX;
  int primarySelectedCellY;

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCellX,
    required this.primarySelectedCellY,
  });

  SelectionData.empty()
      : selectedCells = [],
        primarySelectedCellX = 0,
        primarySelectedCellY = 0;
}