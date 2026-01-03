import 'dart:math';
import 'package:flutter/foundation.dart';

class SelectionModel {
  List<Point<int>> selectedCells;
  Point<int> primarySelectedCell;

  SelectionModel({
    required this.selectedCells,
    required this.primarySelectedCell,
  });

  SelectionModel.empty()
      : selectedCells = [],
        primarySelectedCell = Point<int>(0, 0);

  factory SelectionModel.fromJson(Map<String, dynamic> json) {
    try {
      final pointMap = json['primarySelectedCell'] as Map<String, dynamic>;
      final primaryCell = Point<int>(pointMap['x'] as int, pointMap['y'] as int);
      final selectedList = (json['selectedCells'] as List<dynamic>)
          .map((item) {
            final itemMap = item as Map<String, dynamic>;
            return Point<int>(itemMap['x'] as int, itemMap['y'] as int);
          })
          .toList();
      return SelectionModel(
        primarySelectedCell: primaryCell,
        selectedCells: selectedList,
      );
    } catch (e) {
      debugPrint("Error parsing SelectionModel from JSON: $e");
      return SelectionModel.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'primarySelectedCell': {
        'x': primarySelectedCell.x,
        'y': primarySelectedCell.y,
      },
      'selectedCells': selectedCells
          .map((point) => {
                'x': point.x,
                'y': point.y,
              })
          .toList(),
    };
  }
}