// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrInt _$StrIntFromJson(Map<String, dynamic> json) => StrInt(
      strings:
          (json['strings'] as List<dynamic>?)?.map((e) => e as String).toList(),
      integers: (json['integers'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$StrIntToJson(StrInt instance) => <String, dynamic>{
      'strings': instance.strings,
      'integers': instance.integers,
    };

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    AnalysisResult(
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
          .map((e) => (e as List<dynamic>)
              .map((e) => (e as List<dynamic>)
                  .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
                  .toSet())
              .toList())
          .toList(),
      names: (json['names'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Cell.fromJson(e as Map<String, dynamic>)),
      ),
      attToCol: (json['attToCol'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
      ),
      nameIndexes: (json['nameIndexes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      attToRefFromAttColToCol: _attColMapFromJson(
          json['attToRefFromAttColToCol'] as Map<String, dynamic>),
      attToRefFromDepColToCol: _depColMapFromJson(
          json['attToRefFromDepColToCol'] as Map<String, dynamic>),
      formatedTable: (json['formatedTable'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => StrInt.fromJson(e as Map<String, dynamic>))
              .toList())
          .toList(),
      colToAtt: (json['colToAtt'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k),
            (e as List<dynamic>)
                .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
                .toSet()),
      ),
      myRules: (json['myRules'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            int.parse(k),
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(
                  int.parse(k),
                  (e as List<dynamic>)
                      .map((e) =>
                          SortingRule.fromJson(e as Map<String, dynamic>))
                      .toList()),
            )),
      ),
      validAreas: (json['validAreas'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
      groupsToMaximize: (json['groupsToMaximize'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
      isMedium:
          (json['isMedium'] as List<dynamic>).map((e) => e as bool).toList(),
      validRowIndexes: (json['validRowIndexes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      currentBestSort: (json['currentBestSort'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      sorted: json['sorted'] as bool,
      sortedWithCurrentBestSort: json['sortedWithCurrentBestSort'] as bool,
      bestSortPossibleFound: json['bestSortPossibleFound'] as bool,
      okToCalculateResult: json['okToCalculateResult'] as bool,
      resultCalculated: json['resultCalculated'] as bool,
      okToFindValidSort: json['okToFindValidSort'] as bool,
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'errorChildren': instance.errorChildren.map((e) => e.toJson()).toList(),
      'warningChildren':
          instance.warningChildren.map((e) => e.toJson()).toList(),
      'categoryChildren':
          instance.categoryChildren.map((e) => e.toJson()).toList(),
      'distPairChildren':
          instance.distPairChildren.map((e) => e.toJson()).toList(),
      'tableToAtt': instance.tableToAtt
          .map((e) => e.map((e) => e.map((e) => e.toJson()).toList()).toList())
          .toList(),
      'names': instance.names.map((k, e) => MapEntry(k, e.toJson())),
      'attToCol': instance.attToCol,
      'nameIndexes': instance.nameIndexes,
      'formatedTable': instance.formatedTable
          .map((e) => e.map((e) => e.toJson()).toList())
          .toList(),
      'attToRefFromAttColToCol':
          _attColMapToJson(instance.attToRefFromAttColToCol),
      'attToRefFromDepColToCol':
          _depColMapToJson(instance.attToRefFromDepColToCol),
      'colToAtt': instance.colToAtt.map(
          (k, e) => MapEntry(k.toString(), e.map((e) => e.toJson()).toList())),
      'isMedium': instance.isMedium,
      'validRowIndexes': instance.validRowIndexes,
      'currentBestSort': instance.currentBestSort,
      'validAreas': instance.validAreas,
      'myRules': instance.myRules.map((k, e) => MapEntry(
          k.toString(),
          e.map((k, e) =>
              MapEntry(k.toString(), e.map((e) => e.toJson()).toList())))),
      'groupsToMaximize': instance.groupsToMaximize,
      'sorted': instance.sorted,
      'sortedWithCurrentBestSort': instance.sortedWithCurrentBestSort,
      'bestSortPossibleFound': instance.bestSortPossibleFound,
      'okToCalculateResult': instance.okToCalculateResult,
      'resultCalculated': instance.resultCalculated,
      'okToFindValidSort': instance.okToFindValidSort,
    };
