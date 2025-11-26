import 'package:flutter/material.dart';

enum ColumnType {
  defaultType(Colors.transparent),
  names(Colors.green),
  dependencies(Colors.red),
  sprawl(Colors.purple),
  attributes(Colors.orange),
  filePath(Colors.blue),
  url(Colors.cyan);

  final Color value;
  const ColumnType(this.value);
}
