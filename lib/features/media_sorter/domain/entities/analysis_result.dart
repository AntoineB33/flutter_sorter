import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';

class AnalysisResult {
  final NodeStruct errorRoot = NodeStruct(message: 'Error Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct warningRoot = NodeStruct(message: 'Warning Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection', newChildren: []);
  final NodeStruct searchRoot = NodeStruct(message: 'Search results', newChildren: []);
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories', newChildren: []);
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs', newChildren: []);

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<List<AttAndCol>>> mentions = [];
  Map<String, Cell> names = {};
  Map<String, List<dynamic>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];
  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<AttAndCol, Map<int, int>> attributes = {};
  Map<int, Map<AttAndCol, int>> rowToAtt = {};
  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<AttAndCol, Map<int, List<int>>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<dynamic, List<AttAndCol>> colToAtt = {};
}