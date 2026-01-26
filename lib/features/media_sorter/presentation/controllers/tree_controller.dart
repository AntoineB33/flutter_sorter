import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';

class TreeController extends ChangeNotifier {
  // --- states ---
  AnalysisResult _lastAnalysis = AnalysisResult.empty();
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );

  // --- getters ---
  NodeStruct get errorRoot => _lastAnalysis.errorRoot;
  NodeStruct get warningRoot => _lastAnalysis.warningRoot;
  NodeStruct get categoriesRoot => _lastAnalysis.categoriesRoot;
  NodeStruct get distPairsRoot => _lastAnalysis.distPairsRoot;
  List<List<HashSet<Attribute>>> get tableToAtt => _lastAnalysis.tableToAtt;
  Map<String, Cell> get names => _lastAnalysis.names;
  Map<String, List<int>> get attToCol => _lastAnalysis.attToCol;
  List<int> get pathIndexes => _lastAnalysis.pathIndexes;
  Map<Attribute, Map<int, Cols>> get attToRefFromAttColToCol =>
      _lastAnalysis.attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> get attToRefFromDepColToCol =>
      _lastAnalysis.attToRefFromDepColToCol;
  List<HashSet<int>> get rowToRefFromAttCol => _lastAnalysis.rowToRefFromAttCol;
  List<List<List<rowIdIdentifier>>> get splittedTable =>
      _lastAnalysis.splittedTable;
  List<Map<InstrStruct, Cell>> get instrTable => _lastAnalysis.instrTable;
  Map<int, HashSet<Attribute>> get colToAtt => _lastAnalysis.colToAtt;
  List<int> get validRowIndexes => _lastAnalysis.validRowIndexes;
  List<List<String>> get formatedTable => _lastAnalysis.formatedTable;
  List<int> get nameIndexes => _lastAnalysis.nameIndexes;
  bool get noResult => _lastAnalysis.noResult;

  // --- setters ---
  set lastAnalysis(AnalysisResult analysisResult) {
    _lastAnalysis = analysisResult;
  }

  set mentionsRootChildren(List<NodeStruct>? children) {
    mentionsRoot.newChildren = children;
  }

  set mentionsRootRowId(int rowId) {
    mentionsRoot.rowId = rowId;
  }

  set mentionsRootColId(int colId) {
    mentionsRoot.colId = colId;
  }

  set searchRootChildren(List<NodeStruct>? children) {
    searchRoot.newChildren = children;
  }

  TreeController();

  // --- LOGIC ---

  void populateAttToRefFromDepColNode(NodeStruct node, bool populateChildren) {
    if (!populateChildren) return;

    final attribute = Attribute(name: node.name);
    for (final rowId
        in _lastAnalysis.attToRefFromDepColToCol[attribute]!.keys) {
      node.newChildren!.add(NodeStruct(rowId: rowId));
    }
  }
}
