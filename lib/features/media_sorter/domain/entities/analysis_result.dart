import 'dart:collection';
import 'package:json_annotation/json_annotation.dart';

import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
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
      (k, v) => MapEntry(int.parse(k), Cols.fromJson(v as Map<String, dynamic>)),
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

Map<Attribute, Map<int, List<int>>> _depColMapFromJson(Map<String, dynamic> json) {
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
  List<List<Set<Attribute>>> tableToAtt;
  Map<String, Cell> names;
  Map<String, List<int>> attToCol;
  List<int> nameIndexes;
  List<List<StrInt>> formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)
  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
  @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
  Map<int, Set<Attribute>> colToAtt;
  List<bool> isMedium;
  List<int> validRowIndexes;
  List<int>? currentBestSort;

  List<List<int>> validAreas;
  Map<int, Map<int, List<SortingRule>>> myRules;
  List<List<int>> groupsToMaximize;

  bool sorted;
  bool sortedWithCurrentBestSort;
  bool bestSortPossibleFound;

  bool okToCalculateResult;
  bool resultCalculated;
  bool okToFindValidSort;

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
    required this.validAreas,
    required this.groupsToMaximize,
    required this.isMedium,
    required this.validRowIndexes,
    required this.currentBestSort,
    required this.sorted,
    required this.sortedWithCurrentBestSort,
    required this.bestSortPossibleFound,
    required this.okToCalculateResult,
    required this.resultCalculated,
    required this.okToFindValidSort,
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
      currentBestSort: null,
      sorted: false,
      sortedWithCurrentBestSort: false,
      bestSortPossibleFound: false,
      okToCalculateResult: true,
      resultCalculated: true,
      okToFindValidSort: true,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);
}