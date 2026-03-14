import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/tree_usecase.dart';

class TreeController extends ChangeNotifier {
  final TreeUsecase treeUsecase;

  // --- states ---
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );
  final Map<String, ManageWaitingTasks<void>> _saveResultExecutors = {};

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  TreeController({
    required this.treeUsecase,
  });

  void onTapCellSelect(NodeStruct node) {
    treeUsecase.onTapCellSelect(node);
  }

  void populateAllTrees() {
    treeUsecase.populateAllTrees(
      mentionsRoot,
      searchRoot,
    );
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisAvailable() {
    clearMentionsRoot();
    clearSearchRoot();
    populateAllTrees();
  }

  void updateMentionsContext(int row, int col) {
    updateMentionsRoot(row, col);
    treeUsecase.populateTree([mentionsRoot]);
  }

  void clearMentionsRoot() {
    mentionsRoot.newChildren = null;
  }

  void updateMentionsRoot(int row, int col) {
    clearMentionsRoot();
    mentionsRoot.rowId = row;
    mentionsRoot.colId = col;
  }

  void clearSearchRoot() {
    searchRoot.newChildren = null;
  }
}
