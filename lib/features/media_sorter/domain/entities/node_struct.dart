import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';

class NodeStruct {
  final String? instruction;
  String? message;
  Cell? cell;
  Attribute? att;
  int? rowId;
  int? colId;
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
  }) : rowId = att?.rowId ?? cell?.rowId ?? rowId,
       colId = att?.colId ?? cell?.colId ?? colId,
       name = att?.name ?? name,
       message = message ?? instruction {
    if (this.rowId != null) {
      if (this.colId != null) {
        this.cell ??= Cell(rowId: this.rowId!, colId: this.colId!);
      } else {
        this.att ??= Attribute(rowId: this.rowId, colId: 10);
      }
    } else {
      if (this.colId != null) {
        this.att ??= Attribute(colId: this.colId, name: this.name);
      } else {
        if (this.name != null) {
          this.att ??= Attribute(name: this.name);
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
          rowId == other.rowId &&
          colId == other.colId &&
          dist == other.dist &&
          minDist == other.minDist &&
          hideIfEmpty == other.hideIfEmpty &&
          startOpen == other.startOpen;

  @override
  int get hashCode =>
      instruction.hashCode ^
      message.hashCode ^
      rowId.hashCode ^
      colId.hashCode ^
      dist.hashCode ^
      minDist.hashCode ^
      hideIfEmpty.hashCode ^
      startOpen.hashCode;
}
