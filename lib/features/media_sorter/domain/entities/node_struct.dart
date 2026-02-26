import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';

part 'node_struct.g.dart';

@JsonSerializable()
class NodeStruct {
  final String? instruction;
  String? message;
  Cell? cell;
  Attribute? att;
  int? rowId;
  int? colId;
  List<Cell>? cells;
  String? name;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children = [];
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  bool isExpanded = false;
  String? idOnTap;
  bool defaultOnTap = true;
  List<Cell>? cellsToSelect;

  NodeStruct({
    this.instruction,
    String? message,
    int? rowId,
    int? colId,
    String? name,
    this.att,
    Cell? cell,
    List<Cell>? cells,
    this.dist,
    this.minDist,
    this.newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  }) : rowId = att?.rowId ?? cell?.rowId ?? cells?.first.rowId ?? rowId,
       colId = att?.colId ?? cell?.colId ?? cells?.first.colId ?? colId,
       name = att?.name ?? name,
       message = message ?? instruction {
    if (this.rowId != null) {
      if (this.colId != null) {
        this.cell ??= Cell(rowId: this.rowId!, colId: this.colId!);
      }
      att ??= Attribute.row(this.rowId!);
    } else {
      if (this.colId != null) {
        att ??= Attribute(colId: this.colId, name: this.name);
      } else {
        if (this.name != null) {
          att ??= Attribute(name: this.name);
        }
      }
    }
    this.cells ??= cell != null ? [cell] : null;
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

  factory NodeStruct.fromJson(Map<String, dynamic> json) => _$NodeStructFromJson(json);

  Map<String, dynamic> toJson() => _$NodeStructToJson(this);
}