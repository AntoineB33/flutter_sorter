import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';

class DynAndInt {
  dynamic dyn;
  int id;

  DynAndInt(this.dyn, this.id);
}

class AttAndCol {
  final String name;
  final int row;
  final int col;

  const AttAndCol({this.row = SpreadsheetConstants.all, this.col = SpreadsheetConstants.all, this.name = ""});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttAndCol && name == other.name && row == other.row && col == other.col;
  }

  @override
  int get hashCode => Object.hash(name, row, col);
}
