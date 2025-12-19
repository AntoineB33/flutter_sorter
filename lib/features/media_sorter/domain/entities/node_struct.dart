import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';

class NodeStruct {
  final String? instruction;
  String? message;
  int? row;
  int? col;
  String? name;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children = [];
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  int depth =
      0; // 0 if expanded, 1 if shown but not expanded, 2 if hidden but parent is shown, 3 otherwise
  void Function(NodeStruct) onTap = (_) {};

  static const _undefined = Object();

  NodeStruct({
    this.instruction,
    String? message,
    int? row,
    int? col,
    String? name,
    CellWithName? cellWithName,
    Cell? cell,
    this.dist,
    this.minDist,
    this.newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  }) : depth = startOpen ? 0 : 1,
       row = cellWithName?.row ?? cell?.row ?? row,
       col = cellWithName?.col ?? cell?.col ?? col,
       name = cellWithName?.name ?? name,
       message = message ?? instruction;

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
