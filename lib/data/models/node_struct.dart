class NodeStruct {
  final String? message;
  final int? id;
  final int? col;
  final int? att;
  final int? dist;
  final int? minDist;
  List<NodeStruct> children;
  List<NodeStruct>? newChildren;
  final bool hideIfEmpty;
  final bool startOpen;
  int depth;

  NodeStruct({
    this.message,
    this.id,
    this.col,
    this.att,
    this.dist,
    this.minDist,
    List<NodeStruct>? newChildren,
    this.hideIfEmpty = false,
    this.startOpen = false,
  })  : children = [],
        depth = startOpen ? 0 : 1;
}
