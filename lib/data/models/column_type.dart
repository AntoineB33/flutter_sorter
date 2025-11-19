import 'package:flutter/material.dart';

enum ColumnType {
  defaultType(Colors.transparent),
  green(Colors.green),
  blue(Colors.blue);

  final Color value;
  const ColumnType(this.value);
}
