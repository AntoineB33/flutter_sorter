
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class TreeRepository {
  NodeStruct get errorRoot;
  NodeStruct get warningRoot;
  NodeStruct get categoriesRoot;
  NodeStruct get distPairsRoot;
  bool isRowValid(int rowId);
  void populateAllTrees(NodeStruct mentionsRoot, NodeStruct searchRoot);
  void populateTree(List<NodeStruct> roots);
  CellPosition onTapCellSelect(NodeStruct node);
}
