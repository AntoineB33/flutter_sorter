import 'package:flutter/material.dart';

enum ColumnType {
  defaultType(Colors.transparent),
  names(Colors.green),
  path(Colors.blue),
  attributes(Colors.orange),
  sprawl(Colors.purple),
  dependencies(Colors.red);

  final Color value;
  const ColumnType(this.value);
}
