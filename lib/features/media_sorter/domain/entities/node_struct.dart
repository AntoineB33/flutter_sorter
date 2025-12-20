import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';

class NodeStruct {
  final String? instruction;
  String? message;
  Cell? cell;
  Attribute? att;
  int? row;
  int? col;
  String? name;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children = [];
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  bool isExpanded = false;
  void Function(NodeStruct) onTap = (_) {};

  NodeStruct({
    this.instruction,
    String? message,
    int? rowId,
    int? colId,
    String? name,
    Attribute? att,
    Cell? cell,
    Attribute? attribute,
    this.dist,
    this.minDist,
    this.newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  }) : row = att?.row ?? cell?.row ?? rowId,
       col = att?.col ?? cell?.col ?? colId,
       name = att?.name ?? name,
       message = message ?? instruction {
    if (row != null) {
      if (col != null) {
        this.cell ??= Cell(row: row!, col: col!);
      } else {
        this.att ??= Attribute(row: row);
      }
    } else {
      if (col != null) {
        this.att ??= Attribute(col: col, name: name);
      } else {
        if (name != null) {
          this.att ??= Attribute(name: name);
        }
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeStruct &&
          runtimeType == other.runtimeType &&
          instruction == other.instruction &&
          message == other.message &&
          row == other.row &&
          col == other.col &&
          dist == other.dist &&
          minDist == other.minDist &&
          hideIfEmpty == other.hideIfEmpty &&
          startOpen == other.startOpen;

  @override
  int get hashCode =>
      instruction.hashCode ^
      message.hashCode ^
      row.hashCode ^
      col.hashCode ^
      dist.hashCode ^
      minDist.hashCode ^
      hideIfEmpty.hashCode ^
      startOpen.hashCode;
}
