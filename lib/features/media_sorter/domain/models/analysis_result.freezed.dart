// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalysisResult {

// ---------------------------------------------------------------------------
// Late Final Fields (Replaces your ignored JSON fields + Constructor Logic)
// These are initialized lazily the first time they are accessed, and Freezed
// automatically ignores them for JSON serialization.
// ---------------------------------------------------------------------------
 NodeStruct get errorRoot; NodeStruct get warningRoot; NodeStruct get categoriesRoot; NodeStruct get distPairsRoot; List<NodeStruct> get errorChildren; List<NodeStruct> get warningChildren; List<NodeStruct> get categoryChildren; List<NodeStruct> get distPairChildren;/// 2D table of attribute identifiers (row index or name)
/// mentioned in each cell.
 List<List<Set<Attribute>>> get tableToAtt; Map<String, CellPosition> get names; Map<String, List<int>> get attToCol; List<int> get nameIndexes; List<List<StrInt>> get formatedTable;/// Maps attribute identifiers (row index or name)
/// to a map of pointers (row index) to the column index,
/// in this direction so it is easy to diffuse characteristics to pointers.
@JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson) Map<Attribute, Map<int, Cols>> get attToRefFromAttColToCol;@JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson) Map<Attribute, Map<int, List<int>>> get attToRefFromDepColToCol; Map<int, Set<Attribute>> get colToAtt; List<bool> get isMedium; List<int> get validRowIndexes; List<int>? get currentBestSort; List<List<int>> get validAreas; Map<int, Map<int, List<SortingRule>>> get myRules; List<List<int>> get groupAttribution; List<List<int>> get groupsToMaximize; bool get validSortIsImpossible; bool get isFindingBestSort; bool get sortedWithValidSort;// true if the table is currently sorted with the current best sort found, 
// false otherwise. If no valid sort is found, should be true.
 bool get sortedWithCurrentBestSort; bool get bestSortPossibleFound;
/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisResultCopyWith<AnalysisResult> get copyWith => _$AnalysisResultCopyWithImpl<AnalysisResult>(this as AnalysisResult, _$identity);

  /// Serializes this AnalysisResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisResult&&(identical(other.errorRoot, errorRoot) || other.errorRoot == errorRoot)&&(identical(other.warningRoot, warningRoot) || other.warningRoot == warningRoot)&&(identical(other.categoriesRoot, categoriesRoot) || other.categoriesRoot == categoriesRoot)&&(identical(other.distPairsRoot, distPairsRoot) || other.distPairsRoot == distPairsRoot)&&const DeepCollectionEquality().equals(other.errorChildren, errorChildren)&&const DeepCollectionEquality().equals(other.warningChildren, warningChildren)&&const DeepCollectionEquality().equals(other.categoryChildren, categoryChildren)&&const DeepCollectionEquality().equals(other.distPairChildren, distPairChildren)&&const DeepCollectionEquality().equals(other.tableToAtt, tableToAtt)&&const DeepCollectionEquality().equals(other.names, names)&&const DeepCollectionEquality().equals(other.attToCol, attToCol)&&const DeepCollectionEquality().equals(other.nameIndexes, nameIndexes)&&const DeepCollectionEquality().equals(other.formatedTable, formatedTable)&&const DeepCollectionEquality().equals(other.attToRefFromAttColToCol, attToRefFromAttColToCol)&&const DeepCollectionEquality().equals(other.attToRefFromDepColToCol, attToRefFromDepColToCol)&&const DeepCollectionEquality().equals(other.colToAtt, colToAtt)&&const DeepCollectionEquality().equals(other.isMedium, isMedium)&&const DeepCollectionEquality().equals(other.validRowIndexes, validRowIndexes)&&const DeepCollectionEquality().equals(other.currentBestSort, currentBestSort)&&const DeepCollectionEquality().equals(other.validAreas, validAreas)&&const DeepCollectionEquality().equals(other.myRules, myRules)&&const DeepCollectionEquality().equals(other.groupAttribution, groupAttribution)&&const DeepCollectionEquality().equals(other.groupsToMaximize, groupsToMaximize)&&(identical(other.validSortIsImpossible, validSortIsImpossible) || other.validSortIsImpossible == validSortIsImpossible)&&(identical(other.isFindingBestSort, isFindingBestSort) || other.isFindingBestSort == isFindingBestSort)&&(identical(other.sortedWithValidSort, sortedWithValidSort) || other.sortedWithValidSort == sortedWithValidSort)&&(identical(other.sortedWithCurrentBestSort, sortedWithCurrentBestSort) || other.sortedWithCurrentBestSort == sortedWithCurrentBestSort)&&(identical(other.bestSortPossibleFound, bestSortPossibleFound) || other.bestSortPossibleFound == bestSortPossibleFound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,errorRoot,warningRoot,categoriesRoot,distPairsRoot,const DeepCollectionEquality().hash(errorChildren),const DeepCollectionEquality().hash(warningChildren),const DeepCollectionEquality().hash(categoryChildren),const DeepCollectionEquality().hash(distPairChildren),const DeepCollectionEquality().hash(tableToAtt),const DeepCollectionEquality().hash(names),const DeepCollectionEquality().hash(attToCol),const DeepCollectionEquality().hash(nameIndexes),const DeepCollectionEquality().hash(formatedTable),const DeepCollectionEquality().hash(attToRefFromAttColToCol),const DeepCollectionEquality().hash(attToRefFromDepColToCol),const DeepCollectionEquality().hash(colToAtt),const DeepCollectionEquality().hash(isMedium),const DeepCollectionEquality().hash(validRowIndexes),const DeepCollectionEquality().hash(currentBestSort),const DeepCollectionEquality().hash(validAreas),const DeepCollectionEquality().hash(myRules),const DeepCollectionEquality().hash(groupAttribution),const DeepCollectionEquality().hash(groupsToMaximize),validSortIsImpossible,isFindingBestSort,sortedWithValidSort,sortedWithCurrentBestSort,bestSortPossibleFound]);

@override
String toString() {
  return 'AnalysisResult(errorRoot: $errorRoot, warningRoot: $warningRoot, categoriesRoot: $categoriesRoot, distPairsRoot: $distPairsRoot, errorChildren: $errorChildren, warningChildren: $warningChildren, categoryChildren: $categoryChildren, distPairChildren: $distPairChildren, tableToAtt: $tableToAtt, names: $names, attToCol: $attToCol, nameIndexes: $nameIndexes, formatedTable: $formatedTable, attToRefFromAttColToCol: $attToRefFromAttColToCol, attToRefFromDepColToCol: $attToRefFromDepColToCol, colToAtt: $colToAtt, isMedium: $isMedium, validRowIndexes: $validRowIndexes, currentBestSort: $currentBestSort, validAreas: $validAreas, myRules: $myRules, groupAttribution: $groupAttribution, groupsToMaximize: $groupsToMaximize, validSortIsImpossible: $validSortIsImpossible, isFindingBestSort: $isFindingBestSort, sortedWithValidSort: $sortedWithValidSort, sortedWithCurrentBestSort: $sortedWithCurrentBestSort, bestSortPossibleFound: $bestSortPossibleFound)';
}


}

/// @nodoc
abstract mixin class $AnalysisResultCopyWith<$Res>  {
  factory $AnalysisResultCopyWith(AnalysisResult value, $Res Function(AnalysisResult) _then) = _$AnalysisResultCopyWithImpl;
@useResult
$Res call({
 List<NodeStruct> errorChildren, List<NodeStruct> warningChildren, List<NodeStruct> categoryChildren, List<NodeStruct> distPairChildren, List<List<Set<Attribute>>> tableToAtt, Map<String, CellPosition> names, Map<String, List<int>> attToCol, List<int> nameIndexes, List<List<StrInt>> formatedTable,@JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson) Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol,@JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson) Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol, Map<int, Set<Attribute>> colToAtt, List<bool> isMedium, List<int> validRowIndexes, List<int>? currentBestSort, List<List<int>> validAreas, Map<int, Map<int, List<SortingRule>>> myRules, List<List<int>> groupAttribution, List<List<int>> groupsToMaximize, bool validSortIsImpossible, bool isFindingBestSort, bool sortedWithValidSort, bool sortedWithCurrentBestSort, bool bestSortPossibleFound
});




}
/// @nodoc
class _$AnalysisResultCopyWithImpl<$Res>
    implements $AnalysisResultCopyWith<$Res> {
  _$AnalysisResultCopyWithImpl(this._self, this._then);

  final AnalysisResult _self;
  final $Res Function(AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? errorChildren = null,Object? warningChildren = null,Object? categoryChildren = null,Object? distPairChildren = null,Object? tableToAtt = null,Object? names = null,Object? attToCol = null,Object? nameIndexes = null,Object? formatedTable = null,Object? attToRefFromAttColToCol = null,Object? attToRefFromDepColToCol = null,Object? colToAtt = null,Object? isMedium = null,Object? validRowIndexes = null,Object? currentBestSort = freezed,Object? validAreas = null,Object? myRules = null,Object? groupAttribution = null,Object? groupsToMaximize = null,Object? validSortIsImpossible = null,Object? isFindingBestSort = null,Object? sortedWithValidSort = null,Object? sortedWithCurrentBestSort = null,Object? bestSortPossibleFound = null,}) {
  return _then(_self.copyWith(
errorChildren: null == errorChildren ? _self.errorChildren : errorChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,warningChildren: null == warningChildren ? _self.warningChildren : warningChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,categoryChildren: null == categoryChildren ? _self.categoryChildren : categoryChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,distPairChildren: null == distPairChildren ? _self.distPairChildren : distPairChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,tableToAtt: null == tableToAtt ? _self.tableToAtt : tableToAtt // ignore: cast_nullable_to_non_nullable
as List<List<Set<Attribute>>>,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as Map<String, CellPosition>,attToCol: null == attToCol ? _self.attToCol : attToCol // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,nameIndexes: null == nameIndexes ? _self.nameIndexes : nameIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,formatedTable: null == formatedTable ? _self.formatedTable : formatedTable // ignore: cast_nullable_to_non_nullable
as List<List<StrInt>>,attToRefFromAttColToCol: null == attToRefFromAttColToCol ? _self.attToRefFromAttColToCol : attToRefFromAttColToCol // ignore: cast_nullable_to_non_nullable
as Map<Attribute, Map<int, Cols>>,attToRefFromDepColToCol: null == attToRefFromDepColToCol ? _self.attToRefFromDepColToCol : attToRefFromDepColToCol // ignore: cast_nullable_to_non_nullable
as Map<Attribute, Map<int, List<int>>>,colToAtt: null == colToAtt ? _self.colToAtt : colToAtt // ignore: cast_nullable_to_non_nullable
as Map<int, Set<Attribute>>,isMedium: null == isMedium ? _self.isMedium : isMedium // ignore: cast_nullable_to_non_nullable
as List<bool>,validRowIndexes: null == validRowIndexes ? _self.validRowIndexes : validRowIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,currentBestSort: freezed == currentBestSort ? _self.currentBestSort : currentBestSort // ignore: cast_nullable_to_non_nullable
as List<int>?,validAreas: null == validAreas ? _self.validAreas : validAreas // ignore: cast_nullable_to_non_nullable
as List<List<int>>,myRules: null == myRules ? _self.myRules : myRules // ignore: cast_nullable_to_non_nullable
as Map<int, Map<int, List<SortingRule>>>,groupAttribution: null == groupAttribution ? _self.groupAttribution : groupAttribution // ignore: cast_nullable_to_non_nullable
as List<List<int>>,groupsToMaximize: null == groupsToMaximize ? _self.groupsToMaximize : groupsToMaximize // ignore: cast_nullable_to_non_nullable
as List<List<int>>,validSortIsImpossible: null == validSortIsImpossible ? _self.validSortIsImpossible : validSortIsImpossible // ignore: cast_nullable_to_non_nullable
as bool,isFindingBestSort: null == isFindingBestSort ? _self.isFindingBestSort : isFindingBestSort // ignore: cast_nullable_to_non_nullable
as bool,sortedWithValidSort: null == sortedWithValidSort ? _self.sortedWithValidSort : sortedWithValidSort // ignore: cast_nullable_to_non_nullable
as bool,sortedWithCurrentBestSort: null == sortedWithCurrentBestSort ? _self.sortedWithCurrentBestSort : sortedWithCurrentBestSort // ignore: cast_nullable_to_non_nullable
as bool,bestSortPossibleFound: null == bestSortPossibleFound ? _self.bestSortPossibleFound : bestSortPossibleFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisResult].
extension AnalysisResultPatterns on AnalysisResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisResult value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisResult value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NodeStruct> errorChildren,  List<NodeStruct> warningChildren,  List<NodeStruct> categoryChildren,  List<NodeStruct> distPairChildren,  List<List<Set<Attribute>>> tableToAtt,  Map<String, CellPosition> names,  Map<String, List<int>> attToCol,  List<int> nameIndexes,  List<List<StrInt>> formatedTable, @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol, @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol,  Map<int, Set<Attribute>> colToAtt,  List<bool> isMedium,  List<int> validRowIndexes,  List<int>? currentBestSort,  List<List<int>> validAreas,  Map<int, Map<int, List<SortingRule>>> myRules,  List<List<int>> groupAttribution,  List<List<int>> groupsToMaximize,  bool validSortIsImpossible,  bool isFindingBestSort,  bool sortedWithValidSort,  bool sortedWithCurrentBestSort,  bool bestSortPossibleFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.errorChildren,_that.warningChildren,_that.categoryChildren,_that.distPairChildren,_that.tableToAtt,_that.names,_that.attToCol,_that.nameIndexes,_that.formatedTable,_that.attToRefFromAttColToCol,_that.attToRefFromDepColToCol,_that.colToAtt,_that.isMedium,_that.validRowIndexes,_that.currentBestSort,_that.validAreas,_that.myRules,_that.groupAttribution,_that.groupsToMaximize,_that.validSortIsImpossible,_that.isFindingBestSort,_that.sortedWithValidSort,_that.sortedWithCurrentBestSort,_that.bestSortPossibleFound);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NodeStruct> errorChildren,  List<NodeStruct> warningChildren,  List<NodeStruct> categoryChildren,  List<NodeStruct> distPairChildren,  List<List<Set<Attribute>>> tableToAtt,  Map<String, CellPosition> names,  Map<String, List<int>> attToCol,  List<int> nameIndexes,  List<List<StrInt>> formatedTable, @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol, @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol,  Map<int, Set<Attribute>> colToAtt,  List<bool> isMedium,  List<int> validRowIndexes,  List<int>? currentBestSort,  List<List<int>> validAreas,  Map<int, Map<int, List<SortingRule>>> myRules,  List<List<int>> groupAttribution,  List<List<int>> groupsToMaximize,  bool validSortIsImpossible,  bool isFindingBestSort,  bool sortedWithValidSort,  bool sortedWithCurrentBestSort,  bool bestSortPossibleFound)  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult():
return $default(_that.errorChildren,_that.warningChildren,_that.categoryChildren,_that.distPairChildren,_that.tableToAtt,_that.names,_that.attToCol,_that.nameIndexes,_that.formatedTable,_that.attToRefFromAttColToCol,_that.attToRefFromDepColToCol,_that.colToAtt,_that.isMedium,_that.validRowIndexes,_that.currentBestSort,_that.validAreas,_that.myRules,_that.groupAttribution,_that.groupsToMaximize,_that.validSortIsImpossible,_that.isFindingBestSort,_that.sortedWithValidSort,_that.sortedWithCurrentBestSort,_that.bestSortPossibleFound);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NodeStruct> errorChildren,  List<NodeStruct> warningChildren,  List<NodeStruct> categoryChildren,  List<NodeStruct> distPairChildren,  List<List<Set<Attribute>>> tableToAtt,  Map<String, CellPosition> names,  Map<String, List<int>> attToCol,  List<int> nameIndexes,  List<List<StrInt>> formatedTable, @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol, @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol,  Map<int, Set<Attribute>> colToAtt,  List<bool> isMedium,  List<int> validRowIndexes,  List<int>? currentBestSort,  List<List<int>> validAreas,  Map<int, Map<int, List<SortingRule>>> myRules,  List<List<int>> groupAttribution,  List<List<int>> groupsToMaximize,  bool validSortIsImpossible,  bool isFindingBestSort,  bool sortedWithValidSort,  bool sortedWithCurrentBestSort,  bool bestSortPossibleFound)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.errorChildren,_that.warningChildren,_that.categoryChildren,_that.distPairChildren,_that.tableToAtt,_that.names,_that.attToCol,_that.nameIndexes,_that.formatedTable,_that.attToRefFromAttColToCol,_that.attToRefFromDepColToCol,_that.colToAtt,_that.isMedium,_that.validRowIndexes,_that.currentBestSort,_that.validAreas,_that.myRules,_that.groupAttribution,_that.groupsToMaximize,_that.validSortIsImpossible,_that.isFindingBestSort,_that.sortedWithValidSort,_that.sortedWithCurrentBestSort,_that.bestSortPossibleFound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisResult extends AnalysisResult {
   _AnalysisResult({required this.errorChildren, required this.warningChildren, required this.categoryChildren, required this.distPairChildren, required this.tableToAtt, required this.names, required this.attToCol, required this.nameIndexes, required this.formatedTable, @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson) required this.attToRefFromAttColToCol, @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson) required this.attToRefFromDepColToCol, required this.colToAtt, required this.isMedium, required this.validRowIndexes, required this.currentBestSort, required this.validAreas, required this.myRules, required this.groupAttribution, required this.groupsToMaximize, required this.validSortIsImpossible, required this.isFindingBestSort, required this.sortedWithValidSort, required this.sortedWithCurrentBestSort, required this.bestSortPossibleFound}): super._();
  factory _AnalysisResult.fromJson(Map<String, dynamic> json) => _$AnalysisResultFromJson(json);

@override final  List<NodeStruct> errorChildren;
@override final  List<NodeStruct> warningChildren;
@override final  List<NodeStruct> categoryChildren;
@override final  List<NodeStruct> distPairChildren;
/// 2D table of attribute identifiers (row index or name)
/// mentioned in each cell.
@override final  List<List<Set<Attribute>>> tableToAtt;
@override final  Map<String, CellPosition> names;
@override final  Map<String, List<int>> attToCol;
@override final  List<int> nameIndexes;
@override final  List<List<StrInt>> formatedTable;
/// Maps attribute identifiers (row index or name)
/// to a map of pointers (row index) to the column index,
/// in this direction so it is easy to diffuse characteristics to pointers.
@override@JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson) final  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
@override@JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson) final  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
@override final  Map<int, Set<Attribute>> colToAtt;
@override final  List<bool> isMedium;
@override final  List<int> validRowIndexes;
@override final  List<int>? currentBestSort;
@override final  List<List<int>> validAreas;
@override final  Map<int, Map<int, List<SortingRule>>> myRules;
@override final  List<List<int>> groupAttribution;
@override final  List<List<int>> groupsToMaximize;
@override final  bool validSortIsImpossible;
@override final  bool isFindingBestSort;
@override final  bool sortedWithValidSort;
// true if the table is currently sorted with the current best sort found, 
// false otherwise. If no valid sort is found, should be true.
@override final  bool sortedWithCurrentBestSort;
@override final  bool bestSortPossibleFound;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisResultCopyWith<_AnalysisResult> get copyWith => __$AnalysisResultCopyWithImpl<_AnalysisResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisResult&&const DeepCollectionEquality().equals(other.errorChildren, errorChildren)&&const DeepCollectionEquality().equals(other.warningChildren, warningChildren)&&const DeepCollectionEquality().equals(other.categoryChildren, categoryChildren)&&const DeepCollectionEquality().equals(other.distPairChildren, distPairChildren)&&const DeepCollectionEquality().equals(other.tableToAtt, tableToAtt)&&const DeepCollectionEquality().equals(other.names, names)&&const DeepCollectionEquality().equals(other.attToCol, attToCol)&&const DeepCollectionEquality().equals(other.nameIndexes, nameIndexes)&&const DeepCollectionEquality().equals(other.formatedTable, formatedTable)&&const DeepCollectionEquality().equals(other.attToRefFromAttColToCol, attToRefFromAttColToCol)&&const DeepCollectionEquality().equals(other.attToRefFromDepColToCol, attToRefFromDepColToCol)&&const DeepCollectionEquality().equals(other.colToAtt, colToAtt)&&const DeepCollectionEquality().equals(other.isMedium, isMedium)&&const DeepCollectionEquality().equals(other.validRowIndexes, validRowIndexes)&&const DeepCollectionEquality().equals(other.currentBestSort, currentBestSort)&&const DeepCollectionEquality().equals(other.validAreas, validAreas)&&const DeepCollectionEquality().equals(other.myRules, myRules)&&const DeepCollectionEquality().equals(other.groupAttribution, groupAttribution)&&const DeepCollectionEquality().equals(other.groupsToMaximize, groupsToMaximize)&&(identical(other.validSortIsImpossible, validSortIsImpossible) || other.validSortIsImpossible == validSortIsImpossible)&&(identical(other.isFindingBestSort, isFindingBestSort) || other.isFindingBestSort == isFindingBestSort)&&(identical(other.sortedWithValidSort, sortedWithValidSort) || other.sortedWithValidSort == sortedWithValidSort)&&(identical(other.sortedWithCurrentBestSort, sortedWithCurrentBestSort) || other.sortedWithCurrentBestSort == sortedWithCurrentBestSort)&&(identical(other.bestSortPossibleFound, bestSortPossibleFound) || other.bestSortPossibleFound == bestSortPossibleFound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(errorChildren),const DeepCollectionEquality().hash(warningChildren),const DeepCollectionEquality().hash(categoryChildren),const DeepCollectionEquality().hash(distPairChildren),const DeepCollectionEquality().hash(tableToAtt),const DeepCollectionEquality().hash(names),const DeepCollectionEquality().hash(attToCol),const DeepCollectionEquality().hash(nameIndexes),const DeepCollectionEquality().hash(formatedTable),const DeepCollectionEquality().hash(attToRefFromAttColToCol),const DeepCollectionEquality().hash(attToRefFromDepColToCol),const DeepCollectionEquality().hash(colToAtt),const DeepCollectionEquality().hash(isMedium),const DeepCollectionEquality().hash(validRowIndexes),const DeepCollectionEquality().hash(currentBestSort),const DeepCollectionEquality().hash(validAreas),const DeepCollectionEquality().hash(myRules),const DeepCollectionEquality().hash(groupAttribution),const DeepCollectionEquality().hash(groupsToMaximize),validSortIsImpossible,isFindingBestSort,sortedWithValidSort,sortedWithCurrentBestSort,bestSortPossibleFound]);

@override
String toString() {
  return 'AnalysisResult(errorChildren: $errorChildren, warningChildren: $warningChildren, categoryChildren: $categoryChildren, distPairChildren: $distPairChildren, tableToAtt: $tableToAtt, names: $names, attToCol: $attToCol, nameIndexes: $nameIndexes, formatedTable: $formatedTable, attToRefFromAttColToCol: $attToRefFromAttColToCol, attToRefFromDepColToCol: $attToRefFromDepColToCol, colToAtt: $colToAtt, isMedium: $isMedium, validRowIndexes: $validRowIndexes, currentBestSort: $currentBestSort, validAreas: $validAreas, myRules: $myRules, groupAttribution: $groupAttribution, groupsToMaximize: $groupsToMaximize, validSortIsImpossible: $validSortIsImpossible, isFindingBestSort: $isFindingBestSort, sortedWithValidSort: $sortedWithValidSort, sortedWithCurrentBestSort: $sortedWithCurrentBestSort, bestSortPossibleFound: $bestSortPossibleFound)';
}


}

/// @nodoc
abstract mixin class _$AnalysisResultCopyWith<$Res> implements $AnalysisResultCopyWith<$Res> {
  factory _$AnalysisResultCopyWith(_AnalysisResult value, $Res Function(_AnalysisResult) _then) = __$AnalysisResultCopyWithImpl;
@override @useResult
$Res call({
 List<NodeStruct> errorChildren, List<NodeStruct> warningChildren, List<NodeStruct> categoryChildren, List<NodeStruct> distPairChildren, List<List<Set<Attribute>>> tableToAtt, Map<String, CellPosition> names, Map<String, List<int>> attToCol, List<int> nameIndexes, List<List<StrInt>> formatedTable,@JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson) Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol,@JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson) Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol, Map<int, Set<Attribute>> colToAtt, List<bool> isMedium, List<int> validRowIndexes, List<int>? currentBestSort, List<List<int>> validAreas, Map<int, Map<int, List<SortingRule>>> myRules, List<List<int>> groupAttribution, List<List<int>> groupsToMaximize, bool validSortIsImpossible, bool isFindingBestSort, bool sortedWithValidSort, bool sortedWithCurrentBestSort, bool bestSortPossibleFound
});




}
/// @nodoc
class __$AnalysisResultCopyWithImpl<$Res>
    implements _$AnalysisResultCopyWith<$Res> {
  __$AnalysisResultCopyWithImpl(this._self, this._then);

  final _AnalysisResult _self;
  final $Res Function(_AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? errorChildren = null,Object? warningChildren = null,Object? categoryChildren = null,Object? distPairChildren = null,Object? tableToAtt = null,Object? names = null,Object? attToCol = null,Object? nameIndexes = null,Object? formatedTable = null,Object? attToRefFromAttColToCol = null,Object? attToRefFromDepColToCol = null,Object? colToAtt = null,Object? isMedium = null,Object? validRowIndexes = null,Object? currentBestSort = freezed,Object? validAreas = null,Object? myRules = null,Object? groupAttribution = null,Object? groupsToMaximize = null,Object? validSortIsImpossible = null,Object? isFindingBestSort = null,Object? sortedWithValidSort = null,Object? sortedWithCurrentBestSort = null,Object? bestSortPossibleFound = null,}) {
  return _then(_AnalysisResult(
errorChildren: null == errorChildren ? _self.errorChildren : errorChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,warningChildren: null == warningChildren ? _self.warningChildren : warningChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,categoryChildren: null == categoryChildren ? _self.categoryChildren : categoryChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,distPairChildren: null == distPairChildren ? _self.distPairChildren : distPairChildren // ignore: cast_nullable_to_non_nullable
as List<NodeStruct>,tableToAtt: null == tableToAtt ? _self.tableToAtt : tableToAtt // ignore: cast_nullable_to_non_nullable
as List<List<Set<Attribute>>>,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as Map<String, CellPosition>,attToCol: null == attToCol ? _self.attToCol : attToCol // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,nameIndexes: null == nameIndexes ? _self.nameIndexes : nameIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,formatedTable: null == formatedTable ? _self.formatedTable : formatedTable // ignore: cast_nullable_to_non_nullable
as List<List<StrInt>>,attToRefFromAttColToCol: null == attToRefFromAttColToCol ? _self.attToRefFromAttColToCol : attToRefFromAttColToCol // ignore: cast_nullable_to_non_nullable
as Map<Attribute, Map<int, Cols>>,attToRefFromDepColToCol: null == attToRefFromDepColToCol ? _self.attToRefFromDepColToCol : attToRefFromDepColToCol // ignore: cast_nullable_to_non_nullable
as Map<Attribute, Map<int, List<int>>>,colToAtt: null == colToAtt ? _self.colToAtt : colToAtt // ignore: cast_nullable_to_non_nullable
as Map<int, Set<Attribute>>,isMedium: null == isMedium ? _self.isMedium : isMedium // ignore: cast_nullable_to_non_nullable
as List<bool>,validRowIndexes: null == validRowIndexes ? _self.validRowIndexes : validRowIndexes // ignore: cast_nullable_to_non_nullable
as List<int>,currentBestSort: freezed == currentBestSort ? _self.currentBestSort : currentBestSort // ignore: cast_nullable_to_non_nullable
as List<int>?,validAreas: null == validAreas ? _self.validAreas : validAreas // ignore: cast_nullable_to_non_nullable
as List<List<int>>,myRules: null == myRules ? _self.myRules : myRules // ignore: cast_nullable_to_non_nullable
as Map<int, Map<int, List<SortingRule>>>,groupAttribution: null == groupAttribution ? _self.groupAttribution : groupAttribution // ignore: cast_nullable_to_non_nullable
as List<List<int>>,groupsToMaximize: null == groupsToMaximize ? _self.groupsToMaximize : groupsToMaximize // ignore: cast_nullable_to_non_nullable
as List<List<int>>,validSortIsImpossible: null == validSortIsImpossible ? _self.validSortIsImpossible : validSortIsImpossible // ignore: cast_nullable_to_non_nullable
as bool,isFindingBestSort: null == isFindingBestSort ? _self.isFindingBestSort : isFindingBestSort // ignore: cast_nullable_to_non_nullable
as bool,sortedWithValidSort: null == sortedWithValidSort ? _self.sortedWithValidSort : sortedWithValidSort // ignore: cast_nullable_to_non_nullable
as bool,sortedWithCurrentBestSort: null == sortedWithCurrentBestSort ? _self.sortedWithCurrentBestSort : sortedWithCurrentBestSort // ignore: cast_nullable_to_non_nullable
as bool,bestSortPossibleFound: null == bestSortPossibleFound ? _self.bestSortPossibleFound : bestSortPossibleFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
