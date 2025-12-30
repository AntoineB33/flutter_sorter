import 'dart:math';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/nodes_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/side_menu_tree_builder.dart';
import 'spreadsheet_data_controller.dart';
import 'spreadsheet_selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';

class AnalysisController extends ChangeNotifier {
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  
  NodesUsecase nodesUsecase = NodesUsecase(AnalysisResult());
  SideMenuTreeBuilder? builder;

  // Dependencies
  SpreadsheetDataController? _dataController;
  SpreadsheetSelectionController? _selectionController;

  AnalysisResult analysisResult = AnalysisResult();

  final bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  void updateDependencies({
    required SpreadsheetDataController dataCtrl,
    required SpreadsheetSelectionController selCtrl,
  }) {
    bool dataChanged = _dataController != dataCtrl;
    bool selChanged = _selectionController != selCtrl;

    if (dataChanged) {
      if (_dataController != null) _dataController!.removeListener(_onDataChanged);
      _dataController = dataCtrl;
      _dataController!.addListener(_onDataChanged);
    }

    if (selChanged) {
      if (_selectionController != null) _selectionController!.removeListener(_onSelectionChanged);
      _selectionController = selCtrl;
      _selectionController!.addListener(_onSelectionChanged);
    }

    // Initial Run if needed
    if (dataChanged && !_dataController!.isLoading) {
      _runAnalysis();
    }
  }

  @override
  void dispose() {
    _dataController?.removeListener(_onDataChanged);
    _selectionController?.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onDataChanged() {
    // Re-run analysis when data changes
    _runAnalysis();
  }

  void _onSelectionChanged() {
    if (_selectionController != null && builder != null) {
      analysisResult.mentionsRoot.rowId = _selectionController!.selectionStart.x;
      analysisResult.mentionsRoot.colId = _selectionController!.selectionStart.y;
      
      // Update builder context
      builder!.selectionStart = _selectionController!.selectionStart;
      builder!.selectionEnd = _selectionController!.selectionEnd;
      
      builder!.populateTree([analysisResult.mentionsRoot]);
      notifyListeners();
    }
  }

  Future<void> _runAnalysis() async {
    if (_dataController == null || _dataController!.isLoading) return;
    
    // Snapshot data to avoid race conditions
    final currentTable = _dataController!.table;
    final currentTypes = _dataController!.columnTypes;

    _calculateExecutor.execute(
      () async {
        final calculateUsecase = CalculateUsecase(currentTable, currentTypes);
        return await compute(
          _isolateCalculator,
          calculateUsecase.getMessage(currentTable, currentTypes),
        );
      },
      onComplete: (AnalysisResult result) {
        _applyAnalysisResult(result);
      },
    );
  }

  static AnalysisResult _isolateCalculator(IsolateMessage message) {
    final Object dataPackage = switch (message) {
      RawDataMessage m => m.table,
      TransferableDataMessage m => m.dataPackage,
    };
    final worker = CalculateUsecase(dataPackage, message.columnTypes);
    return worker.run();
  }

  void _applyAnalysisResult(AnalysisResult result) {
    nodesUsecase = NodesUsecase(result);

    // Setup Mentions Context
    if (_selectionController != null) {
      analysisResult.mentionsRoot.rowId = _selectionController!.selectionStart.x;
      analysisResult.mentionsRoot.colId = _selectionController!.selectionStart.y;
    }

    // Instantiate Builder
    // Note: ensure SideMenuTreeBuilder uses _selectionController.selectCell internally
    builder = SideMenuTreeBuilder(
      table: _dataController!.table,
      columnTypes: _dataController!.columnTypes,
      nodesUsecase: nodesUsecase,
      tableToAtt: analysisResult.tableToAtt,
      attToRefFromAttColToCol: analysisResult.attToRefFromAttColToCol,
      attToRefFromDepColToCol: analysisResult.attToRefFromDepColToCol,
      rowToAtt: analysisResult.rowToAtt,
      toMentioners: analysisResult.toMentioners,
      instrTable: analysisResult.instrTable,
      colToAtt: analysisResult.colToAtt,
      attToCol: analysisResult.attToCol,
      nameIndexes: analysisResult.nameIndexes,
      pathIndexes: analysisResult.pathIndexes,
      selectionStart: _selectionController?.selectionStart ?? const Point(0,0),
      selectionEnd: _selectionController?.selectionEnd ?? const Point(0,0),
      onSelectCell: (r, c) => _selectionController?.selectCell(r, c),
    );

    builder!.populateTree([
      analysisResult.errorRoot,
      analysisResult.warningRoot,
      analysisResult.mentionsRoot,
      analysisResult.searchRoot,
      analysisResult.categoriesRoot,
      analysisResult.distPairsRoot,
    ]);

    notifyListeners();
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    if (builder != null) {
      builder!.populateTree([node]);
      notifyListeners();
    }
  }

  String getColumnLabel(int col) {
    return nodesUsecase.getColumnLabel(col);
  }
}