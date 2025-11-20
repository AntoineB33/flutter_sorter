import 'package:flutter/material.dart';

enum ColumnType {
  defaultType(Colors.transparent),
  names(Colors.green),
  path(Colors.blue);

  final Color value;
  const ColumnType(this.value);
}
