import 'package:trying_flutter/data/models/dyn_and_int.dart';

class NodeStruct {
  final String? message;
  final int? row;
  final int? col;
  final AttAndCol? att;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children;
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  int
  depth; // 0 if expanded, 1 if shown but not expanded, 2 if hidden but parent is shown, 3 otherwise

  NodeStruct({
    this.message,
    this.row,
    this.col,
    this.att,
    this.dist,
    this.minDist,
    List<NodeStruct>? newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  }) : children = [],
       depth = startOpen ? 0 : 1;
}
