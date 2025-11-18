import 'package:flutter/material.dart';

class ColumnType {
  final String name;
  final Color color;

  const ColumnType(this.name, this.color);
}

class ColumnTypes {
  static const defaultType = ColumnType('Default', Colors.transparent);

  static const Map<String, Color> columnTypes = {
    'Default': Colors.transparent,
    'Number': Colors.lightBlueAccent,
    'Text': Colors.amberAccent,
    'Date': Colors.lightGreenAccent,
    'Currency': Colors.pinkAccent,
    'Boolean': Colors.deepPurpleAccent,
  };
}