import 'dart:collection';
import 'dart:convert';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';

class StrInt {
  List<String> strings;
  List<int> integers;
  StrInt({List<String>? strings, List<int>? integers})
      : strings = strings ?? [""],
        integers = integers ?? [];
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
  List<List<StrInt>> formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
  Map<int, HashSet<Attribute>> colToAtt;
  List<bool> isMedium;
  List<int> validRowIndexes;
  List<int>? bestMediaSortOrder;

  bool isBestSort;

  List<List<int>> validAreas;
  Map<int, Map<int, List<SortingRule>>> myRules;
  List<List<int>> groupsToMaximize;
  int idSorterProgress;

  AnalysisResult({
    required List<NodeStruct> errorChildren,
    required List<NodeStruct> warningChildren,
    required List<NodeStruct> categoryChildren,
    required List<NodeStruct> distPairChildren,
    required this.tableToAtt,
    required this.names,
    required this.attToCol,
    required this.nameIndexes,
    required this.attToRefFromAttColToCol,
    required this.attToRefFromDepColToCol,
    required this.formatedTable,
    required this.colToAtt,
    required this.myRules,
    required this.validAreas,
    required this.groupsToMaximize,
    required this.isMedium,
    required this.validRowIndexes,
    required this.bestMediaSortOrder,
    required this.idSorterProgress,
    required this.isBestSort,
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
      attToRefFromAttColToCol: {},
      attToRefFromDepColToCol: {},
      colToAtt: {},
      myRules: {},
      validAreas: [],
      groupsToMaximize: [],
      isMedium: [],
      validRowIndexes: [],
      formatedTable: [],
      bestMediaSortOrder: null,
      isBestSort: false,
      idSorterProgress: -1,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      errorChildren: (json['errorRoot']['newChildren'] as List)
          .map((child) => NodeStruct.fromJson(child))
          .toList(),
      warningChildren: (json['warningRoot']['newChildren'] as List)
          .map((child) => NodeStruct.fromJson(child))
          .toList(),
      categoryChildren: (json['categoriesRoot']['newChildren'] as List)
          .map((child) => NodeStruct.fromJson(child))
          .toList(),
      distPairChildren: (json['distPairsRoot']['newChildren'] as List)
          .map((child) => NodeStruct.fromJson(child))
          .toList(),
      tableToAtt: (json['tableToAtt'] as List)
          .map(
            (row) => (row as List)
                .map(
                  (cellAtts) => HashSet<Attribute>.from(
                    (cellAtts as List).map((att) => Attribute.fromJson(att)),
                  ),
                )
                .toList(),
          )
          .toList(),
      names: Map<String, Cell>.fromEntries(
        (json['names'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(entry.key, Cell.fromJson(entry.value)),
        ),
      ),
      attToCol: Map<String, List<int>>.fromEntries(
        (json['attToCol'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(entry.key, List<int>.from(entry.value as List)),
        ),
      ),
      nameIndexes: List<int>.from(json['nameIndexes'] as List<dynamic>),
      attToRefFromAttColToCol: Map<Attribute, Map<int, Cols>>.fromEntries(
        (json['attToRefFromAttColToCol'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            Attribute.fromJson(jsonDecode(entry.key) as Map<String, dynamic>),
            Map<int, Cols>.fromEntries(
              (entry.value as Map<String, dynamic>).entries.map(
                (innerEntry) => MapEntry(
                  int.parse(innerEntry.key),
                  Cols.fromJson(innerEntry.value),
                ),
              ),
            ),
          ),
        ),
      ),
      attToRefFromDepColToCol: Map<Attribute, Map<int, List<int>>>.fromEntries(
        (json['attToRefFromDepColToCol'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            Attribute.fromJson(jsonDecode(entry.key) as Map<String, dynamic>),
            Map<int, List<int>>.fromEntries(
              (entry.value as Map<String, dynamic>).entries.map(
                (innerEntry) => MapEntry(
                  int.parse(innerEntry.key),
                  List<int>.from(innerEntry.value as List),
                ),
              ),
            ),
          ),
        ),
      ),
      formatedTable: (json['formatedTable'] as List)
          .map(
            (row) => (row as List)
                .map(
                  (cell) => StrInt()
                    ..strings = List<String>.from(cell['strings'] as List)
                    ..integers = List<int>.from(cell['integers'] as List),
                )
                .toList(),
          )
          .toList(),
      colToAtt: Map<int, HashSet<Attribute>>.fromEntries(
        (json['colToAtt'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(
            int.parse(entry.key),
            HashSet<Attribute>.from(
              (entry.value as List).map((att) => Attribute.fromJson(att)),
            ),
          ),
        ),
      ),
      myRules: Map<String, dynamic>.from(json['myRules'] as Map<String, dynamic>)
          .map((rowId, targetMap) => MapEntry(
                int.parse(rowId),
                Map<String, dynamic>.from(targetMap as Map<String, dynamic>)
                    .map((target, rulesList) => MapEntry(
                          int.parse(target),
                          (rulesList as List)
                              .map((rule) => SortingRule.fromJson(rule))
                              .toList(),
                        )),
              )),
      validAreas: (json['valid_areas'] as List)
          .map((area) => List<int>.from(area as List))
          .toList(),
      groupsToMaximize: (json['groupsToMaximize'] as List)
          .map((group) => List<int>.from(group as List))
          .toList(),
      isMedium: List<bool>.from(json['isMedium'] as List<dynamic>),
      validRowIndexes: List<int>.from(json['validRowIndexes'] as List<dynamic>),
      bestMediaSortOrder: json['bestMediaSortOrder'] != null
          ? List<int>.from(json['bestMediaSortOrder'] as List<dynamic>)
          : null,
      idSorterProgress: json['idSorterProgress'] as int,
      isBestSort: json['isBestSort'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorRoot': {
        'newChildren': errorRoot.newChildren
            ?.map((child) => child.toJson())
            .toList(),
      },
      'warningRoot': {
        'newChildren': warningRoot.newChildren
            ?.map((child) => child.toJson())
            .toList(),
      },
      'categoriesRoot': {
        'newChildren': categoriesRoot.newChildren
            ?.map((child) => child.toJson())
            .toList(),
      },
      'distPairsRoot': {
        'newChildren': distPairsRoot.newChildren
            ?.map((child) => child.toJson())
            .toList(),
      },
      'tableToAtt': tableToAtt
          .map(
            (row) => row
                .map((cellAtts) => cellAtts.map((att) => att.toJson()).toList())
                .toList(),
          )
          .toList(),
      'names': names.map((key, value) => MapEntry(key, value.toJson())),
      'attToCol': attToCol,
      'nameIndexes': nameIndexes,
      'attToRefFromAttColToCol': attToRefFromAttColToCol.map(
        (key, value) => MapEntry(
          jsonEncode(key.toJson()),
          value.map(
            (innerKey, innerValue) =>
                MapEntry(innerKey.toString(), innerValue.toJson()),
          ),
        ),
      ),
      'attToRefFromDepColToCol': attToRefFromDepColToCol.map(
        (key, value) => MapEntry(
          jsonEncode(key.toJson()),
          value.map(
            (innerKey, innerValue) => MapEntry(innerKey.toString(), innerValue),
          ),
        ),
      ),
      'formatedTable': formatedTable
          .map(
            (row) => row
                .map(
                  (cell) => {
                    'strings': cell.strings,
                    'integers': cell.integers,
                  },
                )
                .toList(),
          )
          .toList(),
      'colToAtt': colToAtt.map(
        (key, value) =>
            MapEntry(key.toString(), value.map((att) => att.toJson()).toList()),
      ),
      'myRules': myRules.map(
        (rowId, targetMap) => MapEntry(
          rowId.toString(),
          targetMap.map(
            (target, rulesList) => MapEntry(
              target.toString(),
              rulesList.map((rule) => rule.toJson()).toList(),
            ),
          ),
        ),
      ),
      'valid_areas': validAreas,
      'groupsToMaximize': groupsToMaximize,
      'validRowIndexes': validRowIndexes,
      'bestMediaSortOrder': bestMediaSortOrder,
      'idSorterProgress': idSorterProgress,
    };
  }
}
