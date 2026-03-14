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

  SelectionData({
    required this.selectedCells,
    required this.primarySelectedCell,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
  });

  SelectionData.empty()
      : selectedCells = [],
        primarySelectedCell = const Point<int>(0, 0),
        scrollOffsetX = 0.0,
        scrollOffsetY = 0.0;

  factory SelectionData.fromJson(Map<String, dynamic> json) => _$SelectionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SelectionDataToJson(this);
}