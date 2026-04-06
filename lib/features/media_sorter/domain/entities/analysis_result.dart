import 'package:json_annotation/json_annotation.dart';

import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'dart:convert';

// IMPORTANT: Replace 'analysis_result' with the actual name of this dart file.
part 'analysis_result.g.dart';

@JsonSerializable()
class StrInt {
  List<String> strings;
  List<int> integers;

  StrInt({List<String>? strings, List<int>? integers})
    : strings = strings ?? [""],
      integers = integers ?? [];

  factory StrInt.fromJson(Map<String, dynamic> json) => _$StrIntFromJson(json);
  Map<String, dynamic> toJson() => _$StrIntToJson(this);
}

Map<Attribute, Map<int, Cols>> _attColMapFromJson(Map<String, dynamic> json) {
  return json.map((key, value) {
    // Decode the stringified JSON key back into an Attribute
    final attr = Attribute.fromJson(jsonDecode(key) as Map<String, dynamic>);

    // Parse the inner map (Assuming Cols has a .fromJson method)
    final innerMap = (value as Map<String, dynamic>).map(
      (k, v) =>
          MapEntry(int.parse(k), Cols.fromJson(v as Map<String, dynamic>)),
    );
    return MapEntry(attr, innerMap);
  });
}

Map<String, dynamic> _attColMapToJson(Map<Attribute, Map<int, Cols>> map) {
  return map.map((key, value) {
    // Encode the Attribute into a stringified JSON key
    final stringKey = jsonEncode(key.toJson());

    // Encode the inner map
    final innerMap = value.map((k, v) => MapEntry(k.toString(), v.toJson()));
    return MapEntry(stringKey, innerMap);
  });
}

Map<Attribute, Map<int, List<int>>> _depColMapFromJson(
  Map<String, dynamic> json,
) {
  return json.map((key, value) {
    final attr = Attribute.fromJson(jsonDecode(key) as Map<String, dynamic>);
    final innerMap = (value as Map<String, dynamic>).map(
      (k, v) => MapEntry(int.parse(k), List<int>.from(v as List)),
    );
    return MapEntry(attr, innerMap);
  });
}

Map<String, dynamic> _depColMapToJson(Map<Attribute, Map<int, List<int>>> map) {
  return map.map((key, value) {
    final stringKey = jsonEncode(key.toJson());
    final innerMap = value.map((k, v) => MapEntry(k.toString(), v));
    return MapEntry(stringKey, innerMap);
  });
}

@JsonSerializable(explicitToJson: true)
class AnalysisResult {
  // Excluded from JSON. Reconstituted in the constructor.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    hideIfEmpty: true,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    hideIfEmpty: true,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
  );

  // Added as fields so json_serializable can automatically save/load them
  final List<NodeStruct> errorChildren;
  final List<NodeStruct> warningChildren;
  final List<NodeStruct> categoryChildren;
  final List<NodeStruct> distPairChildren;

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  final List<List<Set<Attribute>>> tableToAtt;
  final Map<String, Cell> names;
  final Map<String, List<int>> attToCol;
  final List<int> nameIndexes;
  final List<List<StrInt>> formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)
  final Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
  @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)
  final Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
  final Map<int, Set<Attribute>> colToAtt;
  final List<bool> isMedium;
  final List<int> validRowIndexes;
  final List<int>? currentBestSort;

  final List<List<int>> validAreas;
  final Map<int, Map<int, List<SortingRule>>> myRules;
  final List<List<int>> groupAttribution;
  final List<List<int>> groupsToMaximize;
  
  final bool toAlwaysApplyCurrentBestSort;

  final bool validSortIsImpossible;
  final bool isFindingBestSort;
  final bool sortedWithValidSort;

  // true if the table is currently sorted with the current best sort found, false otherwise. If no valid sort is found, should be true.
  final bool sortedWithCurrentBestSort;

  final bool bestSortPossibleFound;

  AnalysisResult({
    required this.errorChildren,
    required this.warningChildren,
    required this.categoryChildren,
    required this.distPairChildren,
    required this.tableToAtt,
    required this.names,
    required this.attToCol,
    required this.nameIndexes,
    required this.attToRefFromAttColToCol,
    required this.attToRefFromDepColToCol,
    required this.formatedTable,
    required this.colToAtt,
    required this.myRules,
    required this.groupAttribution,
    required this.validAreas,
    required this.groupsToMaximize,
    required this.isMedium,
    required this.validRowIndexes,
    required this.currentBestSort,
    required this.toAlwaysApplyCurrentBestSort,
    required this.validSortIsImpossible,
    required this.isFindingBestSort,
    required this.sortedWithValidSort,
    required this.sortedWithCurrentBestSort,
    required this.bestSortPossibleFound,
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
      groupAttribution: [],
      validAreas: [],
      groupsToMaximize: [],
      isMedium: [],
      validRowIndexes: [],
      formatedTable: [],
      currentBestSort: null,
      toAlwaysApplyCurrentBestSort: false,
      validSortIsImpossible: false,
      isFindingBestSort: false,
      sortedWithValidSort: false,
      sortedWithCurrentBestSort: true,
      bestSortPossibleFound: false,
    );
  }

  AnalysisResult merge(
    {
      List<NodeStruct>? errorChildren,
      List<NodeStruct>? warningChildren,
      List<NodeStruct>? categoryChildren,
      List<NodeStruct>? distPairChildren,
      List<List<Set<Attribute>>>? tableToAtt,
      Map<String, Cell>? names,
      Map<String, List<int>>? attToCol,
      List<int>? nameIndexes,
      Map<Attribute, Map<int, Cols>>? attToRefFromAttColToCol,
      Map<Attribute, Map<int, List<int>>>? attToRefFromDepColToCol,
      Map<int, Set<Attribute>>? colToAtt,
      Map<int, Map<int, List<SortingRule>>>? myRules,
      List<List<int>>? groupAttribution,
      List<List<int>>? validAreas,
      List<List<int>>? groupsToMaximize,
      List<bool>? isMedium,
      List<int>? validRowIndexes,
      List<int>? currentBestSort,
      bool? toAlwaysApplyCurrentBestSort,
      bool? validSortIsImpossible,
      bool? isFindingBestSort,
      bool? sortedWithValidSort,
      bool? sortedWithCurrentBestSort,
      bool? bestSortPossibleFound,
      List<List<StrInt>>? formatedTable,
    }  ) {
    return AnalysisResult(
      errorChildren: errorChildren ?? this.errorChildren,
      warningChildren: warningChildren ?? this.warningChildren,
      categoryChildren: categoryChildren ?? this.categoryChildren,
      distPairChildren: distPairChildren ?? this.distPairChildren,
      tableToAtt: tableToAtt ?? this.tableToAtt,
      names: names ?? this.names,
      attToCol: attToCol ?? this.attToCol,
      nameIndexes: nameIndexes ?? this.nameIndexes,
      attToRefFromAttColToCol:
          attToRefFromAttColToCol ?? this.attToRefFromAttColToCol,
      attToRefFromDepColToCol:
          attToRefFromDepColToCol ?? this.attToRefFromDepColToCol,
      colToAtt: colToAtt ?? this.colToAtt,
      myRules: myRules ?? this.myRules,
      groupAttribution: groupAttribution ?? this.groupAttribution,
      validAreas: validAreas ?? this.validAreas,
      groupsToMaximize: groupsToMaximize ?? this.groupsToMaximize,
      isMedium: isMedium ?? this.isMedium,
      validRowIndexes: validRowIndexes ?? this.validRowIndexes,
      currentBestSort: currentBestSort ?? this.currentBestSort,
      toAlwaysApplyCurrentBestSort:
          toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
      validSortIsImpossible:
          validSortIsImpossible ?? this.validSortIsImpossible,
      isFindingBestSort:
          isFindingBestSort ?? this.isFindingBestSort,
      sortedWithValidSort:
          sortedWithValidSort ?? this.sortedWithValidSort,
      sortedWithCurrentBestSort:
          sortedWithCurrentBestSort ?? this.sortedWithCurrentBestSort,
      bestSortPossibleFound:
          bestSortPossibleFound ?? this.bestSortPossibleFound,
      formatedTable: formatedTable ?? this.formatedTable,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);
}
