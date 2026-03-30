import 'dart:math';

import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';

class TreeUsecase {
  final TreeRepository treeRepository;

  NodeStruct get errorRoot => treeRepository.errorRoot;
  NodeStruct get warningRoot => treeRepository.warningRoot;
  NodeStruct get categoriesRoot => treeRepository.categoriesRoot;
  NodeStruct get distPairsRoot => treeRepository.distPairsRoot;

  TreeUsecase(this.treeRepository);

  CellPosition onTapCellSelect(NodeStruct node) {
    return treeRepository.onTapCellSelect(node);
  }

  void populateTree(List<NodeStruct> roots) {
    treeRepository.populateTree(roots);
  }

  void populateAllTrees(NodeStruct mentionsRoot, NodeStruct searchRoot) {
    treeRepository.populateAllTrees(mentionsRoot, searchRoot);
  }
}
