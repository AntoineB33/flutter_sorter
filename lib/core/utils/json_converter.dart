import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

class PointConverter implements JsonConverter<Point<int>, Map<String, dynamic>> {
  const PointConverter();

  @override
  Point<int> fromJson(Map<String, dynamic> json) {
    return Point<int>(json['x'] as int, json['y'] as int);
  }

  @override
  Map<String, dynamic> toJson(Point<int> object) {
    return {'x': object.x, 'y': object.y};
  }
}