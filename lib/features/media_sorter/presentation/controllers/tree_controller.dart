import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/tree_usecase.dart';

class TreeController extends ChangeNotifier {
  final TreeUsecase treeUsecase;
  final SelectionUsecase selectionUsecase;

  // --- states ---
  NodeStruct get errorRoot => treeUsecase.errorRoot;
  NodeStruct get warningRoot => treeUsecase.warningRoot;
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );
  NodeStruct get categoriesRoot => treeUsecase.categoriesRoot;
  NodeStruct get distPairsRoot => treeUsecase.distPairsRoot;

  TreeController(this.treeUsecase, this.selectionUsecase);

  CellPosition onTapCellSelect(NodeStruct node) {
    return treeUsecase.onTapCellSelect(node);
  }

  // Method to allow Controller to toggle expansion
  void nodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    treeUsecase.populateTree([node]);
    notifyListeners();
  }

  void populateAllTrees() {
    treeUsecase.populateAllTrees(mentionsRoot, searchRoot);
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisAvailable() {
    clearMentionsRoot();
    clearSearchRoot();
    populateAllTrees();
  }

  void updateMentionsContext() {
    updateMentionsRoot();
    treeUsecase.populateTree([mentionsRoot]);
  }

  void clearMentionsRoot() {
    mentionsRoot.newChildren = null;
  }

  void updateMentionsRoot() {
    clearMentionsRoot();
    mentionsRoot.rowId = selectionUsecase.primarySelectedCellX;
    mentionsRoot.colId = selectionUsecase.primarySelectedCellY;
  }

  void clearSearchRoot() {
    searchRoot.newChildren = null;
  }
}
