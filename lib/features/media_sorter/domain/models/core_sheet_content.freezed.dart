// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core_sheet_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoreSheetContent {

 int get sheetId; String get title; DateTime get lastOpened; Map<CellPosition, String> get cells; Map<int, ColumnType> get columnTypes; List<int> get usedRows; List<int> get usedCols; bool get toAlwaysApplyCurrentBestSort;
/// Create a copy of CoreSheetContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreSheetContentCopyWith<CoreSheetContent> get copyWith => _$CoreSheetContentCopyWithImpl<CoreSheetContent>(this as CoreSheetContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreSheetContent&&(identical(other.sheetId, sheetId) || other.sheetId == sheetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened)&&const DeepCollectionEquality().equals(other.cells, cells)&&const DeepCollectionEquality().equals(other.columnTypes, columnTypes)&&const DeepCollectionEquality().equals(other.usedRows, usedRows)&&const DeepCollectionEquality().equals(other.usedCols, usedCols)&&(identical(other.toAlwaysApplyCurrentBestSort, toAlwaysApplyCurrentBestSort) || other.toAlwaysApplyCurrentBestSort == toAlwaysApplyCurrentBestSort));
}


@override
int get hashCode => Object.hash(runtimeType,sheetId,title,lastOpened,const DeepCollectionEquality().hash(cells),const DeepCollectionEquality().hash(columnTypes),const DeepCollectionEquality().hash(usedRows),const DeepCollectionEquality().hash(usedCols),toAlwaysApplyCurrentBestSort);

@override
String toString() {
  return 'CoreSheetContent(sheetId: $sheetId, title: $title, lastOpened: $lastOpened, cells: $cells, columnTypes: $columnTypes, usedRows: $usedRows, usedCols: $usedCols, toAlwaysApplyCurrentBestSort: $toAlwaysApplyCurrentBestSort)';
}


}

/// @nodoc
abstract mixin class $CoreSheetContentCopyWith<$Res>  {
  factory $CoreSheetContentCopyWith(CoreSheetContent value, $Res Function(CoreSheetContent) _then) = _$CoreSheetContentCopyWithImpl;
@useResult
$Res call({
 int sheetId, String title, DateTime lastOpened, Map<CellPosition, String> cells, Map<int, ColumnType> columnTypes, List<int> usedRows, List<int> usedCols, bool toAlwaysApplyCurrentBestSort
});




}
/// @nodoc
class _$CoreSheetContentCopyWithImpl<$Res>
    implements $CoreSheetContentCopyWith<$Res> {
  _$CoreSheetContentCopyWithImpl(this._self, this._then);

  final CoreSheetContent _self;
  final $Res Function(CoreSheetContent) _then;

/// Create a copy of CoreSheetContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sheetId = null,Object? title = null,Object? lastOpened = null,Object? cells = null,Object? columnTypes = null,Object? usedRows = null,Object? usedCols = null,Object? toAlwaysApplyCurrentBestSort = null,}) {
  return _then(_self.copyWith(
sheetId: null == sheetId ? _self.sheetId : sheetId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as DateTime,cells: null == cells ? _self.cells : cells // ignore: cast_nullable_to_non_nullable
as Map<CellPosition, String>,columnTypes: null == columnTypes ? _self.columnTypes : columnTypes // ignore: cast_nullable_to_non_nullable
as Map<int, ColumnType>,usedRows: null == usedRows ? _self.usedRows : usedRows // ignore: cast_nullable_to_non_nullable
as List<int>,usedCols: null == usedCols ? _self.usedCols : usedCols // ignore: cast_nullable_to_non_nullable
as List<int>,toAlwaysApplyCurrentBestSort: null == toAlwaysApplyCurrentBestSort ? _self.toAlwaysApplyCurrentBestSort : toAlwaysApplyCurrentBestSort // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreSheetContent].
extension CoreSheetContentPatterns on CoreSheetContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreSheetContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreSheetContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreSheetContent value)  $default,){
final _that = this;
switch (_that) {
case _CoreSheetContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreSheetContent value)?  $default,){
final _that = this;
switch (_that) {
case _CoreSheetContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sheetId,  String title,  DateTime lastOpened,  Map<CellPosition, String> cells,  Map<int, ColumnType> columnTypes,  List<int> usedRows,  List<int> usedCols,  bool toAlwaysApplyCurrentBestSort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreSheetContent() when $default != null:
return $default(_that.sheetId,_that.title,_that.lastOpened,_that.cells,_that.columnTypes,_that.usedRows,_that.usedCols,_that.toAlwaysApplyCurrentBestSort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sheetId,  String title,  DateTime lastOpened,  Map<CellPosition, String> cells,  Map<int, ColumnType> columnTypes,  List<int> usedRows,  List<int> usedCols,  bool toAlwaysApplyCurrentBestSort)  $default,) {final _that = this;
switch (_that) {
case _CoreSheetContent():
return $default(_that.sheetId,_that.title,_that.lastOpened,_that.cells,_that.columnTypes,_that.usedRows,_that.usedCols,_that.toAlwaysApplyCurrentBestSort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sheetId,  String title,  DateTime lastOpened,  Map<CellPosition, String> cells,  Map<int, ColumnType> columnTypes,  List<int> usedRows,  List<int> usedCols,  bool toAlwaysApplyCurrentBestSort)?  $default,) {final _that = this;
switch (_that) {
case _CoreSheetContent() when $default != null:
return $default(_that.sheetId,_that.title,_that.lastOpened,_that.cells,_that.columnTypes,_that.usedRows,_that.usedCols,_that.toAlwaysApplyCurrentBestSort);case _:
  return null;

}
}

}

/// @nodoc


class _CoreSheetContent implements CoreSheetContent {
   _CoreSheetContent({required this.sheetId, required this.title, required this.lastOpened, required final  Map<CellPosition, String> cells, required final  Map<int, ColumnType> columnTypes, required final  List<int> usedRows, required final  List<int> usedCols, required this.toAlwaysApplyCurrentBestSort}): _cells = cells,_columnTypes = columnTypes,_usedRows = usedRows,_usedCols = usedCols;
  

@override final  int sheetId;
@override final  String title;
@override final  DateTime lastOpened;
 final  Map<CellPosition, String> _cells;
@override Map<CellPosition, String> get cells {
  if (_cells is EqualUnmodifiableMapView) return _cells;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cells);
}

 final  Map<int, ColumnType> _columnTypes;
@override Map<int, ColumnType> get columnTypes {
  if (_columnTypes is EqualUnmodifiableMapView) return _columnTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_columnTypes);
}

 final  List<int> _usedRows;
@override List<int> get usedRows {
  if (_usedRows is EqualUnmodifiableListView) return _usedRows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usedRows);
}

 final  List<int> _usedCols;
@override List<int> get usedCols {
  if (_usedCols is EqualUnmodifiableListView) return _usedCols;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_usedCols);
}

@override final  bool toAlwaysApplyCurrentBestSort;

/// Create a copy of CoreSheetContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreSheetContentCopyWith<_CoreSheetContent> get copyWith => __$CoreSheetContentCopyWithImpl<_CoreSheetContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreSheetContent&&(identical(other.sheetId, sheetId) || other.sheetId == sheetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened)&&const DeepCollectionEquality().equals(other._cells, _cells)&&const DeepCollectionEquality().equals(other._columnTypes, _columnTypes)&&const DeepCollectionEquality().equals(other._usedRows, _usedRows)&&const DeepCollectionEquality().equals(other._usedCols, _usedCols)&&(identical(other.toAlwaysApplyCurrentBestSort, toAlwaysApplyCurrentBestSort) || other.toAlwaysApplyCurrentBestSort == toAlwaysApplyCurrentBestSort));
}


@override
int get hashCode => Object.hash(runtimeType,sheetId,title,lastOpened,const DeepCollectionEquality().hash(_cells),const DeepCollectionEquality().hash(_columnTypes),const DeepCollectionEquality().hash(_usedRows),const DeepCollectionEquality().hash(_usedCols),toAlwaysApplyCurrentBestSort);

@override
String toString() {
  return 'CoreSheetContent(sheetId: $sheetId, title: $title, lastOpened: $lastOpened, cells: $cells, columnTypes: $columnTypes, usedRows: $usedRows, usedCols: $usedCols, toAlwaysApplyCurrentBestSort: $toAlwaysApplyCurrentBestSort)';
}


}

/// @nodoc
abstract mixin class _$CoreSheetContentCopyWith<$Res> implements $CoreSheetContentCopyWith<$Res> {
  factory _$CoreSheetContentCopyWith(_CoreSheetContent value, $Res Function(_CoreSheetContent) _then) = __$CoreSheetContentCopyWithImpl;
@override @useResult
$Res call({
 int sheetId, String title, DateTime lastOpened, Map<CellPosition, String> cells, Map<int, ColumnType> columnTypes, List<int> usedRows, List<int> usedCols, bool toAlwaysApplyCurrentBestSort
});




}
/// @nodoc
class __$CoreSheetContentCopyWithImpl<$Res>
    implements _$CoreSheetContentCopyWith<$Res> {
  __$CoreSheetContentCopyWithImpl(this._self, this._then);

  final _CoreSheetContent _self;
  final $Res Function(_CoreSheetContent) _then;

/// Create a copy of CoreSheetContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sheetId = null,Object? title = null,Object? lastOpened = null,Object? cells = null,Object? columnTypes = null,Object? usedRows = null,Object? usedCols = null,Object? toAlwaysApplyCurrentBestSort = null,}) {
  return _then(_CoreSheetContent(
sheetId: null == sheetId ? _self.sheetId : sheetId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as DateTime,cells: null == cells ? _self._cells : cells // ignore: cast_nullable_to_non_nullable
as Map<CellPosition, String>,columnTypes: null == columnTypes ? _self._columnTypes : columnTypes // ignore: cast_nullable_to_non_nullable
as Map<int, ColumnType>,usedRows: null == usedRows ? _self._usedRows : usedRows // ignore: cast_nullable_to_non_nullable
as List<int>,usedCols: null == usedCols ? _self._usedCols : usedCols // ignore: cast_nullable_to_non_nullable
as List<int>,toAlwaysApplyCurrentBestSort: null == toAlwaysApplyCurrentBestSort ? _self.toAlwaysApplyCurrentBestSort : toAlwaysApplyCurrentBestSort // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
