import 'dart:math';
import 'package:flutter/foundation.dart';

class SelectionModel {
  List<Point<int>> selectedCells = [];
  Point<int> primarySelectedCell = Point<int>(0, 0);
  double scrollOffsetX = 0.0;
  double scrollOffsetY = 0.0;
  int rowCount = 0;
  int colCount = 0;

  SelectionModel({
    required this.selectedCells,
    required this.primarySelectedCell,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.rowCount,
    required this.colCount,
  });

  SelectionModel.empty();

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
        scrollOffsetX: (json['scrollOffsetX'] as num).toDouble(),
        scrollOffsetY: (json['scrollOffsetY'] as num).toDouble(),
        rowCount: json['rowCount'] as int,
        colCount: json['colCount'] as int,
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
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
      'rowCount': rowCount,
      'colCount': colCount,
    };
  }
}