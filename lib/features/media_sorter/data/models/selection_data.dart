import 'dart:math';
import 'package:flutter/foundation.dart';

class SelectionData {
  List<Point<int>> selectedCells = [];
  Point<int> primarySelectedCell = Point<int>(0, 0);
  double scrollOffsetX = 0.0;
  double scrollOffsetY = 0.0;
  int tableViewRows = 0;
  int tableViewCols = 0;
  bool editingMode = false;
  String previousContent = '';
  bool findingBestSort = false;

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCell,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.editingMode,
    required this.previousContent,
    required this.findingBestSort,
  });

  SelectionData.empty();

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
        findingBestSort: json['findingBestSort'] as bool,
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
      'findingBestSort': findingBestSort,
    };
  }
}
