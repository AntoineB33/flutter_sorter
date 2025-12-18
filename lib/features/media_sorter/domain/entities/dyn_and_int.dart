import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';

class DynAndInt {
  dynamic dyn;
  int id;

  DynAndInt(this.dyn, this.id);
}

class CellWithName {
  final String? name;
  final int? row;
  final int? col;

  const CellWithName({this.name, this.row, this.col});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CellWithName &&
        name == other.name &&
        row == other.row &&
        col == other.col;
  }

  @override
  int get hashCode => Object.hash(name, row, col);
}
