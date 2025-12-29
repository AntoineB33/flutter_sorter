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

class AnalysisController extends ChangeNotifier {
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  
  NodesUsecase nodesUsecase = NodesUsecase(AnalysisResult());
  late SideMenuTreeBuilder builder;
  
  // Dependencies
  SpreadsheetDataController? _dataController;
  SpreadsheetSelectionController? _selectionController;

  // Tree Roots
  final NodeStruct errorRoot = NodeStruct(instruction: SpreadsheetConstants.errorMsg, newChildren: [], hideIfEmpty: true);
  final NodeStruct warningRoot = NodeStruct(instruction: SpreadsheetConstants.warningMsg, newChildren: [], hideIfEmpty: true);
  final NodeStruct mentionsRoot = NodeStruct(instruction: SpreadsheetConstants.selectionMsg, newChildren: []);
  final NodeStruct searchRoot = NodeStruct(instruction: SpreadsheetConstants.searchMsg, newChildren: []);
  final NodeStruct categoriesRoot = NodeStruct(instruction: SpreadsheetConstants.categoryMsg, newChildren: []);
  final NodeStruct distPairsRoot = NodeStruct(instruction: SpreadsheetConstants.distPairsMsg, newChildren: []);

  // Analysis Data
  List<List<HashSet<Attribute>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<int>> attToCol = {};
  Map<Attribute, Map<int, List<int>>> attToRefFromAttColToCol = {};
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol = {};
  Map<int, HashSet<Attribute>> colToAtt = {};

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
    // Only update mentions part of the tree
    if (_selectionController != null) {
      mentionsRoot.rowId = _selectionController!.selectionStart.x;
      mentionsRoot.colId = _selectionController!.selectionStart.y;
      
      // Update builder context
      builder.selectionStart = _selectionController!.selectionStart;
      builder.selectionEnd = _selectionController!.selectionEnd;
      
      builder.populateTree([mentionsRoot]);
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
    
    // Update Roots
    errorRoot.newChildren = result.errorRoot.newChildren;
    warningRoot.newChildren = result.warningRoot.newChildren;
    mentionsRoot.newChildren = result.mentionsRoot.newChildren;
    searchRoot.newChildren = result.searchRoot.newChildren;
    categoriesRoot.newChildren = result.categoriesRoot.newChildren;
    distPairsRoot.newChildren = result.distPairsRoot.newChildren;

    // Update Maps
    tableToAtt = result.tableToAtt;
    names = result.names;
    attToCol = result.attToCol;
    attToRefFromAttColToCol = result.attToRefFromAttColToCol;
    attToRefFromDepColToCol = result.attToRefFromDepColToCol; 
    colToAtt = result.colToAtt;

    // Setup Mentions Context
    if (_selectionController != null) {
      mentionsRoot.rowId = _selectionController!.selectionStart.x;
      mentionsRoot.colId = _selectionController!.selectionStart.y;
    }

    // Instantiate Builder
    // Note: ensure SideMenuTreeBuilder uses _selectionController.selectCell internally
    builder = SideMenuTreeBuilder(
      table: _dataController!.table,
      columnTypes: _dataController!.columnTypes,
      nodesUsecase: nodesUsecase,
      tableToAtt: tableToAtt,
      attToRefFromAttColToCol: attToRefFromAttColToCol,
      attToRefFromDepColToCol: attToRefFromDepColToCol,
      colToAtt: colToAtt,
      attToCol: attToCol,
      selectionStart: _selectionController?.selectionStart ?? const Point(0,0),
      selectionEnd: _selectionController?.selectionEnd ?? const Point(0,0),
      onSelectCell: (r, c) => _selectionController?.selectCell(r, c),
    );

    builder.populateTree([
      errorRoot,
      warningRoot,
      mentionsRoot,
      searchRoot,
      categoriesRoot,
      distPairsRoot,
    ]);

    notifyListeners();
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    builder.populateTree([node]);
    notifyListeners();
  }

  String getColumnLabel(int col) {
    return nodesUsecase.getColumnLabel(col);
  }
}