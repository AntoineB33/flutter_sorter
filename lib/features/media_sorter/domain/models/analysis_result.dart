import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/data/services/calculate_service.dart';
import 'dart:convert';

// IMPORTANT: Replace 'analysis_result' with the actual name of this dart file.
part 'analysis_result.g.dart';
part 'analysis_result.freezed.dart';

@JsonSerializable()
class StrInt {
  List<String> strings;
  List<int> integers;

  StrInt({List<String>? strings, List<int>? integers})
    : strings = strings ?? [""],
      integers = integers ?? [];

  factory StrInt.fromJson(Map<String, dynamic> json) => _$StrIntFromJson(json);
  Map<String, dynamic> toJson() => _$StrIntToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => StrInt().toJson();
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

@Freezed(makeCollectionsUnmodifiable: false)
abstract class AnalysisResult with _$AnalysisResult {

  AnalysisResult._();

  factory AnalysisResult({
    required List<NodeStruct> errorChildren,
    required List<NodeStruct> warningChildren,
    required List<NodeStruct> categoryChildren,
    required List<NodeStruct> distPairChildren,

    /// 2D table of attribute identifiers (row index or name)
    /// mentioned in each cell.
    required List<List<Set<Attribute>>> tableToAtt,
    required Map<String, CellPosition> names,
    required Map<String, List<int>> attToCol,
    required List<int> nameIndexes,
    required List<List<StrInt>> formatedTable,

    /// Maps attribute identifiers (row index or name)
    /// to a map of pointers (row index) to the column index,
    /// in this direction so it is easy to diffuse characteristics to pointers.
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)
    required Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol,

    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)
    required Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol,
    
    required Map<int, Set<Attribute>> colToAtt,
    required List<bool> isMedium,
    required List<int> validRowIndexes,
    required List<int>? currentBestSort,

    required List<List<int>> validAreas,
    required Map<int, Map<int, List<SortingRule>>> myRules,
    required List<List<int>> groupAttribution,
    required List<List<int>> groupsToMaximize,

    required bool validSortIsImpossible,
    required bool isFindingBestSort,
    required bool sortedWithValidSort,
    // true if the table is currently sorted with the current best sort found, 
    // false otherwise. If no valid sort is found, should be true.
    required bool sortedWithCurrentBestSort,
    required bool bestSortPossibleFound,
  }) = _AnalysisResult;

  // ---------------------------------------------------------------------------
  // Late Final Fields (Replaces your ignored JSON fields + Constructor Logic)
  // These are initialized lazily the first time they are accessed, and Freezed
  // automatically ignores them for JSON serialization.
  // ---------------------------------------------------------------------------

  @override
  late final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    hideIfEmpty: true,
  )..newChildren = errorChildren;

  @override
  late final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    hideIfEmpty: true,
  )..newChildren = warningChildren;

  @override
  late final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
  )..newChildren = categoryChildren;

  @override
  late final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
  )..newChildren = distPairChildren;


  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

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
      validSortIsImpossible: false,
      isFindingBestSort: false,
      sortedWithValidSort: false,
      sortedWithCurrentBestSort: true,
      bestSortPossibleFound: false,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);
}
