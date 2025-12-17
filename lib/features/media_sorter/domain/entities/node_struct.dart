import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';

class NodeStruct {
  final String instruction;
  String? message;
  final int? row;
  final int? col;
  final AttAndCol? att;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children = [];
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  int depth = 0; // 0 if expanded, 1 if shown but not expanded, 2 if hidden but parent is shown, 3 otherwise

  NodeStruct({
    required this.instruction,
    this.message,
    this.row,
    this.col,
    this.att,
    this.dist,
    this.minDist,
    this.newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  }) : depth = startOpen ? 0 : 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeStruct &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          att == other.att &&
          dist == other.dist &&
          minDist == other.minDist &&
          hideIfEmpty == other.hideIfEmpty &&
          startOpen == other.startOpen;
  
  @override
  int get hashCode =>
      message.hashCode ^
      att.hashCode ^
      dist.hashCode ^
      minDist.hashCode ^
      hideIfEmpty.hashCode ^
      startOpen.hashCode;
}
