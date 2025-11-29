import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:trying_flutter/data/models/cell.dart';
import 'package:trying_flutter/data/models/node_struct.dart';
import 'package:trying_flutter/data/models/column_type.dart';
import 'package:trying_flutter/logger.dart';
import 'package:trying_flutter/logic/async_utils.dart';
import 'package:trying_flutter/logic/hungarian_algorithm.dart';
import 'package:trying_flutter/data/models/dyn_and_int.dart';
import 'package:trying_flutter/data/models/instr_struct.dart';


class SpreadsheetData {
  static const patternDistance =
    r'^(?<prefix>as far as possible from )(?<any>any)?(?<att>.+)$/';
  static const patternAreas =
    r'^(?<prefix>.*\|)(?<any>any)?(?<att>.+)(?<suffix>\|.*)$/';
  static const rowCst = "rows";
  static const notUsedCst = "notUsed";
  String spreadsheetName = "";
  final NodeStruct errorRoot = NodeStruct(message: 'Error Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct warningRoot = NodeStruct(message: 'Warning Log', newChildren: [], hideIfEmpty: true);
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection', newChildren: []);
  final NodeStruct searchRoot = NodeStruct(message: 'Search results', newChildren: []);
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories', newChildren: []);
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs', newChildren: []);
  late List<List<String>> table = [];
  List<String> columnTypes = [];

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
  Map<AttAndCol, Map<int, int>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<dynamic, List<AttAndCol>> colToAtt = {};
  Cell? selectionStart;
  Cell? selectionEnd;
  
  SpreadsheetData({
    required this.name, 
    required this.table,
    required this.cellMap,
  });
}