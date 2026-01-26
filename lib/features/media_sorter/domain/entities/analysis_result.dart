import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';

class RowIdIdentifier {
  int start;
  int length;
  int rowId;

  RowIdIdentifier({
    required this.start,
    required this.length,
    required this.rowId,
  });
}

class AnalysisResult {
  final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    hideIfEmpty: true,
  );
  final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    hideIfEmpty: true,
  );
  final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
  );
  final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
  );

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<HashSet<Attribute>>> tableToAtt;
  Map<String, Cell> names;
  Map<String, List<int>> attToCol;
  List<int> nameIndexes;
  List<int> pathIndexes;
  List<List<String>> formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
  List<HashSet<int>> rowToRefFromAttCol;
  List<List<List<RowIdIdentifier>>> splittedTable;
  List<Map<InstrStruct, Cell>> instrTable;
  Map<int, HashSet<Attribute>> colToAtt;
  List<int> validRowIndexes;

  int rowCount;
  int colCount;

  bool noResult = true;

  AnalysisResult({
    required List<NodeStruct> errorChildren,
    required List<NodeStruct> warningChildren,
    required List<NodeStruct> categoryChildren,
    required List<NodeStruct> distPairChildren,
    required this.tableToAtt,
    required this.names,
    required this.attToCol,
    required this.nameIndexes,
    required this.pathIndexes,
    required this.attToRefFromAttColToCol,
    required this.attToRefFromDepColToCol,
    required this.formatedTable,
    required this.splittedTable,
    required this.rowToRefFromAttCol,
    required this.instrTable,
    required this.colToAtt,
    required this.validRowIndexes,
    required this.rowCount,
    required this.colCount,
  }) {
    errorRoot.newChildren = errorChildren;
    warningRoot.newChildren = warningChildren;
    categoriesRoot.newChildren = categoryChildren;
    distPairsRoot.newChildren = distPairChildren;
  }

  factory AnalysisResult.empty() {
    return AnalysisResult(
      errorChildren: [],
      warningChildren: [],
      categoryChildren: [],
      distPairChildren: [],
      tableToAtt: [],
      names: {},
      attToCol: {},
      nameIndexes: [],
      pathIndexes: [],
      attToRefFromAttColToCol: {},
      attToRefFromDepColToCol: {},
      instrTable: [],
      colToAtt: {},
      validRowIndexes: [],
      rowCount: 0,
      colCount: 0,
      formatedTable: [],
      splittedTable: [],
      rowToRefFromAttCol: [],
    );
  }
}
