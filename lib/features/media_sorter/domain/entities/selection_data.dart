import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/core/utils/json_converter.dart';

// Assuming you put the PointConverter in this file, or import it
part 'selection_data.g.dart'; 

@JsonSerializable(explicitToJson: true)
class SelectionData {
  @PointConverter()
  List<Point<int>> selectedCells;
  
  @PointConverter()
  Point<int> primarySelectedCell;
  
  double scrollOffsetX;
  double scrollOffsetY;
  bool editingMode;
  String previousContent;

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCell,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.editingMode,
    required this.previousContent,
  });

  SelectionData.empty()
      : selectedCells = [],
        primarySelectedCell = const Point<int>(0, 0),
        scrollOffsetX = 0.0,
        scrollOffsetY = 0.0,
        editingMode = false,
        previousContent = '';

  // Keep your try-catch safety net, but use the generated parser
  factory SelectionData.fromJson(Map<String, dynamic> json) {
    try {
      return _$SelectionDataFromJson(json);
    } catch (e) {
      debugPrint("Error parsing SelectionData from JSON: $e");
      return SelectionData.empty();
    }
  }

  Map<String, dynamic> toJson() => _$SelectionDataToJson(this);
}