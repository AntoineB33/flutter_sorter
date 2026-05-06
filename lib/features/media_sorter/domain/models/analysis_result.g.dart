// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrInt _$StrIntFromJson(Map<String, dynamic> json) => StrInt(
  strings: (json['strings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  integers: (json['integers'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$StrIntToJson(StrInt instance) => <String, dynamic>{
  'strings': instance.strings,
  'integers': instance.integers,
};

_AnalysisResult _$AnalysisResultFromJson(
  Map<String, dynamic> json,
) => _AnalysisResult(
  errorChildren: (json['errorChildren'] as List<dynamic>)
      .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
      .toList(),
  warningChildren: (json['warningChildren'] as List<dynamic>)
      .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
      .toList(),
  categoryChildren: (json['categoryChildren'] as List<dynamic>)
      .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
      .toList(),
  distPairChildren: (json['distPairChildren'] as List<dynamic>)
      .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
      .toList(),
  tableToAtt: (json['tableToAtt'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>)
            .map(
              (e) => (e as List<dynamic>)
                  .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
                  .toSet(),
            )
            .toList(),
      )
      .toList(),
  names: (json['names'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, CellPosition.fromJson(e as Map<String, dynamic>)),
  ),
  attToCol: (json['attToCol'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    ),
  ),
  nameIndexes: (json['nameIndexes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  formatedTable: (json['formatedTable'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>)
            .map((e) => StrInt.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      .toList(),
  attToRefFromAttColToCol: _attColMapFromJson(
    json['attToRefFromAttColToCol'] as Map<String, dynamic>,
  ),
  attToRefFromDepColToCol: _depColMapFromJson(
    json['attToRefFromDepColToCol'] as Map<String, dynamic>,
  ),
  colToAtt: (json['colToAtt'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      int.parse(k),
      (e as List<dynamic>)
          .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
          .toSet(),
    ),
  ),
  isMedium: (json['isMedium'] as List<dynamic>).map((e) => e as bool).toList(),
  validRowIndexes: (json['validRowIndexes'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  currentBestSort: (json['currentBestSort'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  validAreas: (json['validAreas'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  myRules: (json['myRules'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      int.parse(k),
      (e as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          int.parse(k),
          (e as List<dynamic>)
              .map((e) => SortingRule.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
    ),
  ),
  groupAttribution: (json['groupAttribution'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  groupsToMaximize: (json['groupsToMaximize'] as List<dynamic>)
      .map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
      .toList(),
  validSortIsImpossible: json['validSortIsImpossible'] as bool,
  isFindingBestSort: json['isFindingBestSort'] as bool,
  sortedWithValidSort: json['sortedWithValidSort'] as bool,
  sortedWithCurrentBestSort: json['sortedWithCurrentBestSort'] as bool,
  bestSortPossibleFound: json['bestSortPossibleFound'] as bool,
);

Map<String, dynamic> _$AnalysisResultToJson(
  _AnalysisResult instance,
) => <String, dynamic>{
  'errorChildren': instance.errorChildren,
  'warningChildren': instance.warningChildren,
  'categoryChildren': instance.categoryChildren,
  'distPairChildren': instance.distPairChildren,
  'tableToAtt': instance.tableToAtt
      .map((e) => e.map((e) => e.toList()).toList())
      .toList(),
  'names': instance.names,
  'attToCol': instance.attToCol,
  'nameIndexes': instance.nameIndexes,
  'formatedTable': instance.formatedTable,
  'attToRefFromAttColToCol': _attColMapToJson(instance.attToRefFromAttColToCol),
  'attToRefFromDepColToCol': _depColMapToJson(instance.attToRefFromDepColToCol),
  'colToAtt': instance.colToAtt.map(
    (k, e) => MapEntry(k.toString(), e.toList()),
  ),
  'isMedium': instance.isMedium,
  'validRowIndexes': instance.validRowIndexes,
  'currentBestSort': instance.currentBestSort,
  'validAreas': instance.validAreas,
  'myRules': instance.myRules.map(
    (k, e) =>
        MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e))),
  ),
  'groupAttribution': instance.groupAttribution,
  'groupsToMaximize': instance.groupsToMaximize,
  'validSortIsImpossible': instance.validSortIsImpossible,
  'isFindingBestSort': instance.isFindingBestSort,
  'sortedWithValidSort': instance.sortedWithValidSort,
  'sortedWithCurrentBestSort': instance.sortedWithCurrentBestSort,
  'bestSortPossibleFound': instance.bestSortPossibleFound,
};
