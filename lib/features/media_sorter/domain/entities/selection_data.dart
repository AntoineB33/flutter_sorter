import 'dart:math';
import 'package:flutter/foundation.dart';

class SelectionData {
  List<Point<int>> selectedCells;
  Point<int> primarySelectedCell;
  double scrollOffsetX;
  double scrollOffsetY;
  int tableViewRows;
  int tableViewCols;
  bool editingMode;
  String previousContent;

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCell,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.tableViewRows,
    required this.tableViewCols,
    required this.editingMode,
    required this.previousContent,
  });

  SelectionData.empty()
      : selectedCells = [],
        primarySelectedCell = Point<int>(0, 0),
        scrollOffsetX = 0.0,
        scrollOffsetY = 0.0,
        tableViewRows = 0,
        tableViewCols = 0,
        editingMode = false,
        previousContent = '';

  factory SelectionData.fromJson(Map<String, dynamic> json) {
    try {
      final pointMap = json['primarySelectedCell'] as Map<String, dynamic>;
      final primaryCell = Point<int>(
        pointMap['x'] as int,
        pointMap['y'] as int,
      );
      final selectedList = (json['selectedCells'] as List<dynamic>).map((item) {
        final itemMap = item as Map<String, dynamic>;
        return Point<int>(itemMap['x'] as int, itemMap['y'] as int);
      }).toList();
      return SelectionData(
        primarySelectedCell: primaryCell,
        selectedCells: selectedList,
        scrollOffsetX: (json['scrollOffsetX'] as num).toDouble(),
        scrollOffsetY: (json['scrollOffsetY'] as num).toDouble(),
        editingMode: json['editingMode'] as bool,
        previousContent: json['previousContent'] as String,
        tableViewRows: json['tableViewRows'] as int,
        tableViewCols: json['tableViewCols'] as int,
      );
    } catch (e) {
      debugPrint("Error parsing SelectionData from JSON: $e");
      return SelectionData.empty();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'primarySelectedCell': {
        'x': primarySelectedCell.x,
        'y': primarySelectedCell.y,
      },
      'selectedCells': selectedCells
          .map((point) => {'x': point.x, 'y': point.y})
          .toList(),
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
      'editingMode': editingMode,
      'previousContent': previousContent,
      'tableViewRows': tableViewRows,
      'tableViewCols': tableViewCols,
    };
  }
}
