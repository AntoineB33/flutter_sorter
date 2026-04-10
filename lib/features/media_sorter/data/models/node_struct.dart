import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/attribute.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

part 'node_struct.g.dart';

@JsonSerializable()
class NodeStruct {
  final String? instruction;
  String? message;
  CellPosition? cell;
  Attribute? att;
  int? rowId;
  int? colId;
  List<CellPosition>? cells;
  String? name;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children = [];
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  bool isExpanded = false;
  OnTapAction? idOnTap;
  bool defaultOnTap = true;
  List<CellPosition>? cellsToSelect;

  NodeStruct({
    this.instruction,
    String? message,
    int? rowId,
    int? colId,
    String? name,
    this.att,
    CellPosition? cell,
    List<CellPosition>? cells,
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
        this.cell ??= CellPosition(this.rowId!, this.colId!);
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

enum OnTapAction {
  selectCell,
  selectAttribute,
  cycle,
  defaultAction,
}