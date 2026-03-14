import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';

abstract class TreeRepository {
  void onTap(NodeStruct node);
  bool isRowValid(
    int rowId,
  );
  void populateAllTrees(
    NodeStruct mentionsRoot,
    NodeStruct searchRoot,
  );
  void populateTree(List<NodeStruct> roots);
  void onTapCellSelect(NodeStruct node);
}