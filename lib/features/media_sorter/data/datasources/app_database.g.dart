// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SheetDataTablesTable extends SheetDataTables
    with TableInfo<$SheetDataTablesTable, SheetDataTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetDataTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _historyIndexMeta = const VerificationMeta(
    'historyIndex',
  );
  @override
  late final GeneratedColumn<int> historyIndex = GeneratedColumn<int>(
    'history_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colHeaderHeightMeta = const VerificationMeta(
    'colHeaderHeight',
  );
  @override
  late final GeneratedColumn<double> colHeaderHeight = GeneratedColumn<double>(
    'col_header_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowHeaderWidthMeta = const VerificationMeta(
    'rowHeaderWidth',
  );
  @override
  late final GeneratedColumn<double> rowHeaderWidth = GeneratedColumn<double>(
    'row_header_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primarySelectedCellXMeta =
      const VerificationMeta('primarySelectedCellX');
  @override
  late final GeneratedColumn<int> primarySelectedCellX = GeneratedColumn<int>(
    'primary_selected_cell_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primarySelectedCellYMeta =
      const VerificationMeta('primarySelectedCellY');
  @override
  late final GeneratedColumn<int> primarySelectedCellY = GeneratedColumn<int>(
    'primary_selected_cell_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scrollOffsetXMeta = const VerificationMeta(
    'scrollOffsetX',
  );
  @override
  late final GeneratedColumn<double> scrollOffsetX = GeneratedColumn<double>(
    'scroll_offset_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scrollOffsetYMeta = const VerificationMeta(
    'scrollOffsetY',
  );
  @override
  late final GeneratedColumn<double> scrollOffsetY = GeneratedColumn<double>(
    'scroll_offset_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AnalysisResult, String>
  analysisResult =
      GeneratedColumn<String>(
        'analysis_result',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AnalysisResult>(
        $SheetDataTablesTable.$converteranalysisResult,
      );
  static const VerificationMeta _sortInProgressMeta = const VerificationMeta(
    'sortInProgress',
  );
  @override
  late final GeneratedColumn<bool> sortInProgress = GeneratedColumn<bool>(
    'sort_in_progress',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sort_in_progress" IN (0, 1))',
    ),
  );
  static const VerificationMeta _toApplyNextBestSortMeta =
      const VerificationMeta('toApplyNextBestSort');
  @override
  late final GeneratedColumn<bool> toApplyNextBestSort = GeneratedColumn<bool>(
    'to_apply_next_best_sort',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("to_apply_next_best_sort" IN (0, 1))',
    ),
  );
  static const VerificationMeta _toAlwaysApplyCurrentBestSortMeta =
      const VerificationMeta('toAlwaysApplyCurrentBestSort');
  @override
  late final GeneratedColumn<bool> toAlwaysApplyCurrentBestSort =
      GeneratedColumn<bool>(
        'to_always_apply_current_best_sort',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("to_always_apply_current_best_sort" IN (0, 1))',
        ),
      );
  static const VerificationMeta _analysisDoneMeta = const VerificationMeta(
    'analysisDone',
  );
  @override
  late final GeneratedColumn<bool> analysisDone = GeneratedColumn<bool>(
    'analysis_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("analysis_done" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    historyIndex,
    colHeaderHeight,
    rowHeaderWidth,
    primarySelectedCellX,
    primarySelectedCellY,
    scrollOffsetX,
    scrollOffsetY,
    sortIndex,
    analysisResult,
    sortInProgress,
    toApplyNextBestSort,
    toAlwaysApplyCurrentBestSort,
    analysisDone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheet_data_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetDataTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('history_index')) {
      context.handle(
        _historyIndexMeta,
        historyIndex.isAcceptableOrUnknown(
          data['history_index']!,
          _historyIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_historyIndexMeta);
    }
    if (data.containsKey('col_header_height')) {
      context.handle(
        _colHeaderHeightMeta,
        colHeaderHeight.isAcceptableOrUnknown(
          data['col_header_height']!,
          _colHeaderHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_colHeaderHeightMeta);
    }
    if (data.containsKey('row_header_width')) {
      context.handle(
        _rowHeaderWidthMeta,
        rowHeaderWidth.isAcceptableOrUnknown(
          data['row_header_width']!,
          _rowHeaderWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rowHeaderWidthMeta);
    }
    if (data.containsKey('primary_selected_cell_x')) {
      context.handle(
        _primarySelectedCellXMeta,
        primarySelectedCellX.isAcceptableOrUnknown(
          data['primary_selected_cell_x']!,
          _primarySelectedCellXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primarySelectedCellXMeta);
    }
    if (data.containsKey('primary_selected_cell_y')) {
      context.handle(
        _primarySelectedCellYMeta,
        primarySelectedCellY.isAcceptableOrUnknown(
          data['primary_selected_cell_y']!,
          _primarySelectedCellYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primarySelectedCellYMeta);
    }
    if (data.containsKey('scroll_offset_x')) {
      context.handle(
        _scrollOffsetXMeta,
        scrollOffsetX.isAcceptableOrUnknown(
          data['scroll_offset_x']!,
          _scrollOffsetXMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scrollOffsetXMeta);
    }
    if (data.containsKey('scroll_offset_y')) {
      context.handle(
        _scrollOffsetYMeta,
        scrollOffsetY.isAcceptableOrUnknown(
          data['scroll_offset_y']!,
          _scrollOffsetYMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scrollOffsetYMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('sort_in_progress')) {
      context.handle(
        _sortInProgressMeta,
        sortInProgress.isAcceptableOrUnknown(
          data['sort_in_progress']!,
          _sortInProgressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sortInProgressMeta);
    }
    if (data.containsKey('to_apply_next_best_sort')) {
      context.handle(
        _toApplyNextBestSortMeta,
        toApplyNextBestSort.isAcceptableOrUnknown(
          data['to_apply_next_best_sort']!,
          _toApplyNextBestSortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toApplyNextBestSortMeta);
    }
    if (data.containsKey('to_always_apply_current_best_sort')) {
      context.handle(
        _toAlwaysApplyCurrentBestSortMeta,
        toAlwaysApplyCurrentBestSort.isAcceptableOrUnknown(
          data['to_always_apply_current_best_sort']!,
          _toAlwaysApplyCurrentBestSortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toAlwaysApplyCurrentBestSortMeta);
    }
    if (data.containsKey('analysis_done')) {
      context.handle(
        _analysisDoneMeta,
        analysisDone.isAcceptableOrUnknown(
          data['analysis_done']!,
          _analysisDoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analysisDoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SheetDataTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetDataTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      historyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}history_index'],
      )!,
      colHeaderHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}col_header_height'],
      )!,
      rowHeaderWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}row_header_width'],
      )!,
      primarySelectedCellX: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_selected_cell_x'],
      )!,
      primarySelectedCellY: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_selected_cell_y'],
      )!,
      scrollOffsetX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_offset_x'],
      )!,
      scrollOffsetY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_offset_y'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      analysisResult: $SheetDataTablesTable.$converteranalysisResult.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}analysis_result'],
        )!,
      ),
      sortInProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sort_in_progress'],
      )!,
      toApplyNextBestSort: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}to_apply_next_best_sort'],
      )!,
      toAlwaysApplyCurrentBestSort: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}to_always_apply_current_best_sort'],
      )!,
      analysisDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}analysis_done'],
      )!,
    );
  }

  @override
  $SheetDataTablesTable createAlias(String alias) {
    return $SheetDataTablesTable(attachedDatabase, alias);
  }

  static TypeConverter<AnalysisResult, String> $converteranalysisResult =
      const AnalysisResultConverter();
}

class SheetDataTable extends DataClass implements Insertable<SheetDataTable> {
  final int id;
  final String name;
  final int historyIndex;
  final double colHeaderHeight;
  final double rowHeaderWidth;
  final int primarySelectedCellX;
  final int primarySelectedCellY;
  final double scrollOffsetX;
  final double scrollOffsetY;
  final int sortIndex;
  final AnalysisResult analysisResult;
  final bool sortInProgress;
  final bool toApplyNextBestSort;
  final bool toAlwaysApplyCurrentBestSort;
  final bool analysisDone;
  const SheetDataTable({
    required this.id,
    required this.name,
    required this.historyIndex,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
    required this.primarySelectedCellX,
    required this.primarySelectedCellY,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.sortIndex,
    required this.analysisResult,
    required this.sortInProgress,
    required this.toApplyNextBestSort,
    required this.toAlwaysApplyCurrentBestSort,
    required this.analysisDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['history_index'] = Variable<int>(historyIndex);
    map['col_header_height'] = Variable<double>(colHeaderHeight);
    map['row_header_width'] = Variable<double>(rowHeaderWidth);
    map['primary_selected_cell_x'] = Variable<int>(primarySelectedCellX);
    map['primary_selected_cell_y'] = Variable<int>(primarySelectedCellY);
    map['scroll_offset_x'] = Variable<double>(scrollOffsetX);
    map['scroll_offset_y'] = Variable<double>(scrollOffsetY);
    map['sort_index'] = Variable<int>(sortIndex);
    {
      map['analysis_result'] = Variable<String>(
        $SheetDataTablesTable.$converteranalysisResult.toSql(analysisResult),
      );
    }
    map['sort_in_progress'] = Variable<bool>(sortInProgress);
    map['to_apply_next_best_sort'] = Variable<bool>(toApplyNextBestSort);
    map['to_always_apply_current_best_sort'] = Variable<bool>(
      toAlwaysApplyCurrentBestSort,
    );
    map['analysis_done'] = Variable<bool>(analysisDone);
    return map;
  }

  SheetDataTablesCompanion toCompanion(bool nullToAbsent) {
    return SheetDataTablesCompanion(
      id: Value(id),
      name: Value(name),
      historyIndex: Value(historyIndex),
      colHeaderHeight: Value(colHeaderHeight),
      rowHeaderWidth: Value(rowHeaderWidth),
      primarySelectedCellX: Value(primarySelectedCellX),
      primarySelectedCellY: Value(primarySelectedCellY),
      scrollOffsetX: Value(scrollOffsetX),
      scrollOffsetY: Value(scrollOffsetY),
      sortIndex: Value(sortIndex),
      analysisResult: Value(analysisResult),
      sortInProgress: Value(sortInProgress),
      toApplyNextBestSort: Value(toApplyNextBestSort),
      toAlwaysApplyCurrentBestSort: Value(toAlwaysApplyCurrentBestSort),
      analysisDone: Value(analysisDone),
    );
  }

  factory SheetDataTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetDataTable(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      historyIndex: serializer.fromJson<int>(json['historyIndex']),
      colHeaderHeight: serializer.fromJson<double>(json['colHeaderHeight']),
      rowHeaderWidth: serializer.fromJson<double>(json['rowHeaderWidth']),
      primarySelectedCellX: serializer.fromJson<int>(
        json['primarySelectedCellX'],
      ),
      primarySelectedCellY: serializer.fromJson<int>(
        json['primarySelectedCellY'],
      ),
      scrollOffsetX: serializer.fromJson<double>(json['scrollOffsetX']),
      scrollOffsetY: serializer.fromJson<double>(json['scrollOffsetY']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      analysisResult: serializer.fromJson<AnalysisResult>(
        json['analysisResult'],
      ),
      sortInProgress: serializer.fromJson<bool>(json['sortInProgress']),
      toApplyNextBestSort: serializer.fromJson<bool>(
        json['toApplyNextBestSort'],
      ),
      toAlwaysApplyCurrentBestSort: serializer.fromJson<bool>(
        json['toAlwaysApplyCurrentBestSort'],
      ),
      analysisDone: serializer.fromJson<bool>(json['analysisDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'historyIndex': serializer.toJson<int>(historyIndex),
      'colHeaderHeight': serializer.toJson<double>(colHeaderHeight),
      'rowHeaderWidth': serializer.toJson<double>(rowHeaderWidth),
      'primarySelectedCellX': serializer.toJson<int>(primarySelectedCellX),
      'primarySelectedCellY': serializer.toJson<int>(primarySelectedCellY),
      'scrollOffsetX': serializer.toJson<double>(scrollOffsetX),
      'scrollOffsetY': serializer.toJson<double>(scrollOffsetY),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'analysisResult': serializer.toJson<AnalysisResult>(analysisResult),
      'sortInProgress': serializer.toJson<bool>(sortInProgress),
      'toApplyNextBestSort': serializer.toJson<bool>(toApplyNextBestSort),
      'toAlwaysApplyCurrentBestSort': serializer.toJson<bool>(
        toAlwaysApplyCurrentBestSort,
      ),
      'analysisDone': serializer.toJson<bool>(analysisDone),
    };
  }

  SheetDataTable copyWith({
    int? id,
    String? name,
    int? historyIndex,
    double? colHeaderHeight,
    double? rowHeaderWidth,
    int? primarySelectedCellX,
    int? primarySelectedCellY,
    double? scrollOffsetX,
    double? scrollOffsetY,
    int? sortIndex,
    AnalysisResult? analysisResult,
    bool? sortInProgress,
    bool? toApplyNextBestSort,
    bool? toAlwaysApplyCurrentBestSort,
    bool? analysisDone,
  }) => SheetDataTable(
    id: id ?? this.id,
    name: name ?? this.name,
    historyIndex: historyIndex ?? this.historyIndex,
    colHeaderHeight: colHeaderHeight ?? this.colHeaderHeight,
    rowHeaderWidth: rowHeaderWidth ?? this.rowHeaderWidth,
    primarySelectedCellX: primarySelectedCellX ?? this.primarySelectedCellX,
    primarySelectedCellY: primarySelectedCellY ?? this.primarySelectedCellY,
    scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
    scrollOffsetY: scrollOffsetY ?? this.scrollOffsetY,
    sortIndex: sortIndex ?? this.sortIndex,
    analysisResult: analysisResult ?? this.analysisResult,
    sortInProgress: sortInProgress ?? this.sortInProgress,
    toApplyNextBestSort: toApplyNextBestSort ?? this.toApplyNextBestSort,
    toAlwaysApplyCurrentBestSort:
        toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
    analysisDone: analysisDone ?? this.analysisDone,
  );
  SheetDataTable copyWithCompanion(SheetDataTablesCompanion data) {
    return SheetDataTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      historyIndex: data.historyIndex.present
          ? data.historyIndex.value
          : this.historyIndex,
      colHeaderHeight: data.colHeaderHeight.present
          ? data.colHeaderHeight.value
          : this.colHeaderHeight,
      rowHeaderWidth: data.rowHeaderWidth.present
          ? data.rowHeaderWidth.value
          : this.rowHeaderWidth,
      primarySelectedCellX: data.primarySelectedCellX.present
          ? data.primarySelectedCellX.value
          : this.primarySelectedCellX,
      primarySelectedCellY: data.primarySelectedCellY.present
          ? data.primarySelectedCellY.value
          : this.primarySelectedCellY,
      scrollOffsetX: data.scrollOffsetX.present
          ? data.scrollOffsetX.value
          : this.scrollOffsetX,
      scrollOffsetY: data.scrollOffsetY.present
          ? data.scrollOffsetY.value
          : this.scrollOffsetY,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      analysisResult: data.analysisResult.present
          ? data.analysisResult.value
          : this.analysisResult,
      sortInProgress: data.sortInProgress.present
          ? data.sortInProgress.value
          : this.sortInProgress,
      toApplyNextBestSort: data.toApplyNextBestSort.present
          ? data.toApplyNextBestSort.value
          : this.toApplyNextBestSort,
      toAlwaysApplyCurrentBestSort: data.toAlwaysApplyCurrentBestSort.present
          ? data.toAlwaysApplyCurrentBestSort.value
          : this.toAlwaysApplyCurrentBestSort,
      analysisDone: data.analysisDone.present
          ? data.analysisDone.value
          : this.analysisDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SheetDataTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('historyIndex: $historyIndex, ')
          ..write('colHeaderHeight: $colHeaderHeight, ')
          ..write('rowHeaderWidth: $rowHeaderWidth, ')
          ..write('primarySelectedCellX: $primarySelectedCellX, ')
          ..write('primarySelectedCellY: $primarySelectedCellY, ')
          ..write('scrollOffsetX: $scrollOffsetX, ')
          ..write('scrollOffsetY: $scrollOffsetY, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('analysisResult: $analysisResult, ')
          ..write('sortInProgress: $sortInProgress, ')
          ..write('toApplyNextBestSort: $toApplyNextBestSort, ')
          ..write(
            'toAlwaysApplyCurrentBestSort: $toAlwaysApplyCurrentBestSort, ',
          )
          ..write('analysisDone: $analysisDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    historyIndex,
    colHeaderHeight,
    rowHeaderWidth,
    primarySelectedCellX,
    primarySelectedCellY,
    scrollOffsetX,
    scrollOffsetY,
    sortIndex,
    analysisResult,
    sortInProgress,
    toApplyNextBestSort,
    toAlwaysApplyCurrentBestSort,
    analysisDone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SheetDataTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.historyIndex == this.historyIndex &&
          other.colHeaderHeight == this.colHeaderHeight &&
          other.rowHeaderWidth == this.rowHeaderWidth &&
          other.primarySelectedCellX == this.primarySelectedCellX &&
          other.primarySelectedCellY == this.primarySelectedCellY &&
          other.scrollOffsetX == this.scrollOffsetX &&
          other.scrollOffsetY == this.scrollOffsetY &&
          other.sortIndex == this.sortIndex &&
          other.analysisResult == this.analysisResult &&
          other.sortInProgress == this.sortInProgress &&
          other.toApplyNextBestSort == this.toApplyNextBestSort &&
          other.toAlwaysApplyCurrentBestSort ==
              this.toAlwaysApplyCurrentBestSort &&
          other.analysisDone == this.analysisDone);
}

class SheetDataTablesCompanion extends UpdateCompanion<SheetDataTable> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> historyIndex;
  final Value<double> colHeaderHeight;
  final Value<double> rowHeaderWidth;
  final Value<int> primarySelectedCellX;
  final Value<int> primarySelectedCellY;
  final Value<double> scrollOffsetX;
  final Value<double> scrollOffsetY;
  final Value<int> sortIndex;
  final Value<AnalysisResult> analysisResult;
  final Value<bool> sortInProgress;
  final Value<bool> toApplyNextBestSort;
  final Value<bool> toAlwaysApplyCurrentBestSort;
  final Value<bool> analysisDone;
  const SheetDataTablesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.historyIndex = const Value.absent(),
    this.colHeaderHeight = const Value.absent(),
    this.rowHeaderWidth = const Value.absent(),
    this.primarySelectedCellX = const Value.absent(),
    this.primarySelectedCellY = const Value.absent(),
    this.scrollOffsetX = const Value.absent(),
    this.scrollOffsetY = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.analysisResult = const Value.absent(),
    this.sortInProgress = const Value.absent(),
    this.toApplyNextBestSort = const Value.absent(),
    this.toAlwaysApplyCurrentBestSort = const Value.absent(),
    this.analysisDone = const Value.absent(),
  });
  SheetDataTablesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int historyIndex,
    required double colHeaderHeight,
    required double rowHeaderWidth,
    required int primarySelectedCellX,
    required int primarySelectedCellY,
    required double scrollOffsetX,
    required double scrollOffsetY,
    required int sortIndex,
    required AnalysisResult analysisResult,
    required bool sortInProgress,
    required bool toApplyNextBestSort,
    required bool toAlwaysApplyCurrentBestSort,
    required bool analysisDone,
  }) : name = Value(name),
       historyIndex = Value(historyIndex),
       colHeaderHeight = Value(colHeaderHeight),
       rowHeaderWidth = Value(rowHeaderWidth),
       primarySelectedCellX = Value(primarySelectedCellX),
       primarySelectedCellY = Value(primarySelectedCellY),
       scrollOffsetX = Value(scrollOffsetX),
       scrollOffsetY = Value(scrollOffsetY),
       sortIndex = Value(sortIndex),
       analysisResult = Value(analysisResult),
       sortInProgress = Value(sortInProgress),
       toApplyNextBestSort = Value(toApplyNextBestSort),
       toAlwaysApplyCurrentBestSort = Value(toAlwaysApplyCurrentBestSort),
       analysisDone = Value(analysisDone);
  static Insertable<SheetDataTable> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? historyIndex,
    Expression<double>? colHeaderHeight,
    Expression<double>? rowHeaderWidth,
    Expression<int>? primarySelectedCellX,
    Expression<int>? primarySelectedCellY,
    Expression<double>? scrollOffsetX,
    Expression<double>? scrollOffsetY,
    Expression<int>? sortIndex,
    Expression<String>? analysisResult,
    Expression<bool>? sortInProgress,
    Expression<bool>? toApplyNextBestSort,
    Expression<bool>? toAlwaysApplyCurrentBestSort,
    Expression<bool>? analysisDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (historyIndex != null) 'history_index': historyIndex,
      if (colHeaderHeight != null) 'col_header_height': colHeaderHeight,
      if (rowHeaderWidth != null) 'row_header_width': rowHeaderWidth,
      if (primarySelectedCellX != null)
        'primary_selected_cell_x': primarySelectedCellX,
      if (primarySelectedCellY != null)
        'primary_selected_cell_y': primarySelectedCellY,
      if (scrollOffsetX != null) 'scroll_offset_x': scrollOffsetX,
      if (scrollOffsetY != null) 'scroll_offset_y': scrollOffsetY,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (analysisResult != null) 'analysis_result': analysisResult,
      if (sortInProgress != null) 'sort_in_progress': sortInProgress,
      if (toApplyNextBestSort != null)
        'to_apply_next_best_sort': toApplyNextBestSort,
      if (toAlwaysApplyCurrentBestSort != null)
        'to_always_apply_current_best_sort': toAlwaysApplyCurrentBestSort,
      if (analysisDone != null) 'analysis_done': analysisDone,
    });
  }

  SheetDataTablesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? historyIndex,
    Value<double>? colHeaderHeight,
    Value<double>? rowHeaderWidth,
    Value<int>? primarySelectedCellX,
    Value<int>? primarySelectedCellY,
    Value<double>? scrollOffsetX,
    Value<double>? scrollOffsetY,
    Value<int>? sortIndex,
    Value<AnalysisResult>? analysisResult,
    Value<bool>? sortInProgress,
    Value<bool>? toApplyNextBestSort,
    Value<bool>? toAlwaysApplyCurrentBestSort,
    Value<bool>? analysisDone,
  }) {
    return SheetDataTablesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      historyIndex: historyIndex ?? this.historyIndex,
      colHeaderHeight: colHeaderHeight ?? this.colHeaderHeight,
      rowHeaderWidth: rowHeaderWidth ?? this.rowHeaderWidth,
      primarySelectedCellX: primarySelectedCellX ?? this.primarySelectedCellX,
      primarySelectedCellY: primarySelectedCellY ?? this.primarySelectedCellY,
      scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
      scrollOffsetY: scrollOffsetY ?? this.scrollOffsetY,
      sortIndex: sortIndex ?? this.sortIndex,
      analysisResult: analysisResult ?? this.analysisResult,
      sortInProgress: sortInProgress ?? this.sortInProgress,
      toApplyNextBestSort: toApplyNextBestSort ?? this.toApplyNextBestSort,
      toAlwaysApplyCurrentBestSort:
          toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
      analysisDone: analysisDone ?? this.analysisDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (historyIndex.present) {
      map['history_index'] = Variable<int>(historyIndex.value);
    }
    if (colHeaderHeight.present) {
      map['col_header_height'] = Variable<double>(colHeaderHeight.value);
    }
    if (rowHeaderWidth.present) {
      map['row_header_width'] = Variable<double>(rowHeaderWidth.value);
    }
    if (primarySelectedCellX.present) {
      map['primary_selected_cell_x'] = Variable<int>(
        primarySelectedCellX.value,
      );
    }
    if (primarySelectedCellY.present) {
      map['primary_selected_cell_y'] = Variable<int>(
        primarySelectedCellY.value,
      );
    }
    if (scrollOffsetX.present) {
      map['scroll_offset_x'] = Variable<double>(scrollOffsetX.value);
    }
    if (scrollOffsetY.present) {
      map['scroll_offset_y'] = Variable<double>(scrollOffsetY.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (analysisResult.present) {
      map['analysis_result'] = Variable<String>(
        $SheetDataTablesTable.$converteranalysisResult.toSql(
          analysisResult.value,
        ),
      );
    }
    if (sortInProgress.present) {
      map['sort_in_progress'] = Variable<bool>(sortInProgress.value);
    }
    if (toApplyNextBestSort.present) {
      map['to_apply_next_best_sort'] = Variable<bool>(
        toApplyNextBestSort.value,
      );
    }
    if (toAlwaysApplyCurrentBestSort.present) {
      map['to_always_apply_current_best_sort'] = Variable<bool>(
        toAlwaysApplyCurrentBestSort.value,
      );
    }
    if (analysisDone.present) {
      map['analysis_done'] = Variable<bool>(analysisDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetDataTablesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('historyIndex: $historyIndex, ')
          ..write('colHeaderHeight: $colHeaderHeight, ')
          ..write('rowHeaderWidth: $rowHeaderWidth, ')
          ..write('primarySelectedCellX: $primarySelectedCellX, ')
          ..write('primarySelectedCellY: $primarySelectedCellY, ')
          ..write('scrollOffsetX: $scrollOffsetX, ')
          ..write('scrollOffsetY: $scrollOffsetY, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('analysisResult: $analysisResult, ')
          ..write('sortInProgress: $sortInProgress, ')
          ..write('toApplyNextBestSort: $toApplyNextBestSort, ')
          ..write(
            'toAlwaysApplyCurrentBestSort: $toAlwaysApplyCurrentBestSort, ',
          )
          ..write('analysisDone: $analysisDone')
          ..write(')'))
        .toString();
  }
}

class $SheetCellsTable extends SheetCells
    with TableInfo<$SheetCellsTable, SheetCell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetCellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _rowMeta = const VerificationMeta('row');
  @override
  late final GeneratedColumn<int> row = GeneratedColumn<int>(
    'row',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colMeta = const VerificationMeta('col');
  @override
  late final GeneratedColumn<int> col = GeneratedColumn<int>(
    'col',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, row, col, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheet_cells';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetCell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('row')) {
      context.handle(
        _rowMeta,
        row.isAcceptableOrUnknown(data['row']!, _rowMeta),
      );
    } else if (isInserting) {
      context.missing(_rowMeta);
    }
    if (data.containsKey('col')) {
      context.handle(
        _colMeta,
        col.isAcceptableOrUnknown(data['col']!, _colMeta),
      );
    } else if (isInserting) {
      context.missing(_colMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, row, col};
  @override
  SheetCell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetCell(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      row: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row'],
      )!,
      col: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}col'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $SheetCellsTable createAlias(String alias) {
    return $SheetCellsTable(attachedDatabase, alias);
  }
}

class SheetCell extends DataClass implements Insertable<SheetCell> {
  final int sheetId;
  final int row;
  final int col;
  final String content;
  const SheetCell({
    required this.sheetId,
    required this.row,
    required this.col,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['row'] = Variable<int>(row);
    map['col'] = Variable<int>(col);
    map['content'] = Variable<String>(content);
    return map;
  }

  SheetCellsCompanion toCompanion(bool nullToAbsent) {
    return SheetCellsCompanion(
      sheetId: Value(sheetId),
      row: Value(row),
      col: Value(col),
      content: Value(content),
    );
  }

  factory SheetCell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetCell(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      row: serializer.fromJson<int>(json['row']),
      col: serializer.fromJson<int>(json['col']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'row': serializer.toJson<int>(row),
      'col': serializer.toJson<int>(col),
      'content': serializer.toJson<String>(content),
    };
  }

  SheetCell copyWith({int? sheetId, int? row, int? col, String? content}) =>
      SheetCell(
        sheetId: sheetId ?? this.sheetId,
        row: row ?? this.row,
        col: col ?? this.col,
        content: content ?? this.content,
      );
  SheetCell copyWithCompanion(SheetCellsCompanion data) {
    return SheetCell(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      row: data.row.present ? data.row.value : this.row,
      col: data.col.present ? data.col.value : this.col,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SheetCell(')
          ..write('sheetId: $sheetId, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, row, col, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SheetCell &&
          other.sheetId == this.sheetId &&
          other.row == this.row &&
          other.col == this.col &&
          other.content == this.content);
}

class SheetCellsCompanion extends UpdateCompanion<SheetCell> {
  final Value<int> sheetId;
  final Value<int> row;
  final Value<int> col;
  final Value<String> content;
  final Value<int> rowid;
  const SheetCellsCompanion({
    this.sheetId = const Value.absent(),
    this.row = const Value.absent(),
    this.col = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SheetCellsCompanion.insert({
    required int sheetId,
    required int row,
    required int col,
    required String content,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       row = Value(row),
       col = Value(col),
       content = Value(content);
  static Insertable<SheetCell> custom({
    Expression<int>? sheetId,
    Expression<int>? row,
    Expression<int>? col,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (row != null) 'row': row,
      if (col != null) 'col': col,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SheetCellsCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? row,
    Value<int>? col,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return SheetCellsCompanion(
      sheetId: sheetId ?? this.sheetId,
      row: row ?? this.row,
      col: col ?? this.col,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (row.present) {
      map['row'] = Variable<int>(row.value);
    }
    if (col.present) {
      map['col'] = Variable<int>(col.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetCellsCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SheetColumnTypesTable extends SheetColumnTypes
    with TableInfo<$SheetColumnTypesTable, SheetColumnType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetColumnTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _columnIndexMeta = const VerificationMeta(
    'columnIndex',
  );
  @override
  late final GeneratedColumn<int> columnIndex = GeneratedColumn<int>(
    'column_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ColumnType, int> columnType =
      GeneratedColumn<int>(
        'column_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ColumnType>($SheetColumnTypesTable.$convertercolumnType);
  @override
  List<GeneratedColumn> get $columns => [sheetId, columnIndex, columnType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheet_column_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetColumnType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('column_index')) {
      context.handle(
        _columnIndexMeta,
        columnIndex.isAcceptableOrUnknown(
          data['column_index']!,
          _columnIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_columnIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, columnIndex};
  @override
  SheetColumnType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetColumnType(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      columnIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}column_index'],
      )!,
      columnType: $SheetColumnTypesTable.$convertercolumnType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}column_type'],
        )!,
      ),
    );
  }

  @override
  $SheetColumnTypesTable createAlias(String alias) {
    return $SheetColumnTypesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ColumnType, int, int> $convertercolumnType =
      const EnumIndexConverter<ColumnType>(ColumnType.values);
}

class SheetColumnType extends DataClass implements Insertable<SheetColumnType> {
  final int sheetId;
  final int columnIndex;
  final ColumnType columnType;
  const SheetColumnType({
    required this.sheetId,
    required this.columnIndex,
    required this.columnType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['column_index'] = Variable<int>(columnIndex);
    {
      map['column_type'] = Variable<int>(
        $SheetColumnTypesTable.$convertercolumnType.toSql(columnType),
      );
    }
    return map;
  }

  SheetColumnTypesCompanion toCompanion(bool nullToAbsent) {
    return SheetColumnTypesCompanion(
      sheetId: Value(sheetId),
      columnIndex: Value(columnIndex),
      columnType: Value(columnType),
    );
  }

  factory SheetColumnType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetColumnType(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      columnIndex: serializer.fromJson<int>(json['columnIndex']),
      columnType: $SheetColumnTypesTable.$convertercolumnType.fromJson(
        serializer.fromJson<int>(json['columnType']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'columnIndex': serializer.toJson<int>(columnIndex),
      'columnType': serializer.toJson<int>(
        $SheetColumnTypesTable.$convertercolumnType.toJson(columnType),
      ),
    };
  }

  SheetColumnType copyWith({
    int? sheetId,
    int? columnIndex,
    ColumnType? columnType,
  }) => SheetColumnType(
    sheetId: sheetId ?? this.sheetId,
    columnIndex: columnIndex ?? this.columnIndex,
    columnType: columnType ?? this.columnType,
  );
  SheetColumnType copyWithCompanion(SheetColumnTypesCompanion data) {
    return SheetColumnType(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      columnIndex: data.columnIndex.present
          ? data.columnIndex.value
          : this.columnIndex,
      columnType: data.columnType.present
          ? data.columnType.value
          : this.columnType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SheetColumnType(')
          ..write('sheetId: $sheetId, ')
          ..write('columnIndex: $columnIndex, ')
          ..write('columnType: $columnType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, columnIndex, columnType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SheetColumnType &&
          other.sheetId == this.sheetId &&
          other.columnIndex == this.columnIndex &&
          other.columnType == this.columnType);
}

class SheetColumnTypesCompanion extends UpdateCompanion<SheetColumnType> {
  final Value<int> sheetId;
  final Value<int> columnIndex;
  final Value<ColumnType> columnType;
  final Value<int> rowid;
  const SheetColumnTypesCompanion({
    this.sheetId = const Value.absent(),
    this.columnIndex = const Value.absent(),
    this.columnType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SheetColumnTypesCompanion.insert({
    required int sheetId,
    required int columnIndex,
    required ColumnType columnType,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       columnIndex = Value(columnIndex),
       columnType = Value(columnType);
  static Insertable<SheetColumnType> custom({
    Expression<int>? sheetId,
    Expression<int>? columnIndex,
    Expression<int>? columnType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (columnIndex != null) 'column_index': columnIndex,
      if (columnType != null) 'column_type': columnType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SheetColumnTypesCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? columnIndex,
    Value<ColumnType>? columnType,
    Value<int>? rowid,
  }) {
    return SheetColumnTypesCompanion(
      sheetId: sheetId ?? this.sheetId,
      columnIndex: columnIndex ?? this.columnIndex,
      columnType: columnType ?? this.columnType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (columnIndex.present) {
      map['column_index'] = Variable<int>(columnIndex.value);
    }
    if (columnType.present) {
      map['column_type'] = Variable<int>(
        $SheetColumnTypesTable.$convertercolumnType.toSql(columnType.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetColumnTypesCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('columnIndex: $columnIndex, ')
          ..write('columnType: $columnType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UpdateHistoriesTable extends UpdateHistories
    with TableInfo<$UpdateHistoriesTable, UpdateHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpdateHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chronoIdMeta = const VerificationMeta(
    'chronoId',
  );
  @override
  late final GeneratedColumn<int> chronoId = GeneratedColumn<int>(
    'chrono_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, UpdateUnit>, String>
  updates =
      GeneratedColumn<String>(
        'updates',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, UpdateUnit>>(
        $UpdateHistoriesTable.$converterupdates,
      );
  @override
  List<GeneratedColumn> get $columns => [timestamp, chronoId, sheetId, updates];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'update_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpdateHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('chrono_id')) {
      context.handle(
        _chronoIdMeta,
        chronoId.isAcceptableOrUnknown(data['chrono_id']!, _chronoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chronoIdMeta);
    }
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {timestamp, chronoId};
  @override
  UpdateHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpdateHistory(
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      chronoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chrono_id'],
      )!,
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      updates: $UpdateHistoriesTable.$converterupdates.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updates'],
        )!,
      ),
    );
  }

  @override
  $UpdateHistoriesTable createAlias(String alias) {
    return $UpdateHistoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, UpdateUnit>, String> $converterupdates =
      const UpdateUnitMapConverter();
}

class UpdateHistory extends DataClass implements Insertable<UpdateHistory> {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final Map<String, UpdateUnit> updates;
  const UpdateHistory({
    required this.timestamp,
    required this.chronoId,
    required this.sheetId,
    required this.updates,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['chrono_id'] = Variable<int>(chronoId);
    map['sheet_id'] = Variable<int>(sheetId);
    {
      map['updates'] = Variable<String>(
        $UpdateHistoriesTable.$converterupdates.toSql(updates),
      );
    }
    return map;
  }

  UpdateHistoriesCompanion toCompanion(bool nullToAbsent) {
    return UpdateHistoriesCompanion(
      timestamp: Value(timestamp),
      chronoId: Value(chronoId),
      sheetId: Value(sheetId),
      updates: Value(updates),
    );
  }

  factory UpdateHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpdateHistory(
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      chronoId: serializer.fromJson<int>(json['chronoId']),
      sheetId: serializer.fromJson<int>(json['sheetId']),
      updates: serializer.fromJson<Map<String, UpdateUnit>>(json['updates']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'chronoId': serializer.toJson<int>(chronoId),
      'sheetId': serializer.toJson<int>(sheetId),
      'updates': serializer.toJson<Map<String, UpdateUnit>>(updates),
    };
  }

  UpdateHistory copyWith({
    DateTime? timestamp,
    int? chronoId,
    int? sheetId,
    Map<String, UpdateUnit>? updates,
  }) => UpdateHistory(
    timestamp: timestamp ?? this.timestamp,
    chronoId: chronoId ?? this.chronoId,
    sheetId: sheetId ?? this.sheetId,
    updates: updates ?? this.updates,
  );
  UpdateHistory copyWithCompanion(UpdateHistoriesCompanion data) {
    return UpdateHistory(
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      chronoId: data.chronoId.present ? data.chronoId.value : this.chronoId,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      updates: data.updates.present ? data.updates.value : this.updates,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistory(')
          ..write('timestamp: $timestamp, ')
          ..write('chronoId: $chronoId, ')
          ..write('sheetId: $sheetId, ')
          ..write('updates: $updates')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(timestamp, chronoId, sheetId, updates);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpdateHistory &&
          other.timestamp == this.timestamp &&
          other.chronoId == this.chronoId &&
          other.sheetId == this.sheetId &&
          other.updates == this.updates);
}

class UpdateHistoriesCompanion extends UpdateCompanion<UpdateHistory> {
  final Value<DateTime> timestamp;
  final Value<int> chronoId;
  final Value<int> sheetId;
  final Value<Map<String, UpdateUnit>> updates;
  final Value<int> rowid;
  const UpdateHistoriesCompanion({
    this.timestamp = const Value.absent(),
    this.chronoId = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.updates = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UpdateHistoriesCompanion.insert({
    required DateTime timestamp,
    required int chronoId,
    required int sheetId,
    required Map<String, UpdateUnit> updates,
    this.rowid = const Value.absent(),
  }) : timestamp = Value(timestamp),
       chronoId = Value(chronoId),
       sheetId = Value(sheetId),
       updates = Value(updates);
  static Insertable<UpdateHistory> custom({
    Expression<DateTime>? timestamp,
    Expression<int>? chronoId,
    Expression<int>? sheetId,
    Expression<String>? updates,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (timestamp != null) 'timestamp': timestamp,
      if (chronoId != null) 'chrono_id': chronoId,
      if (sheetId != null) 'sheet_id': sheetId,
      if (updates != null) 'updates': updates,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UpdateHistoriesCompanion copyWith({
    Value<DateTime>? timestamp,
    Value<int>? chronoId,
    Value<int>? sheetId,
    Value<Map<String, UpdateUnit>>? updates,
    Value<int>? rowid,
  }) {
    return UpdateHistoriesCompanion(
      timestamp: timestamp ?? this.timestamp,
      chronoId: chronoId ?? this.chronoId,
      sheetId: sheetId ?? this.sheetId,
      updates: updates ?? this.updates,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (chronoId.present) {
      map['chrono_id'] = Variable<int>(chronoId.value);
    }
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (updates.present) {
      map['updates'] = Variable<String>(
        $UpdateHistoriesTable.$converterupdates.toSql(updates.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistoriesCompanion(')
          ..write('timestamp: $timestamp, ')
          ..write('chronoId: $chronoId, ')
          ..write('sheetId: $sheetId, ')
          ..write('updates: $updates, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RowsBottomPosTable extends RowsBottomPos
    with TableInfo<$RowsBottomPosTable, RowsBottomPo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RowsBottomPosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _rowIndexMeta = const VerificationMeta(
    'rowIndex',
  );
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
    'row_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottomPosMeta = const VerificationMeta(
    'bottomPos',
  );
  @override
  late final GeneratedColumn<double> bottomPos = GeneratedColumn<double>(
    'bottom_pos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, rowIndex, bottomPos];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rows_bottom_pos';
  @override
  VerificationContext validateIntegrity(
    Insertable<RowsBottomPo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(
        _rowIndexMeta,
        rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('bottom_pos')) {
      context.handle(
        _bottomPosMeta,
        bottomPos.isAcceptableOrUnknown(data['bottom_pos']!, _bottomPosMeta),
      );
    } else if (isInserting) {
      context.missing(_bottomPosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, rowIndex};
  @override
  RowsBottomPo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RowsBottomPo(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      rowIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_index'],
      )!,
      bottomPos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_pos'],
      )!,
    );
  }

  @override
  $RowsBottomPosTable createAlias(String alias) {
    return $RowsBottomPosTable(attachedDatabase, alias);
  }
}

class RowsBottomPo extends DataClass implements Insertable<RowsBottomPo> {
  final int sheetId;
  final int rowIndex;
  final double bottomPos;
  const RowsBottomPo({
    required this.sheetId,
    required this.rowIndex,
    required this.bottomPos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['row_index'] = Variable<int>(rowIndex);
    map['bottom_pos'] = Variable<double>(bottomPos);
    return map;
  }

  RowsBottomPosCompanion toCompanion(bool nullToAbsent) {
    return RowsBottomPosCompanion(
      sheetId: Value(sheetId),
      rowIndex: Value(rowIndex),
      bottomPos: Value(bottomPos),
    );
  }

  factory RowsBottomPo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RowsBottomPo(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      bottomPos: serializer.fromJson<double>(json['bottomPos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'bottomPos': serializer.toJson<double>(bottomPos),
    };
  }

  RowsBottomPo copyWith({int? sheetId, int? rowIndex, double? bottomPos}) =>
      RowsBottomPo(
        sheetId: sheetId ?? this.sheetId,
        rowIndex: rowIndex ?? this.rowIndex,
        bottomPos: bottomPos ?? this.bottomPos,
      );
  RowsBottomPo copyWithCompanion(RowsBottomPosCompanion data) {
    return RowsBottomPo(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      bottomPos: data.bottomPos.present ? data.bottomPos.value : this.bottomPos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RowsBottomPo(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('bottomPos: $bottomPos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, rowIndex, bottomPos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RowsBottomPo &&
          other.sheetId == this.sheetId &&
          other.rowIndex == this.rowIndex &&
          other.bottomPos == this.bottomPos);
}

class RowsBottomPosCompanion extends UpdateCompanion<RowsBottomPo> {
  final Value<int> sheetId;
  final Value<int> rowIndex;
  final Value<double> bottomPos;
  final Value<int> rowid;
  const RowsBottomPosCompanion({
    this.sheetId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.bottomPos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RowsBottomPosCompanion.insert({
    required int sheetId,
    required int rowIndex,
    required double bottomPos,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       rowIndex = Value(rowIndex),
       bottomPos = Value(bottomPos);
  static Insertable<RowsBottomPo> custom({
    Expression<int>? sheetId,
    Expression<int>? rowIndex,
    Expression<double>? bottomPos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (rowIndex != null) 'row_index': rowIndex,
      if (bottomPos != null) 'bottom_pos': bottomPos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RowsBottomPosCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? rowIndex,
    Value<double>? bottomPos,
    Value<int>? rowid,
  }) {
    return RowsBottomPosCompanion(
      sheetId: sheetId ?? this.sheetId,
      rowIndex: rowIndex ?? this.rowIndex,
      bottomPos: bottomPos ?? this.bottomPos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (bottomPos.present) {
      map['bottom_pos'] = Variable<double>(bottomPos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RowsBottomPosCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('bottomPos: $bottomPos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColRightPosTable extends ColRightPos
    with TableInfo<$ColRightPosTable, ColRightPo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColRightPosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _colIndexMeta = const VerificationMeta(
    'colIndex',
  );
  @override
  late final GeneratedColumn<int> colIndex = GeneratedColumn<int>(
    'col_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rightPosMeta = const VerificationMeta(
    'rightPos',
  );
  @override
  late final GeneratedColumn<double> rightPos = GeneratedColumn<double>(
    'right_pos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, colIndex, rightPos];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'col_right_pos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColRightPo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('col_index')) {
      context.handle(
        _colIndexMeta,
        colIndex.isAcceptableOrUnknown(data['col_index']!, _colIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_colIndexMeta);
    }
    if (data.containsKey('right_pos')) {
      context.handle(
        _rightPosMeta,
        rightPos.isAcceptableOrUnknown(data['right_pos']!, _rightPosMeta),
      );
    } else if (isInserting) {
      context.missing(_rightPosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, colIndex};
  @override
  ColRightPo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColRightPo(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      colIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}col_index'],
      )!,
      rightPos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_pos'],
      )!,
    );
  }

  @override
  $ColRightPosTable createAlias(String alias) {
    return $ColRightPosTable(attachedDatabase, alias);
  }
}

class ColRightPo extends DataClass implements Insertable<ColRightPo> {
  final int sheetId;
  final int colIndex;
  final double rightPos;
  const ColRightPo({
    required this.sheetId,
    required this.colIndex,
    required this.rightPos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['col_index'] = Variable<int>(colIndex);
    map['right_pos'] = Variable<double>(rightPos);
    return map;
  }

  ColRightPosCompanion toCompanion(bool nullToAbsent) {
    return ColRightPosCompanion(
      sheetId: Value(sheetId),
      colIndex: Value(colIndex),
      rightPos: Value(rightPos),
    );
  }

  factory ColRightPo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColRightPo(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      colIndex: serializer.fromJson<int>(json['colIndex']),
      rightPos: serializer.fromJson<double>(json['rightPos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'colIndex': serializer.toJson<int>(colIndex),
      'rightPos': serializer.toJson<double>(rightPos),
    };
  }

  ColRightPo copyWith({int? sheetId, int? colIndex, double? rightPos}) =>
      ColRightPo(
        sheetId: sheetId ?? this.sheetId,
        colIndex: colIndex ?? this.colIndex,
        rightPos: rightPos ?? this.rightPos,
      );
  ColRightPo copyWithCompanion(ColRightPosCompanion data) {
    return ColRightPo(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      colIndex: data.colIndex.present ? data.colIndex.value : this.colIndex,
      rightPos: data.rightPos.present ? data.rightPos.value : this.rightPos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColRightPo(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('rightPos: $rightPos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, colIndex, rightPos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColRightPo &&
          other.sheetId == this.sheetId &&
          other.colIndex == this.colIndex &&
          other.rightPos == this.rightPos);
}

class ColRightPosCompanion extends UpdateCompanion<ColRightPo> {
  final Value<int> sheetId;
  final Value<int> colIndex;
  final Value<double> rightPos;
  final Value<int> rowid;
  const ColRightPosCompanion({
    this.sheetId = const Value.absent(),
    this.colIndex = const Value.absent(),
    this.rightPos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColRightPosCompanion.insert({
    required int sheetId,
    required int colIndex,
    required double rightPos,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       colIndex = Value(colIndex),
       rightPos = Value(rightPos);
  static Insertable<ColRightPo> custom({
    Expression<int>? sheetId,
    Expression<int>? colIndex,
    Expression<double>? rightPos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (colIndex != null) 'col_index': colIndex,
      if (rightPos != null) 'right_pos': rightPos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColRightPosCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? colIndex,
    Value<double>? rightPos,
    Value<int>? rowid,
  }) {
    return ColRightPosCompanion(
      sheetId: sheetId ?? this.sheetId,
      colIndex: colIndex ?? this.colIndex,
      rightPos: rightPos ?? this.rightPos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (colIndex.present) {
      map['col_index'] = Variable<int>(colIndex.value);
    }
    if (rightPos.present) {
      map['right_pos'] = Variable<double>(rightPos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColRightPosCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('rightPos: $rightPos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RowsManuallyAdjustedHeightTable extends RowsManuallyAdjustedHeight
    with
        TableInfo<
          $RowsManuallyAdjustedHeightTable,
          RowsManuallyAdjustedHeightData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RowsManuallyAdjustedHeightTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _rowIndexMeta = const VerificationMeta(
    'rowIndex',
  );
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
    'row_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manuallyAdjustedMeta = const VerificationMeta(
    'manuallyAdjusted',
  );
  @override
  late final GeneratedColumn<bool> manuallyAdjusted = GeneratedColumn<bool>(
    'manually_adjusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manually_adjusted" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, rowIndex, manuallyAdjusted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rows_manually_adjusted_height';
  @override
  VerificationContext validateIntegrity(
    Insertable<RowsManuallyAdjustedHeightData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(
        _rowIndexMeta,
        rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('manually_adjusted')) {
      context.handle(
        _manuallyAdjustedMeta,
        manuallyAdjusted.isAcceptableOrUnknown(
          data['manually_adjusted']!,
          _manuallyAdjustedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manuallyAdjustedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, rowIndex};
  @override
  RowsManuallyAdjustedHeightData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RowsManuallyAdjustedHeightData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      rowIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_index'],
      )!,
      manuallyAdjusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manually_adjusted'],
      )!,
    );
  }

  @override
  $RowsManuallyAdjustedHeightTable createAlias(String alias) {
    return $RowsManuallyAdjustedHeightTable(attachedDatabase, alias);
  }
}

class RowsManuallyAdjustedHeightData extends DataClass
    implements Insertable<RowsManuallyAdjustedHeightData> {
  final int sheetId;
  final int rowIndex;
  final bool manuallyAdjusted;
  const RowsManuallyAdjustedHeightData({
    required this.sheetId,
    required this.rowIndex,
    required this.manuallyAdjusted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['row_index'] = Variable<int>(rowIndex);
    map['manually_adjusted'] = Variable<bool>(manuallyAdjusted);
    return map;
  }

  RowsManuallyAdjustedHeightCompanion toCompanion(bool nullToAbsent) {
    return RowsManuallyAdjustedHeightCompanion(
      sheetId: Value(sheetId),
      rowIndex: Value(rowIndex),
      manuallyAdjusted: Value(manuallyAdjusted),
    );
  }

  factory RowsManuallyAdjustedHeightData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RowsManuallyAdjustedHeightData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      manuallyAdjusted: serializer.fromJson<bool>(json['manuallyAdjusted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'manuallyAdjusted': serializer.toJson<bool>(manuallyAdjusted),
    };
  }

  RowsManuallyAdjustedHeightData copyWith({
    int? sheetId,
    int? rowIndex,
    bool? manuallyAdjusted,
  }) => RowsManuallyAdjustedHeightData(
    sheetId: sheetId ?? this.sheetId,
    rowIndex: rowIndex ?? this.rowIndex,
    manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
  );
  RowsManuallyAdjustedHeightData copyWithCompanion(
    RowsManuallyAdjustedHeightCompanion data,
  ) {
    return RowsManuallyAdjustedHeightData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      manuallyAdjusted: data.manuallyAdjusted.present
          ? data.manuallyAdjusted.value
          : this.manuallyAdjusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RowsManuallyAdjustedHeightData(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, rowIndex, manuallyAdjusted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RowsManuallyAdjustedHeightData &&
          other.sheetId == this.sheetId &&
          other.rowIndex == this.rowIndex &&
          other.manuallyAdjusted == this.manuallyAdjusted);
}

class RowsManuallyAdjustedHeightCompanion
    extends UpdateCompanion<RowsManuallyAdjustedHeightData> {
  final Value<int> sheetId;
  final Value<int> rowIndex;
  final Value<bool> manuallyAdjusted;
  final Value<int> rowid;
  const RowsManuallyAdjustedHeightCompanion({
    this.sheetId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.manuallyAdjusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RowsManuallyAdjustedHeightCompanion.insert({
    required int sheetId,
    required int rowIndex,
    required bool manuallyAdjusted,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       rowIndex = Value(rowIndex),
       manuallyAdjusted = Value(manuallyAdjusted);
  static Insertable<RowsManuallyAdjustedHeightData> custom({
    Expression<int>? sheetId,
    Expression<int>? rowIndex,
    Expression<bool>? manuallyAdjusted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (rowIndex != null) 'row_index': rowIndex,
      if (manuallyAdjusted != null) 'manually_adjusted': manuallyAdjusted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RowsManuallyAdjustedHeightCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? rowIndex,
    Value<bool>? manuallyAdjusted,
    Value<int>? rowid,
  }) {
    return RowsManuallyAdjustedHeightCompanion(
      sheetId: sheetId ?? this.sheetId,
      rowIndex: rowIndex ?? this.rowIndex,
      manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (manuallyAdjusted.present) {
      map['manually_adjusted'] = Variable<bool>(manuallyAdjusted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RowsManuallyAdjustedHeightCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColsManuallyAdjustedWidthTable extends ColsManuallyAdjustedWidth
    with
        TableInfo<
          $ColsManuallyAdjustedWidthTable,
          ColsManuallyAdjustedWidthData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColsManuallyAdjustedWidthTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _colIndexMeta = const VerificationMeta(
    'colIndex',
  );
  @override
  late final GeneratedColumn<int> colIndex = GeneratedColumn<int>(
    'col_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manuallyAdjustedMeta = const VerificationMeta(
    'manuallyAdjusted',
  );
  @override
  late final GeneratedColumn<bool> manuallyAdjusted = GeneratedColumn<bool>(
    'manually_adjusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manually_adjusted" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, colIndex, manuallyAdjusted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cols_manually_adjusted_width';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColsManuallyAdjustedWidthData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('col_index')) {
      context.handle(
        _colIndexMeta,
        colIndex.isAcceptableOrUnknown(data['col_index']!, _colIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_colIndexMeta);
    }
    if (data.containsKey('manually_adjusted')) {
      context.handle(
        _manuallyAdjustedMeta,
        manuallyAdjusted.isAcceptableOrUnknown(
          data['manually_adjusted']!,
          _manuallyAdjustedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manuallyAdjustedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, colIndex};
  @override
  ColsManuallyAdjustedWidthData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColsManuallyAdjustedWidthData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      colIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}col_index'],
      )!,
      manuallyAdjusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manually_adjusted'],
      )!,
    );
  }

  @override
  $ColsManuallyAdjustedWidthTable createAlias(String alias) {
    return $ColsManuallyAdjustedWidthTable(attachedDatabase, alias);
  }
}

class ColsManuallyAdjustedWidthData extends DataClass
    implements Insertable<ColsManuallyAdjustedWidthData> {
  final int sheetId;
  final int colIndex;
  final bool manuallyAdjusted;
  const ColsManuallyAdjustedWidthData({
    required this.sheetId,
    required this.colIndex,
    required this.manuallyAdjusted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['col_index'] = Variable<int>(colIndex);
    map['manually_adjusted'] = Variable<bool>(manuallyAdjusted);
    return map;
  }

  ColsManuallyAdjustedWidthCompanion toCompanion(bool nullToAbsent) {
    return ColsManuallyAdjustedWidthCompanion(
      sheetId: Value(sheetId),
      colIndex: Value(colIndex),
      manuallyAdjusted: Value(manuallyAdjusted),
    );
  }

  factory ColsManuallyAdjustedWidthData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColsManuallyAdjustedWidthData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      colIndex: serializer.fromJson<int>(json['colIndex']),
      manuallyAdjusted: serializer.fromJson<bool>(json['manuallyAdjusted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'colIndex': serializer.toJson<int>(colIndex),
      'manuallyAdjusted': serializer.toJson<bool>(manuallyAdjusted),
    };
  }

  ColsManuallyAdjustedWidthData copyWith({
    int? sheetId,
    int? colIndex,
    bool? manuallyAdjusted,
  }) => ColsManuallyAdjustedWidthData(
    sheetId: sheetId ?? this.sheetId,
    colIndex: colIndex ?? this.colIndex,
    manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
  );
  ColsManuallyAdjustedWidthData copyWithCompanion(
    ColsManuallyAdjustedWidthCompanion data,
  ) {
    return ColsManuallyAdjustedWidthData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      colIndex: data.colIndex.present ? data.colIndex.value : this.colIndex,
      manuallyAdjusted: data.manuallyAdjusted.present
          ? data.manuallyAdjusted.value
          : this.manuallyAdjusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColsManuallyAdjustedWidthData(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, colIndex, manuallyAdjusted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColsManuallyAdjustedWidthData &&
          other.sheetId == this.sheetId &&
          other.colIndex == this.colIndex &&
          other.manuallyAdjusted == this.manuallyAdjusted);
}

class ColsManuallyAdjustedWidthCompanion
    extends UpdateCompanion<ColsManuallyAdjustedWidthData> {
  final Value<int> sheetId;
  final Value<int> colIndex;
  final Value<bool> manuallyAdjusted;
  final Value<int> rowid;
  const ColsManuallyAdjustedWidthCompanion({
    this.sheetId = const Value.absent(),
    this.colIndex = const Value.absent(),
    this.manuallyAdjusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColsManuallyAdjustedWidthCompanion.insert({
    required int sheetId,
    required int colIndex,
    required bool manuallyAdjusted,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       colIndex = Value(colIndex),
       manuallyAdjusted = Value(manuallyAdjusted);
  static Insertable<ColsManuallyAdjustedWidthData> custom({
    Expression<int>? sheetId,
    Expression<int>? colIndex,
    Expression<bool>? manuallyAdjusted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (colIndex != null) 'col_index': colIndex,
      if (manuallyAdjusted != null) 'manually_adjusted': manuallyAdjusted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColsManuallyAdjustedWidthCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? colIndex,
    Value<bool>? manuallyAdjusted,
    Value<int>? rowid,
  }) {
    return ColsManuallyAdjustedWidthCompanion(
      sheetId: sheetId ?? this.sheetId,
      colIndex: colIndex ?? this.colIndex,
      manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (colIndex.present) {
      map['col_index'] = Variable<int>(colIndex.value);
    }
    if (manuallyAdjusted.present) {
      map['manually_adjusted'] = Variable<bool>(manuallyAdjusted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColsManuallyAdjustedWidthCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SelectedCellsTable extends SelectedCells
    with TableInfo<$SelectedCellsTable, SelectedCell> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SelectedCellsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _cellIndexMeta = const VerificationMeta(
    'cellIndex',
  );
  @override
  late final GeneratedColumn<int> cellIndex = GeneratedColumn<int>(
    'cell_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowMeta = const VerificationMeta('row');
  @override
  late final GeneratedColumn<int> row = GeneratedColumn<int>(
    'row',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colMeta = const VerificationMeta('col');
  @override
  late final GeneratedColumn<int> col = GeneratedColumn<int>(
    'col',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, cellIndex, row, col];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'selected_cells';
  @override
  VerificationContext validateIntegrity(
    Insertable<SelectedCell> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('cell_index')) {
      context.handle(
        _cellIndexMeta,
        cellIndex.isAcceptableOrUnknown(data['cell_index']!, _cellIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_cellIndexMeta);
    }
    if (data.containsKey('row')) {
      context.handle(
        _rowMeta,
        row.isAcceptableOrUnknown(data['row']!, _rowMeta),
      );
    } else if (isInserting) {
      context.missing(_rowMeta);
    }
    if (data.containsKey('col')) {
      context.handle(
        _colMeta,
        col.isAcceptableOrUnknown(data['col']!, _colMeta),
      );
    } else if (isInserting) {
      context.missing(_colMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, cellIndex};
  @override
  SelectedCell map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SelectedCell(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      cellIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cell_index'],
      )!,
      row: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row'],
      )!,
      col: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}col'],
      )!,
    );
  }

  @override
  $SelectedCellsTable createAlias(String alias) {
    return $SelectedCellsTable(attachedDatabase, alias);
  }
}

class SelectedCell extends DataClass implements Insertable<SelectedCell> {
  final int sheetId;
  final int cellIndex;
  final int row;
  final int col;
  const SelectedCell({
    required this.sheetId,
    required this.cellIndex,
    required this.row,
    required this.col,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['cell_index'] = Variable<int>(cellIndex);
    map['row'] = Variable<int>(row);
    map['col'] = Variable<int>(col);
    return map;
  }

  SelectedCellsCompanion toCompanion(bool nullToAbsent) {
    return SelectedCellsCompanion(
      sheetId: Value(sheetId),
      cellIndex: Value(cellIndex),
      row: Value(row),
      col: Value(col),
    );
  }

  factory SelectedCell.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SelectedCell(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      cellIndex: serializer.fromJson<int>(json['cellIndex']),
      row: serializer.fromJson<int>(json['row']),
      col: serializer.fromJson<int>(json['col']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'cellIndex': serializer.toJson<int>(cellIndex),
      'row': serializer.toJson<int>(row),
      'col': serializer.toJson<int>(col),
    };
  }

  SelectedCell copyWith({int? sheetId, int? cellIndex, int? row, int? col}) =>
      SelectedCell(
        sheetId: sheetId ?? this.sheetId,
        cellIndex: cellIndex ?? this.cellIndex,
        row: row ?? this.row,
        col: col ?? this.col,
      );
  SelectedCell copyWithCompanion(SelectedCellsCompanion data) {
    return SelectedCell(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      cellIndex: data.cellIndex.present ? data.cellIndex.value : this.cellIndex,
      row: data.row.present ? data.row.value : this.row,
      col: data.col.present ? data.col.value : this.col,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SelectedCell(')
          ..write('sheetId: $sheetId, ')
          ..write('cellIndex: $cellIndex, ')
          ..write('row: $row, ')
          ..write('col: $col')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, cellIndex, row, col);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SelectedCell &&
          other.sheetId == this.sheetId &&
          other.cellIndex == this.cellIndex &&
          other.row == this.row &&
          other.col == this.col);
}

class SelectedCellsCompanion extends UpdateCompanion<SelectedCell> {
  final Value<int> sheetId;
  final Value<int> cellIndex;
  final Value<int> row;
  final Value<int> col;
  final Value<int> rowid;
  const SelectedCellsCompanion({
    this.sheetId = const Value.absent(),
    this.cellIndex = const Value.absent(),
    this.row = const Value.absent(),
    this.col = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SelectedCellsCompanion.insert({
    required int sheetId,
    required int cellIndex,
    required int row,
    required int col,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       cellIndex = Value(cellIndex),
       row = Value(row),
       col = Value(col);
  static Insertable<SelectedCell> custom({
    Expression<int>? sheetId,
    Expression<int>? cellIndex,
    Expression<int>? row,
    Expression<int>? col,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (cellIndex != null) 'cell_index': cellIndex,
      if (row != null) 'row': row,
      if (col != null) 'col': col,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SelectedCellsCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? cellIndex,
    Value<int>? row,
    Value<int>? col,
    Value<int>? rowid,
  }) {
    return SelectedCellsCompanion(
      sheetId: sheetId ?? this.sheetId,
      cellIndex: cellIndex ?? this.cellIndex,
      row: row ?? this.row,
      col: col ?? this.col,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (cellIndex.present) {
      map['cell_index'] = Variable<int>(cellIndex.value);
    }
    if (row.present) {
      map['row'] = Variable<int>(row.value);
    }
    if (col.present) {
      map['col'] = Variable<int>(col.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SelectedCellsCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('cellIndex: $cellIndex, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BestSortFoundTable extends BestSortFound
    with TableInfo<$BestSortFoundTable, BestSortFoundData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BestSortFoundTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, sortIndex, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'best_sort_found';
  @override
  VerificationContext validateIntegrity(
    Insertable<BestSortFoundData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, sortIndex};
  @override
  BestSortFoundData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BestSortFoundData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $BestSortFoundTable createAlias(String alias) {
    return $BestSortFoundTable(attachedDatabase, alias);
  }
}

class BestSortFoundData extends DataClass
    implements Insertable<BestSortFoundData> {
  final int sheetId;
  final int sortIndex;
  final int value;
  const BestSortFoundData({
    required this.sheetId,
    required this.sortIndex,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['sort_index'] = Variable<int>(sortIndex);
    map['value'] = Variable<int>(value);
    return map;
  }

  BestSortFoundCompanion toCompanion(bool nullToAbsent) {
    return BestSortFoundCompanion(
      sheetId: Value(sheetId),
      sortIndex: Value(sortIndex),
      value: Value(value),
    );
  }

  factory BestSortFoundData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BestSortFoundData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'value': serializer.toJson<int>(value),
    };
  }

  BestSortFoundData copyWith({int? sheetId, int? sortIndex, int? value}) =>
      BestSortFoundData(
        sheetId: sheetId ?? this.sheetId,
        sortIndex: sortIndex ?? this.sortIndex,
        value: value ?? this.value,
      );
  BestSortFoundData copyWithCompanion(BestSortFoundCompanion data) {
    return BestSortFoundData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BestSortFoundData(')
          ..write('sheetId: $sheetId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, sortIndex, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BestSortFoundData &&
          other.sheetId == this.sheetId &&
          other.sortIndex == this.sortIndex &&
          other.value == this.value);
}

class BestSortFoundCompanion extends UpdateCompanion<BestSortFoundData> {
  final Value<int> sheetId;
  final Value<int> sortIndex;
  final Value<int> value;
  final Value<int> rowid;
  const BestSortFoundCompanion({
    this.sheetId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BestSortFoundCompanion.insert({
    required int sheetId,
    required int sortIndex,
    required int value,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       sortIndex = Value(sortIndex),
       value = Value(value);
  static Insertable<BestSortFoundData> custom({
    Expression<int>? sheetId,
    Expression<int>? sortIndex,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BestSortFoundCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? sortIndex,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return BestSortFoundCompanion(
      sheetId: sheetId ?? this.sheetId,
      sortIndex: sortIndex ?? this.sortIndex,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BestSortFoundCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CursorsTable extends Cursors with TableInfo<$CursorsTable, Cursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _cursorIndexMeta = const VerificationMeta(
    'cursorIndex',
  );
  @override
  late final GeneratedColumn<int> cursorIndex = GeneratedColumn<int>(
    'cursor_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, cursorIndex, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('cursor_index')) {
      context.handle(
        _cursorIndexMeta,
        cursorIndex.isAcceptableOrUnknown(
          data['cursor_index']!,
          _cursorIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cursorIndexMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, cursorIndex};
  @override
  Cursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cursor(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      cursorIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor_index'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $CursorsTable createAlias(String alias) {
    return $CursorsTable(attachedDatabase, alias);
  }
}

class Cursor extends DataClass implements Insertable<Cursor> {
  final int sheetId;
  final int cursorIndex;
  final int value;
  const Cursor({
    required this.sheetId,
    required this.cursorIndex,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['cursor_index'] = Variable<int>(cursorIndex);
    map['value'] = Variable<int>(value);
    return map;
  }

  CursorsCompanion toCompanion(bool nullToAbsent) {
    return CursorsCompanion(
      sheetId: Value(sheetId),
      cursorIndex: Value(cursorIndex),
      value: Value(value),
    );
  }

  factory Cursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cursor(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      cursorIndex: serializer.fromJson<int>(json['cursorIndex']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'cursorIndex': serializer.toJson<int>(cursorIndex),
      'value': serializer.toJson<int>(value),
    };
  }

  Cursor copyWith({int? sheetId, int? cursorIndex, int? value}) => Cursor(
    sheetId: sheetId ?? this.sheetId,
    cursorIndex: cursorIndex ?? this.cursorIndex,
    value: value ?? this.value,
  );
  Cursor copyWithCompanion(CursorsCompanion data) {
    return Cursor(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      cursorIndex: data.cursorIndex.present
          ? data.cursorIndex.value
          : this.cursorIndex,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cursor(')
          ..write('sheetId: $sheetId, ')
          ..write('cursorIndex: $cursorIndex, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, cursorIndex, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cursor &&
          other.sheetId == this.sheetId &&
          other.cursorIndex == this.cursorIndex &&
          other.value == this.value);
}

class CursorsCompanion extends UpdateCompanion<Cursor> {
  final Value<int> sheetId;
  final Value<int> cursorIndex;
  final Value<int> value;
  final Value<int> rowid;
  const CursorsCompanion({
    this.sheetId = const Value.absent(),
    this.cursorIndex = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CursorsCompanion.insert({
    required int sheetId,
    required int cursorIndex,
    required int value,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       cursorIndex = Value(cursorIndex),
       value = Value(value);
  static Insertable<Cursor> custom({
    Expression<int>? sheetId,
    Expression<int>? cursorIndex,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (cursorIndex != null) 'cursor_index': cursorIndex,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CursorsCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? cursorIndex,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return CursorsCompanion(
      sheetId: sheetId ?? this.sheetId,
      cursorIndex: cursorIndex ?? this.cursorIndex,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (cursorIndex.present) {
      map['cursor_index'] = Variable<int>(cursorIndex.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CursorsCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('cursorIndex: $cursorIndex, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PossibleIntsByIdTable extends PossibleIntsById
    with TableInfo<$PossibleIntsByIdTable, PossibleIntsByIdData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PossibleIntsByIdTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intIndexMeta = const VerificationMeta(
    'intIndex',
  );
  @override
  late final GeneratedColumn<int> intIndex = GeneratedColumn<int>(
    'int_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, id, intIndex, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'possible_ints_by_id';
  @override
  VerificationContext validateIntegrity(
    Insertable<PossibleIntsByIdData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('int_index')) {
      context.handle(
        _intIndexMeta,
        intIndex.isAcceptableOrUnknown(data['int_index']!, _intIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_intIndexMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, id, intIndex};
  @override
  PossibleIntsByIdData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PossibleIntsByIdData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      intIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_index'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PossibleIntsByIdTable createAlias(String alias) {
    return $PossibleIntsByIdTable(attachedDatabase, alias);
  }
}

class PossibleIntsByIdData extends DataClass
    implements Insertable<PossibleIntsByIdData> {
  final int sheetId;
  final int id;
  final int intIndex;
  final int value;
  const PossibleIntsByIdData({
    required this.sheetId,
    required this.id,
    required this.intIndex,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['id'] = Variable<int>(id);
    map['int_index'] = Variable<int>(intIndex);
    map['value'] = Variable<int>(value);
    return map;
  }

  PossibleIntsByIdCompanion toCompanion(bool nullToAbsent) {
    return PossibleIntsByIdCompanion(
      sheetId: Value(sheetId),
      id: Value(id),
      intIndex: Value(intIndex),
      value: Value(value),
    );
  }

  factory PossibleIntsByIdData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PossibleIntsByIdData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      id: serializer.fromJson<int>(json['id']),
      intIndex: serializer.fromJson<int>(json['intIndex']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'id': serializer.toJson<int>(id),
      'intIndex': serializer.toJson<int>(intIndex),
      'value': serializer.toJson<int>(value),
    };
  }

  PossibleIntsByIdData copyWith({
    int? sheetId,
    int? id,
    int? intIndex,
    int? value,
  }) => PossibleIntsByIdData(
    sheetId: sheetId ?? this.sheetId,
    id: id ?? this.id,
    intIndex: intIndex ?? this.intIndex,
    value: value ?? this.value,
  );
  PossibleIntsByIdData copyWithCompanion(PossibleIntsByIdCompanion data) {
    return PossibleIntsByIdData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      id: data.id.present ? data.id.value : this.id,
      intIndex: data.intIndex.present ? data.intIndex.value : this.intIndex,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PossibleIntsByIdData(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('intIndex: $intIndex, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, id, intIndex, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PossibleIntsByIdData &&
          other.sheetId == this.sheetId &&
          other.id == this.id &&
          other.intIndex == this.intIndex &&
          other.value == this.value);
}

class PossibleIntsByIdCompanion extends UpdateCompanion<PossibleIntsByIdData> {
  final Value<int> sheetId;
  final Value<int> id;
  final Value<int> intIndex;
  final Value<int> value;
  final Value<int> rowid;
  const PossibleIntsByIdCompanion({
    this.sheetId = const Value.absent(),
    this.id = const Value.absent(),
    this.intIndex = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PossibleIntsByIdCompanion.insert({
    required int sheetId,
    required int id,
    required int intIndex,
    required int value,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       id = Value(id),
       intIndex = Value(intIndex),
       value = Value(value);
  static Insertable<PossibleIntsByIdData> custom({
    Expression<int>? sheetId,
    Expression<int>? id,
    Expression<int>? intIndex,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (id != null) 'id': id,
      if (intIndex != null) 'int_index': intIndex,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PossibleIntsByIdCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? id,
    Value<int>? intIndex,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return PossibleIntsByIdCompanion(
      sheetId: sheetId ?? this.sheetId,
      id: id ?? this.id,
      intIndex: intIndex ?? this.intIndex,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (intIndex.present) {
      map['int_index'] = Variable<int>(intIndex.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PossibleIntsByIdCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('intIndex: $intIndex, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ValidAreasByIdTable extends ValidAreasById
    with TableInfo<$ValidAreasByIdTable, ValidAreasByIdData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ValidAreasByIdTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intIndexMeta = const VerificationMeta(
    'intIndex',
  );
  @override
  late final GeneratedColumn<int> intIndex = GeneratedColumn<int>(
    'int_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaIndexMeta = const VerificationMeta(
    'areaIndex',
  );
  @override
  late final GeneratedColumn<int> areaIndex = GeneratedColumn<int>(
    'area_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaEdgeMeta = const VerificationMeta(
    'areaEdge',
  );
  @override
  late final GeneratedColumn<int> areaEdge = GeneratedColumn<int>(
    'area_edge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sheetId,
    id,
    intIndex,
    areaIndex,
    areaEdge,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'valid_areas_by_id';
  @override
  VerificationContext validateIntegrity(
    Insertable<ValidAreasByIdData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('int_index')) {
      context.handle(
        _intIndexMeta,
        intIndex.isAcceptableOrUnknown(data['int_index']!, _intIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_intIndexMeta);
    }
    if (data.containsKey('area_index')) {
      context.handle(
        _areaIndexMeta,
        areaIndex.isAcceptableOrUnknown(data['area_index']!, _areaIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_areaIndexMeta);
    }
    if (data.containsKey('area_edge')) {
      context.handle(
        _areaEdgeMeta,
        areaEdge.isAcceptableOrUnknown(data['area_edge']!, _areaEdgeMeta),
      );
    } else if (isInserting) {
      context.missing(_areaEdgeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, id, intIndex, areaIndex};
  @override
  ValidAreasByIdData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ValidAreasByIdData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      intIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_index'],
      )!,
      areaIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}area_index'],
      )!,
      areaEdge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}area_edge'],
      )!,
    );
  }

  @override
  $ValidAreasByIdTable createAlias(String alias) {
    return $ValidAreasByIdTable(attachedDatabase, alias);
  }
}

class ValidAreasByIdData extends DataClass
    implements Insertable<ValidAreasByIdData> {
  final int sheetId;
  final int id;
  final int intIndex;
  final int areaIndex;
  final int areaEdge;
  const ValidAreasByIdData({
    required this.sheetId,
    required this.id,
    required this.intIndex,
    required this.areaIndex,
    required this.areaEdge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['id'] = Variable<int>(id);
    map['int_index'] = Variable<int>(intIndex);
    map['area_index'] = Variable<int>(areaIndex);
    map['area_edge'] = Variable<int>(areaEdge);
    return map;
  }

  ValidAreasByIdCompanion toCompanion(bool nullToAbsent) {
    return ValidAreasByIdCompanion(
      sheetId: Value(sheetId),
      id: Value(id),
      intIndex: Value(intIndex),
      areaIndex: Value(areaIndex),
      areaEdge: Value(areaEdge),
    );
  }

  factory ValidAreasByIdData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ValidAreasByIdData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      id: serializer.fromJson<int>(json['id']),
      intIndex: serializer.fromJson<int>(json['intIndex']),
      areaIndex: serializer.fromJson<int>(json['areaIndex']),
      areaEdge: serializer.fromJson<int>(json['areaEdge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'id': serializer.toJson<int>(id),
      'intIndex': serializer.toJson<int>(intIndex),
      'areaIndex': serializer.toJson<int>(areaIndex),
      'areaEdge': serializer.toJson<int>(areaEdge),
    };
  }

  ValidAreasByIdData copyWith({
    int? sheetId,
    int? id,
    int? intIndex,
    int? areaIndex,
    int? areaEdge,
  }) => ValidAreasByIdData(
    sheetId: sheetId ?? this.sheetId,
    id: id ?? this.id,
    intIndex: intIndex ?? this.intIndex,
    areaIndex: areaIndex ?? this.areaIndex,
    areaEdge: areaEdge ?? this.areaEdge,
  );
  ValidAreasByIdData copyWithCompanion(ValidAreasByIdCompanion data) {
    return ValidAreasByIdData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      id: data.id.present ? data.id.value : this.id,
      intIndex: data.intIndex.present ? data.intIndex.value : this.intIndex,
      areaIndex: data.areaIndex.present ? data.areaIndex.value : this.areaIndex,
      areaEdge: data.areaEdge.present ? data.areaEdge.value : this.areaEdge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ValidAreasByIdData(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('intIndex: $intIndex, ')
          ..write('areaIndex: $areaIndex, ')
          ..write('areaEdge: $areaEdge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, id, intIndex, areaIndex, areaEdge);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValidAreasByIdData &&
          other.sheetId == this.sheetId &&
          other.id == this.id &&
          other.intIndex == this.intIndex &&
          other.areaIndex == this.areaIndex &&
          other.areaEdge == this.areaEdge);
}

class ValidAreasByIdCompanion extends UpdateCompanion<ValidAreasByIdData> {
  final Value<int> sheetId;
  final Value<int> id;
  final Value<int> intIndex;
  final Value<int> areaIndex;
  final Value<int> areaEdge;
  final Value<int> rowid;
  const ValidAreasByIdCompanion({
    this.sheetId = const Value.absent(),
    this.id = const Value.absent(),
    this.intIndex = const Value.absent(),
    this.areaIndex = const Value.absent(),
    this.areaEdge = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ValidAreasByIdCompanion.insert({
    required int sheetId,
    required int id,
    required int intIndex,
    required int areaIndex,
    required int areaEdge,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       id = Value(id),
       intIndex = Value(intIndex),
       areaIndex = Value(areaIndex),
       areaEdge = Value(areaEdge);
  static Insertable<ValidAreasByIdData> custom({
    Expression<int>? sheetId,
    Expression<int>? id,
    Expression<int>? intIndex,
    Expression<int>? areaIndex,
    Expression<int>? areaEdge,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (id != null) 'id': id,
      if (intIndex != null) 'int_index': intIndex,
      if (areaIndex != null) 'area_index': areaIndex,
      if (areaEdge != null) 'area_edge': areaEdge,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ValidAreasByIdCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? id,
    Value<int>? intIndex,
    Value<int>? areaIndex,
    Value<int>? areaEdge,
    Value<int>? rowid,
  }) {
    return ValidAreasByIdCompanion(
      sheetId: sheetId ?? this.sheetId,
      id: id ?? this.id,
      intIndex: intIndex ?? this.intIndex,
      areaIndex: areaIndex ?? this.areaIndex,
      areaEdge: areaEdge ?? this.areaEdge,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (intIndex.present) {
      map['int_index'] = Variable<int>(intIndex.value);
    }
    if (areaIndex.present) {
      map['area_index'] = Variable<int>(areaIndex.value);
    }
    if (areaEdge.present) {
      map['area_edge'] = Variable<int>(areaEdge.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ValidAreasByIdCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('intIndex: $intIndex, ')
          ..write('areaIndex: $areaIndex, ')
          ..write('areaEdge: $areaEdge, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BestDistFoundTable extends BestDistFound
    with TableInfo<$BestDistFoundTable, BestDistFoundData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BestDistFoundTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet_data_tables (id)',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sheetId, id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'best_dist_found';
  @override
  VerificationContext validateIntegrity(
    Insertable<BestDistFoundData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sheetId, id};
  @override
  BestDistFoundData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BestDistFoundData(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $BestDistFoundTable createAlias(String alias) {
    return $BestDistFoundTable(attachedDatabase, alias);
  }
}

class BestDistFoundData extends DataClass
    implements Insertable<BestDistFoundData> {
  final int sheetId;
  final int id;
  final int value;
  const BestDistFoundData({
    required this.sheetId,
    required this.id,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sheet_id'] = Variable<int>(sheetId);
    map['id'] = Variable<int>(id);
    map['value'] = Variable<int>(value);
    return map;
  }

  BestDistFoundCompanion toCompanion(bool nullToAbsent) {
    return BestDistFoundCompanion(
      sheetId: Value(sheetId),
      id: Value(id),
      value: Value(value),
    );
  }

  factory BestDistFoundData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BestDistFoundData(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sheetId': serializer.toJson<int>(sheetId),
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<int>(value),
    };
  }

  BestDistFoundData copyWith({int? sheetId, int? id, int? value}) =>
      BestDistFoundData(
        sheetId: sheetId ?? this.sheetId,
        id: id ?? this.id,
        value: value ?? this.value,
      );
  BestDistFoundData copyWithCompanion(BestDistFoundCompanion data) {
    return BestDistFoundData(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BestDistFoundData(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sheetId, id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BestDistFoundData &&
          other.sheetId == this.sheetId &&
          other.id == this.id &&
          other.value == this.value);
}

class BestDistFoundCompanion extends UpdateCompanion<BestDistFoundData> {
  final Value<int> sheetId;
  final Value<int> id;
  final Value<int> value;
  final Value<int> rowid;
  const BestDistFoundCompanion({
    this.sheetId = const Value.absent(),
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BestDistFoundCompanion.insert({
    required int sheetId,
    required int id,
    required int value,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       id = Value(id),
       value = Value(value);
  static Insertable<BestDistFoundData> custom({
    Expression<int>? sheetId,
    Expression<int>? id,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sheetId != null) 'sheet_id': sheetId,
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BestDistFoundCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? id,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return BestDistFoundCompanion(
      sheetId: sheetId ?? this.sheetId,
      id: id ?? this.id,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BestDistFoundCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SheetDataTablesTable sheetDataTables = $SheetDataTablesTable(
    this,
  );
  late final $SheetCellsTable sheetCells = $SheetCellsTable(this);
  late final $SheetColumnTypesTable sheetColumnTypes = $SheetColumnTypesTable(
    this,
  );
  late final $UpdateHistoriesTable updateHistories = $UpdateHistoriesTable(
    this,
  );
  late final $RowsBottomPosTable rowsBottomPos = $RowsBottomPosTable(this);
  late final $ColRightPosTable colRightPos = $ColRightPosTable(this);
  late final $RowsManuallyAdjustedHeightTable rowsManuallyAdjustedHeight =
      $RowsManuallyAdjustedHeightTable(this);
  late final $ColsManuallyAdjustedWidthTable colsManuallyAdjustedWidth =
      $ColsManuallyAdjustedWidthTable(this);
  late final $SelectedCellsTable selectedCells = $SelectedCellsTable(this);
  late final $BestSortFoundTable bestSortFound = $BestSortFoundTable(this);
  late final $CursorsTable cursors = $CursorsTable(this);
  late final $PossibleIntsByIdTable possibleIntsById = $PossibleIntsByIdTable(
    this,
  );
  late final $ValidAreasByIdTable validAreasById = $ValidAreasByIdTable(this);
  late final $BestDistFoundTable bestDistFound = $BestDistFoundTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sheetDataTables,
    sheetCells,
    sheetColumnTypes,
    updateHistories,
    rowsBottomPos,
    colRightPos,
    rowsManuallyAdjustedHeight,
    colsManuallyAdjustedWidth,
    selectedCells,
    bestSortFound,
    cursors,
    possibleIntsById,
    validAreasById,
    bestDistFound,
  ];
}

typedef $$SheetDataTablesTableCreateCompanionBuilder =
    SheetDataTablesCompanion Function({
      Value<int> id,
      required String name,
      required int historyIndex,
      required double colHeaderHeight,
      required double rowHeaderWidth,
      required int primarySelectedCellX,
      required int primarySelectedCellY,
      required double scrollOffsetX,
      required double scrollOffsetY,
      required int sortIndex,
      required AnalysisResult analysisResult,
      required bool sortInProgress,
      required bool toApplyNextBestSort,
      required bool toAlwaysApplyCurrentBestSort,
      required bool analysisDone,
    });
typedef $$SheetDataTablesTableUpdateCompanionBuilder =
    SheetDataTablesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> historyIndex,
      Value<double> colHeaderHeight,
      Value<double> rowHeaderWidth,
      Value<int> primarySelectedCellX,
      Value<int> primarySelectedCellY,
      Value<double> scrollOffsetX,
      Value<double> scrollOffsetY,
      Value<int> sortIndex,
      Value<AnalysisResult> analysisResult,
      Value<bool> sortInProgress,
      Value<bool> toApplyNextBestSort,
      Value<bool> toAlwaysApplyCurrentBestSort,
      Value<bool> analysisDone,
    });

final class $$SheetDataTablesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SheetDataTablesTable, SheetDataTable> {
  $$SheetDataTablesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SheetCellsTable, List<SheetCell>>
  _sheetCellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sheetCells,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.sheetCells.sheetId,
    ),
  );

  $$SheetCellsTableProcessedTableManager get sheetCellsRefs {
    final manager = $$SheetCellsTableTableManager(
      $_db,
      $_db.sheetCells,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sheetCellsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SheetColumnTypesTable, List<SheetColumnType>>
  _sheetColumnTypesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sheetColumnTypes,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.sheetColumnTypes.sheetId,
    ),
  );

  $$SheetColumnTypesTableProcessedTableManager get sheetColumnTypesRefs {
    final manager = $$SheetColumnTypesTableTableManager(
      $_db,
      $_db.sheetColumnTypes,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sheetColumnTypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UpdateHistoriesTable, List<UpdateHistory>>
  _updateHistoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.updateHistories,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.updateHistories.sheetId,
    ),
  );

  $$UpdateHistoriesTableProcessedTableManager get updateHistoriesRefs {
    final manager = $$UpdateHistoriesTableTableManager(
      $_db,
      $_db.updateHistories,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _updateHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RowsBottomPosTable, List<RowsBottomPo>>
  _rowsBottomPosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rowsBottomPos,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.rowsBottomPos.sheetId,
    ),
  );

  $$RowsBottomPosTableProcessedTableManager get rowsBottomPosRefs {
    final manager = $$RowsBottomPosTableTableManager(
      $_db,
      $_db.rowsBottomPos,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rowsBottomPosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ColRightPosTable, List<ColRightPo>>
  _colRightPosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.colRightPos,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.colRightPos.sheetId,
    ),
  );

  $$ColRightPosTableProcessedTableManager get colRightPosRefs {
    final manager = $$ColRightPosTableTableManager(
      $_db,
      $_db.colRightPos,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_colRightPosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RowsManuallyAdjustedHeightTable,
    List<RowsManuallyAdjustedHeightData>
  >
  _rowsManuallyAdjustedHeightRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rowsManuallyAdjustedHeight,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.rowsManuallyAdjustedHeight.sheetId,
        ),
      );

  $$RowsManuallyAdjustedHeightTableProcessedTableManager
  get rowsManuallyAdjustedHeightRefs {
    final manager = $$RowsManuallyAdjustedHeightTableTableManager(
      $_db,
      $_db.rowsManuallyAdjustedHeight,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rowsManuallyAdjustedHeightRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ColsManuallyAdjustedWidthTable,
    List<ColsManuallyAdjustedWidthData>
  >
  _colsManuallyAdjustedWidthRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.colsManuallyAdjustedWidth,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.colsManuallyAdjustedWidth.sheetId,
        ),
      );

  $$ColsManuallyAdjustedWidthTableProcessedTableManager
  get colsManuallyAdjustedWidthRefs {
    final manager = $$ColsManuallyAdjustedWidthTableTableManager(
      $_db,
      $_db.colsManuallyAdjustedWidth,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _colsManuallyAdjustedWidthRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SelectedCellsTable, List<SelectedCell>>
  _selectedCellsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.selectedCells,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.selectedCells.sheetId,
    ),
  );

  $$SelectedCellsTableProcessedTableManager get selectedCellsRefs {
    final manager = $$SelectedCellsTableTableManager(
      $_db,
      $_db.selectedCells,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_selectedCellsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BestSortFoundTable, List<BestSortFoundData>>
  _bestSortFoundRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bestSortFound,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.bestSortFound.sheetId,
    ),
  );

  $$BestSortFoundTableProcessedTableManager get bestSortFoundRefs {
    final manager = $$BestSortFoundTableTableManager(
      $_db,
      $_db.bestSortFound,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bestSortFoundRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CursorsTable, List<Cursor>> _cursorsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cursors,
    aliasName: $_aliasNameGenerator(db.sheetDataTables.id, db.cursors.sheetId),
  );

  $$CursorsTableProcessedTableManager get cursorsRefs {
    final manager = $$CursorsTableTableManager(
      $_db,
      $_db.cursors,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cursorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PossibleIntsByIdTable, List<PossibleIntsByIdData>>
  _possibleIntsByIdRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.possibleIntsById,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.possibleIntsById.sheetId,
    ),
  );

  $$PossibleIntsByIdTableProcessedTableManager get possibleIntsByIdRefs {
    final manager = $$PossibleIntsByIdTableTableManager(
      $_db,
      $_db.possibleIntsById,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _possibleIntsByIdRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ValidAreasByIdTable, List<ValidAreasByIdData>>
  _validAreasByIdRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.validAreasById,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.validAreasById.sheetId,
    ),
  );

  $$ValidAreasByIdTableProcessedTableManager get validAreasByIdRefs {
    final manager = $$ValidAreasByIdTableTableManager(
      $_db,
      $_db.validAreasById,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_validAreasByIdRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BestDistFoundTable, List<BestDistFoundData>>
  _bestDistFoundRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bestDistFound,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.bestDistFound.sheetId,
    ),
  );

  $$BestDistFoundTableProcessedTableManager get bestDistFoundRefs {
    final manager = $$BestDistFoundTableTableManager(
      $_db,
      $_db.bestDistFound,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bestDistFoundRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SheetDataTablesTableFilterComposer
    extends Composer<_$AppDatabase, $SheetDataTablesTable> {
  $$SheetDataTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get historyIndex => $composableBuilder(
    column: $table.historyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get colHeaderHeight => $composableBuilder(
    column: $table.colHeaderHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rowHeaderWidth => $composableBuilder(
    column: $table.rowHeaderWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primarySelectedCellX => $composableBuilder(
    column: $table.primarySelectedCellX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get primarySelectedCellY => $composableBuilder(
    column: $table.primarySelectedCellY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollOffsetX => $composableBuilder(
    column: $table.scrollOffsetX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scrollOffsetY => $composableBuilder(
    column: $table.scrollOffsetY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AnalysisResult, AnalysisResult, String>
  get analysisResult => $composableBuilder(
    column: $table.analysisResult,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get sortInProgress => $composableBuilder(
    column: $table.sortInProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get toApplyNextBestSort => $composableBuilder(
    column: $table.toApplyNextBestSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get toAlwaysApplyCurrentBestSort => $composableBuilder(
    column: $table.toAlwaysApplyCurrentBestSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get analysisDone => $composableBuilder(
    column: $table.analysisDone,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sheetCellsRefs(
    Expression<bool> Function($$SheetCellsTableFilterComposer f) f,
  ) {
    final $$SheetCellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetCells,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetCellsTableFilterComposer(
            $db: $db,
            $table: $db.sheetCells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sheetColumnTypesRefs(
    Expression<bool> Function($$SheetColumnTypesTableFilterComposer f) f,
  ) {
    final $$SheetColumnTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetColumnTypes,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetColumnTypesTableFilterComposer(
            $db: $db,
            $table: $db.sheetColumnTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> updateHistoriesRefs(
    Expression<bool> Function($$UpdateHistoriesTableFilterComposer f) f,
  ) {
    final $$UpdateHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.updateHistories,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpdateHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.updateHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rowsBottomPosRefs(
    Expression<bool> Function($$RowsBottomPosTableFilterComposer f) f,
  ) {
    final $$RowsBottomPosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rowsBottomPos,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RowsBottomPosTableFilterComposer(
            $db: $db,
            $table: $db.rowsBottomPos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> colRightPosRefs(
    Expression<bool> Function($$ColRightPosTableFilterComposer f) f,
  ) {
    final $$ColRightPosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.colRightPos,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColRightPosTableFilterComposer(
            $db: $db,
            $table: $db.colRightPos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rowsManuallyAdjustedHeightRefs(
    Expression<bool> Function($$RowsManuallyAdjustedHeightTableFilterComposer f)
    f,
  ) {
    final $$RowsManuallyAdjustedHeightTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rowsManuallyAdjustedHeight,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RowsManuallyAdjustedHeightTableFilterComposer(
                $db: $db,
                $table: $db.rowsManuallyAdjustedHeight,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> colsManuallyAdjustedWidthRefs(
    Expression<bool> Function($$ColsManuallyAdjustedWidthTableFilterComposer f)
    f,
  ) {
    final $$ColsManuallyAdjustedWidthTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.colsManuallyAdjustedWidth,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ColsManuallyAdjustedWidthTableFilterComposer(
                $db: $db,
                $table: $db.colsManuallyAdjustedWidth,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> selectedCellsRefs(
    Expression<bool> Function($$SelectedCellsTableFilterComposer f) f,
  ) {
    final $$SelectedCellsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selectedCells,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedCellsTableFilterComposer(
            $db: $db,
            $table: $db.selectedCells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bestSortFoundRefs(
    Expression<bool> Function($$BestSortFoundTableFilterComposer f) f,
  ) {
    final $$BestSortFoundTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestSortFound,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestSortFoundTableFilterComposer(
            $db: $db,
            $table: $db.bestSortFound,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cursorsRefs(
    Expression<bool> Function($$CursorsTableFilterComposer f) f,
  ) {
    final $$CursorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cursors,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursorsTableFilterComposer(
            $db: $db,
            $table: $db.cursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> possibleIntsByIdRefs(
    Expression<bool> Function($$PossibleIntsByIdTableFilterComposer f) f,
  ) {
    final $$PossibleIntsByIdTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.possibleIntsById,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PossibleIntsByIdTableFilterComposer(
            $db: $db,
            $table: $db.possibleIntsById,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> validAreasByIdRefs(
    Expression<bool> Function($$ValidAreasByIdTableFilterComposer f) f,
  ) {
    final $$ValidAreasByIdTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.validAreasById,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ValidAreasByIdTableFilterComposer(
            $db: $db,
            $table: $db.validAreasById,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bestDistFoundRefs(
    Expression<bool> Function($$BestDistFoundTableFilterComposer f) f,
  ) {
    final $$BestDistFoundTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestDistFound,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestDistFoundTableFilterComposer(
            $db: $db,
            $table: $db.bestDistFound,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetDataTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetDataTablesTable> {
  $$SheetDataTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get historyIndex => $composableBuilder(
    column: $table.historyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get colHeaderHeight => $composableBuilder(
    column: $table.colHeaderHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rowHeaderWidth => $composableBuilder(
    column: $table.rowHeaderWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primarySelectedCellX => $composableBuilder(
    column: $table.primarySelectedCellX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primarySelectedCellY => $composableBuilder(
    column: $table.primarySelectedCellY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollOffsetX => $composableBuilder(
    column: $table.scrollOffsetX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scrollOffsetY => $composableBuilder(
    column: $table.scrollOffsetY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisResult => $composableBuilder(
    column: $table.analysisResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sortInProgress => $composableBuilder(
    column: $table.sortInProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get toApplyNextBestSort => $composableBuilder(
    column: $table.toApplyNextBestSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get toAlwaysApplyCurrentBestSort => $composableBuilder(
    column: $table.toAlwaysApplyCurrentBestSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get analysisDone => $composableBuilder(
    column: $table.analysisDone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SheetDataTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetDataTablesTable> {
  $$SheetDataTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get historyIndex => $composableBuilder(
    column: $table.historyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<double> get colHeaderHeight => $composableBuilder(
    column: $table.colHeaderHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rowHeaderWidth => $composableBuilder(
    column: $table.rowHeaderWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primarySelectedCellX => $composableBuilder(
    column: $table.primarySelectedCellX,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primarySelectedCellY => $composableBuilder(
    column: $table.primarySelectedCellY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrollOffsetX => $composableBuilder(
    column: $table.scrollOffsetX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scrollOffsetY => $composableBuilder(
    column: $table.scrollOffsetY,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AnalysisResult, String> get analysisResult =>
      $composableBuilder(
        column: $table.analysisResult,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get sortInProgress => $composableBuilder(
    column: $table.sortInProgress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get toApplyNextBestSort => $composableBuilder(
    column: $table.toApplyNextBestSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get toAlwaysApplyCurrentBestSort => $composableBuilder(
    column: $table.toAlwaysApplyCurrentBestSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get analysisDone => $composableBuilder(
    column: $table.analysisDone,
    builder: (column) => column,
  );

  Expression<T> sheetCellsRefs<T extends Object>(
    Expression<T> Function($$SheetCellsTableAnnotationComposer a) f,
  ) {
    final $$SheetCellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetCells,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetCellsTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetCells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sheetColumnTypesRefs<T extends Object>(
    Expression<T> Function($$SheetColumnTypesTableAnnotationComposer a) f,
  ) {
    final $$SheetColumnTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetColumnTypes,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetColumnTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetColumnTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> updateHistoriesRefs<T extends Object>(
    Expression<T> Function($$UpdateHistoriesTableAnnotationComposer a) f,
  ) {
    final $$UpdateHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.updateHistories,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpdateHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.updateHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rowsBottomPosRefs<T extends Object>(
    Expression<T> Function($$RowsBottomPosTableAnnotationComposer a) f,
  ) {
    final $$RowsBottomPosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rowsBottomPos,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RowsBottomPosTableAnnotationComposer(
            $db: $db,
            $table: $db.rowsBottomPos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> colRightPosRefs<T extends Object>(
    Expression<T> Function($$ColRightPosTableAnnotationComposer a) f,
  ) {
    final $$ColRightPosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.colRightPos,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColRightPosTableAnnotationComposer(
            $db: $db,
            $table: $db.colRightPos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rowsManuallyAdjustedHeightRefs<T extends Object>(
    Expression<T> Function(
      $$RowsManuallyAdjustedHeightTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RowsManuallyAdjustedHeightTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rowsManuallyAdjustedHeight,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RowsManuallyAdjustedHeightTableAnnotationComposer(
                $db: $db,
                $table: $db.rowsManuallyAdjustedHeight,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> colsManuallyAdjustedWidthRefs<T extends Object>(
    Expression<T> Function($$ColsManuallyAdjustedWidthTableAnnotationComposer a)
    f,
  ) {
    final $$ColsManuallyAdjustedWidthTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.colsManuallyAdjustedWidth,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ColsManuallyAdjustedWidthTableAnnotationComposer(
                $db: $db,
                $table: $db.colsManuallyAdjustedWidth,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> selectedCellsRefs<T extends Object>(
    Expression<T> Function($$SelectedCellsTableAnnotationComposer a) f,
  ) {
    final $$SelectedCellsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.selectedCells,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SelectedCellsTableAnnotationComposer(
            $db: $db,
            $table: $db.selectedCells,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bestSortFoundRefs<T extends Object>(
    Expression<T> Function($$BestSortFoundTableAnnotationComposer a) f,
  ) {
    final $$BestSortFoundTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestSortFound,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestSortFoundTableAnnotationComposer(
            $db: $db,
            $table: $db.bestSortFound,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cursorsRefs<T extends Object>(
    Expression<T> Function($$CursorsTableAnnotationComposer a) f,
  ) {
    final $$CursorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cursors,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursorsTableAnnotationComposer(
            $db: $db,
            $table: $db.cursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> possibleIntsByIdRefs<T extends Object>(
    Expression<T> Function($$PossibleIntsByIdTableAnnotationComposer a) f,
  ) {
    final $$PossibleIntsByIdTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.possibleIntsById,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PossibleIntsByIdTableAnnotationComposer(
            $db: $db,
            $table: $db.possibleIntsById,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> validAreasByIdRefs<T extends Object>(
    Expression<T> Function($$ValidAreasByIdTableAnnotationComposer a) f,
  ) {
    final $$ValidAreasByIdTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.validAreasById,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ValidAreasByIdTableAnnotationComposer(
            $db: $db,
            $table: $db.validAreasById,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bestDistFoundRefs<T extends Object>(
    Expression<T> Function($$BestDistFoundTableAnnotationComposer a) f,
  ) {
    final $$BestDistFoundTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestDistFound,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestDistFoundTableAnnotationComposer(
            $db: $db,
            $table: $db.bestDistFound,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetDataTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetDataTablesTable,
          SheetDataTable,
          $$SheetDataTablesTableFilterComposer,
          $$SheetDataTablesTableOrderingComposer,
          $$SheetDataTablesTableAnnotationComposer,
          $$SheetDataTablesTableCreateCompanionBuilder,
          $$SheetDataTablesTableUpdateCompanionBuilder,
          (SheetDataTable, $$SheetDataTablesTableReferences),
          SheetDataTable,
          PrefetchHooks Function({
            bool sheetCellsRefs,
            bool sheetColumnTypesRefs,
            bool updateHistoriesRefs,
            bool rowsBottomPosRefs,
            bool colRightPosRefs,
            bool rowsManuallyAdjustedHeightRefs,
            bool colsManuallyAdjustedWidthRefs,
            bool selectedCellsRefs,
            bool bestSortFoundRefs,
            bool cursorsRefs,
            bool possibleIntsByIdRefs,
            bool validAreasByIdRefs,
            bool bestDistFoundRefs,
          })
        > {
  $$SheetDataTablesTableTableManager(
    _$AppDatabase db,
    $SheetDataTablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetDataTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetDataTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetDataTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> historyIndex = const Value.absent(),
                Value<double> colHeaderHeight = const Value.absent(),
                Value<double> rowHeaderWidth = const Value.absent(),
                Value<int> primarySelectedCellX = const Value.absent(),
                Value<int> primarySelectedCellY = const Value.absent(),
                Value<double> scrollOffsetX = const Value.absent(),
                Value<double> scrollOffsetY = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<AnalysisResult> analysisResult = const Value.absent(),
                Value<bool> sortInProgress = const Value.absent(),
                Value<bool> toApplyNextBestSort = const Value.absent(),
                Value<bool> toAlwaysApplyCurrentBestSort = const Value.absent(),
                Value<bool> analysisDone = const Value.absent(),
              }) => SheetDataTablesCompanion(
                id: id,
                name: name,
                historyIndex: historyIndex,
                colHeaderHeight: colHeaderHeight,
                rowHeaderWidth: rowHeaderWidth,
                primarySelectedCellX: primarySelectedCellX,
                primarySelectedCellY: primarySelectedCellY,
                scrollOffsetX: scrollOffsetX,
                scrollOffsetY: scrollOffsetY,
                sortIndex: sortIndex,
                analysisResult: analysisResult,
                sortInProgress: sortInProgress,
                toApplyNextBestSort: toApplyNextBestSort,
                toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort,
                analysisDone: analysisDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int historyIndex,
                required double colHeaderHeight,
                required double rowHeaderWidth,
                required int primarySelectedCellX,
                required int primarySelectedCellY,
                required double scrollOffsetX,
                required double scrollOffsetY,
                required int sortIndex,
                required AnalysisResult analysisResult,
                required bool sortInProgress,
                required bool toApplyNextBestSort,
                required bool toAlwaysApplyCurrentBestSort,
                required bool analysisDone,
              }) => SheetDataTablesCompanion.insert(
                id: id,
                name: name,
                historyIndex: historyIndex,
                colHeaderHeight: colHeaderHeight,
                rowHeaderWidth: rowHeaderWidth,
                primarySelectedCellX: primarySelectedCellX,
                primarySelectedCellY: primarySelectedCellY,
                scrollOffsetX: scrollOffsetX,
                scrollOffsetY: scrollOffsetY,
                sortIndex: sortIndex,
                analysisResult: analysisResult,
                sortInProgress: sortInProgress,
                toApplyNextBestSort: toApplyNextBestSort,
                toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort,
                analysisDone: analysisDone,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SheetDataTablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sheetCellsRefs = false,
                sheetColumnTypesRefs = false,
                updateHistoriesRefs = false,
                rowsBottomPosRefs = false,
                colRightPosRefs = false,
                rowsManuallyAdjustedHeightRefs = false,
                colsManuallyAdjustedWidthRefs = false,
                selectedCellsRefs = false,
                bestSortFoundRefs = false,
                cursorsRefs = false,
                possibleIntsByIdRefs = false,
                validAreasByIdRefs = false,
                bestDistFoundRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sheetCellsRefs) db.sheetCells,
                    if (sheetColumnTypesRefs) db.sheetColumnTypes,
                    if (updateHistoriesRefs) db.updateHistories,
                    if (rowsBottomPosRefs) db.rowsBottomPos,
                    if (colRightPosRefs) db.colRightPos,
                    if (rowsManuallyAdjustedHeightRefs)
                      db.rowsManuallyAdjustedHeight,
                    if (colsManuallyAdjustedWidthRefs)
                      db.colsManuallyAdjustedWidth,
                    if (selectedCellsRefs) db.selectedCells,
                    if (bestSortFoundRefs) db.bestSortFound,
                    if (cursorsRefs) db.cursors,
                    if (possibleIntsByIdRefs) db.possibleIntsById,
                    if (validAreasByIdRefs) db.validAreasById,
                    if (bestDistFoundRefs) db.bestDistFound,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sheetCellsRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          SheetCell
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._sheetCellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).sheetCellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sheetColumnTypesRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          SheetColumnType
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._sheetColumnTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).sheetColumnTypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (updateHistoriesRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          UpdateHistory
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._updateHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).updateHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rowsBottomPosRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          RowsBottomPo
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._rowsBottomPosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).rowsBottomPosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (colRightPosRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          ColRightPo
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._colRightPosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).colRightPosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rowsManuallyAdjustedHeightRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          RowsManuallyAdjustedHeightData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._rowsManuallyAdjustedHeightRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).rowsManuallyAdjustedHeightRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (colsManuallyAdjustedWidthRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          ColsManuallyAdjustedWidthData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._colsManuallyAdjustedWidthRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).colsManuallyAdjustedWidthRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (selectedCellsRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          SelectedCell
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._selectedCellsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).selectedCellsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bestSortFoundRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          BestSortFoundData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._bestSortFoundRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).bestSortFoundRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cursorsRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          Cursor
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._cursorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).cursorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (possibleIntsByIdRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          PossibleIntsByIdData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._possibleIntsByIdRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).possibleIntsByIdRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (validAreasByIdRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          ValidAreasByIdData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._validAreasByIdRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).validAreasByIdRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bestDistFoundRefs)
                        await $_getPrefetchedData<
                          SheetDataTable,
                          $SheetDataTablesTable,
                          BestDistFoundData
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._bestDistFoundRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).bestDistFoundRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SheetDataTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetDataTablesTable,
      SheetDataTable,
      $$SheetDataTablesTableFilterComposer,
      $$SheetDataTablesTableOrderingComposer,
      $$SheetDataTablesTableAnnotationComposer,
      $$SheetDataTablesTableCreateCompanionBuilder,
      $$SheetDataTablesTableUpdateCompanionBuilder,
      (SheetDataTable, $$SheetDataTablesTableReferences),
      SheetDataTable,
      PrefetchHooks Function({
        bool sheetCellsRefs,
        bool sheetColumnTypesRefs,
        bool updateHistoriesRefs,
        bool rowsBottomPosRefs,
        bool colRightPosRefs,
        bool rowsManuallyAdjustedHeightRefs,
        bool colsManuallyAdjustedWidthRefs,
        bool selectedCellsRefs,
        bool bestSortFoundRefs,
        bool cursorsRefs,
        bool possibleIntsByIdRefs,
        bool validAreasByIdRefs,
        bool bestDistFoundRefs,
      })
    >;
typedef $$SheetCellsTableCreateCompanionBuilder =
    SheetCellsCompanion Function({
      required int sheetId,
      required int row,
      required int col,
      required String content,
      Value<int> rowid,
    });
typedef $$SheetCellsTableUpdateCompanionBuilder =
    SheetCellsCompanion Function({
      Value<int> sheetId,
      Value<int> row,
      Value<int> col,
      Value<String> content,
      Value<int> rowid,
    });

final class $$SheetCellsTableReferences
    extends BaseReferences<_$AppDatabase, $SheetCellsTable, SheetCell> {
  $$SheetCellsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.sheetCells.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SheetCellsTableFilterComposer
    extends Composer<_$AppDatabase, $SheetCellsTable> {
  $$SheetCellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get col => $composableBuilder(
    column: $table.col,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetCellsTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetCellsTable> {
  $$SheetCellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get col => $composableBuilder(
    column: $table.col,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetCellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetCellsTable> {
  $$SheetCellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get row =>
      $composableBuilder(column: $table.row, builder: (column) => column);

  GeneratedColumn<int> get col =>
      $composableBuilder(column: $table.col, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetCellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetCellsTable,
          SheetCell,
          $$SheetCellsTableFilterComposer,
          $$SheetCellsTableOrderingComposer,
          $$SheetCellsTableAnnotationComposer,
          $$SheetCellsTableCreateCompanionBuilder,
          $$SheetCellsTableUpdateCompanionBuilder,
          (SheetCell, $$SheetCellsTableReferences),
          SheetCell,
          PrefetchHooks Function({bool sheetId})
        > {
  $$SheetCellsTableTableManager(_$AppDatabase db, $SheetCellsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetCellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetCellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetCellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> row = const Value.absent(),
                Value<int> col = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SheetCellsCompanion(
                sheetId: sheetId,
                row: row,
                col: col,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int row,
                required int col,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => SheetCellsCompanion.insert(
                sheetId: sheetId,
                row: row,
                col: col,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SheetCellsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$SheetCellsTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$SheetCellsTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SheetCellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetCellsTable,
      SheetCell,
      $$SheetCellsTableFilterComposer,
      $$SheetCellsTableOrderingComposer,
      $$SheetCellsTableAnnotationComposer,
      $$SheetCellsTableCreateCompanionBuilder,
      $$SheetCellsTableUpdateCompanionBuilder,
      (SheetCell, $$SheetCellsTableReferences),
      SheetCell,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$SheetColumnTypesTableCreateCompanionBuilder =
    SheetColumnTypesCompanion Function({
      required int sheetId,
      required int columnIndex,
      required ColumnType columnType,
      Value<int> rowid,
    });
typedef $$SheetColumnTypesTableUpdateCompanionBuilder =
    SheetColumnTypesCompanion Function({
      Value<int> sheetId,
      Value<int> columnIndex,
      Value<ColumnType> columnType,
      Value<int> rowid,
    });

final class $$SheetColumnTypesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SheetColumnTypesTable, SheetColumnType> {
  $$SheetColumnTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.sheetColumnTypes.sheetId,
          db.sheetDataTables.id,
        ),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SheetColumnTypesTableFilterComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTable> {
  $$SheetColumnTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get columnIndex => $composableBuilder(
    column: $table.columnIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ColumnType, ColumnType, int> get columnType =>
      $composableBuilder(
        column: $table.columnType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetColumnTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTable> {
  $$SheetColumnTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get columnIndex => $composableBuilder(
    column: $table.columnIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get columnType => $composableBuilder(
    column: $table.columnType,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetColumnTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTable> {
  $$SheetColumnTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get columnIndex => $composableBuilder(
    column: $table.columnIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ColumnType, int> get columnType =>
      $composableBuilder(
        column: $table.columnType,
        builder: (column) => column,
      );

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SheetColumnTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetColumnTypesTable,
          SheetColumnType,
          $$SheetColumnTypesTableFilterComposer,
          $$SheetColumnTypesTableOrderingComposer,
          $$SheetColumnTypesTableAnnotationComposer,
          $$SheetColumnTypesTableCreateCompanionBuilder,
          $$SheetColumnTypesTableUpdateCompanionBuilder,
          (SheetColumnType, $$SheetColumnTypesTableReferences),
          SheetColumnType,
          PrefetchHooks Function({bool sheetId})
        > {
  $$SheetColumnTypesTableTableManager(
    _$AppDatabase db,
    $SheetColumnTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetColumnTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetColumnTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetColumnTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> columnIndex = const Value.absent(),
                Value<ColumnType> columnType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SheetColumnTypesCompanion(
                sheetId: sheetId,
                columnIndex: columnIndex,
                columnType: columnType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int columnIndex,
                required ColumnType columnType,
                Value<int> rowid = const Value.absent(),
              }) => SheetColumnTypesCompanion.insert(
                sheetId: sheetId,
                columnIndex: columnIndex,
                columnType: columnType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SheetColumnTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$SheetColumnTypesTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$SheetColumnTypesTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SheetColumnTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetColumnTypesTable,
      SheetColumnType,
      $$SheetColumnTypesTableFilterComposer,
      $$SheetColumnTypesTableOrderingComposer,
      $$SheetColumnTypesTableAnnotationComposer,
      $$SheetColumnTypesTableCreateCompanionBuilder,
      $$SheetColumnTypesTableUpdateCompanionBuilder,
      (SheetColumnType, $$SheetColumnTypesTableReferences),
      SheetColumnType,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$UpdateHistoriesTableCreateCompanionBuilder =
    UpdateHistoriesCompanion Function({
      required DateTime timestamp,
      required int chronoId,
      required int sheetId,
      required Map<String, UpdateUnit> updates,
      Value<int> rowid,
    });
typedef $$UpdateHistoriesTableUpdateCompanionBuilder =
    UpdateHistoriesCompanion Function({
      Value<DateTime> timestamp,
      Value<int> chronoId,
      Value<int> sheetId,
      Value<Map<String, UpdateUnit>> updates,
      Value<int> rowid,
    });

final class $$UpdateHistoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $UpdateHistoriesTable, UpdateHistory> {
  $$UpdateHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.updateHistories.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UpdateHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chronoId => $composableBuilder(
    column: $table.chronoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, UpdateUnit>,
    Map<String, UpdateUnit>,
    String
  >
  get updates => $composableBuilder(
    column: $table.updates,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpdateHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chronoId => $composableBuilder(
    column: $table.chronoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updates => $composableBuilder(
    column: $table.updates,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpdateHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTable> {
  $$UpdateHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get chronoId =>
      $composableBuilder(column: $table.chronoId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, UpdateUnit>, String>
  get updates =>
      $composableBuilder(column: $table.updates, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpdateHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpdateHistoriesTable,
          UpdateHistory,
          $$UpdateHistoriesTableFilterComposer,
          $$UpdateHistoriesTableOrderingComposer,
          $$UpdateHistoriesTableAnnotationComposer,
          $$UpdateHistoriesTableCreateCompanionBuilder,
          $$UpdateHistoriesTableUpdateCompanionBuilder,
          (UpdateHistory, $$UpdateHistoriesTableReferences),
          UpdateHistory,
          PrefetchHooks Function({bool sheetId})
        > {
  $$UpdateHistoriesTableTableManager(
    _$AppDatabase db,
    $UpdateHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpdateHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpdateHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UpdateHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> chronoId = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<Map<String, UpdateUnit>> updates = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UpdateHistoriesCompanion(
                timestamp: timestamp,
                chronoId: chronoId,
                sheetId: sheetId,
                updates: updates,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime timestamp,
                required int chronoId,
                required int sheetId,
                required Map<String, UpdateUnit> updates,
                Value<int> rowid = const Value.absent(),
              }) => UpdateHistoriesCompanion.insert(
                timestamp: timestamp,
                chronoId: chronoId,
                sheetId: sheetId,
                updates: updates,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UpdateHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$UpdateHistoriesTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$UpdateHistoriesTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UpdateHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpdateHistoriesTable,
      UpdateHistory,
      $$UpdateHistoriesTableFilterComposer,
      $$UpdateHistoriesTableOrderingComposer,
      $$UpdateHistoriesTableAnnotationComposer,
      $$UpdateHistoriesTableCreateCompanionBuilder,
      $$UpdateHistoriesTableUpdateCompanionBuilder,
      (UpdateHistory, $$UpdateHistoriesTableReferences),
      UpdateHistory,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$RowsBottomPosTableCreateCompanionBuilder =
    RowsBottomPosCompanion Function({
      required int sheetId,
      required int rowIndex,
      required double bottomPos,
      Value<int> rowid,
    });
typedef $$RowsBottomPosTableUpdateCompanionBuilder =
    RowsBottomPosCompanion Function({
      Value<int> sheetId,
      Value<int> rowIndex,
      Value<double> bottomPos,
      Value<int> rowid,
    });

final class $$RowsBottomPosTableReferences
    extends BaseReferences<_$AppDatabase, $RowsBottomPosTable, RowsBottomPo> {
  $$RowsBottomPosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.rowsBottomPos.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RowsBottomPosTableFilterComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTable> {
  $$RowsBottomPosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomPos => $composableBuilder(
    column: $table.bottomPos,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsBottomPosTableOrderingComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTable> {
  $$RowsBottomPosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomPos => $composableBuilder(
    column: $table.bottomPos,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsBottomPosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTable> {
  $$RowsBottomPosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<double> get bottomPos =>
      $composableBuilder(column: $table.bottomPos, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsBottomPosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RowsBottomPosTable,
          RowsBottomPo,
          $$RowsBottomPosTableFilterComposer,
          $$RowsBottomPosTableOrderingComposer,
          $$RowsBottomPosTableAnnotationComposer,
          $$RowsBottomPosTableCreateCompanionBuilder,
          $$RowsBottomPosTableUpdateCompanionBuilder,
          (RowsBottomPo, $$RowsBottomPosTableReferences),
          RowsBottomPo,
          PrefetchHooks Function({bool sheetId})
        > {
  $$RowsBottomPosTableTableManager(_$AppDatabase db, $RowsBottomPosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RowsBottomPosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RowsBottomPosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RowsBottomPosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<double> bottomPos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RowsBottomPosCompanion(
                sheetId: sheetId,
                rowIndex: rowIndex,
                bottomPos: bottomPos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int rowIndex,
                required double bottomPos,
                Value<int> rowid = const Value.absent(),
              }) => RowsBottomPosCompanion.insert(
                sheetId: sheetId,
                rowIndex: rowIndex,
                bottomPos: bottomPos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RowsBottomPosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$RowsBottomPosTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$RowsBottomPosTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RowsBottomPosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RowsBottomPosTable,
      RowsBottomPo,
      $$RowsBottomPosTableFilterComposer,
      $$RowsBottomPosTableOrderingComposer,
      $$RowsBottomPosTableAnnotationComposer,
      $$RowsBottomPosTableCreateCompanionBuilder,
      $$RowsBottomPosTableUpdateCompanionBuilder,
      (RowsBottomPo, $$RowsBottomPosTableReferences),
      RowsBottomPo,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$ColRightPosTableCreateCompanionBuilder =
    ColRightPosCompanion Function({
      required int sheetId,
      required int colIndex,
      required double rightPos,
      Value<int> rowid,
    });
typedef $$ColRightPosTableUpdateCompanionBuilder =
    ColRightPosCompanion Function({
      Value<int> sheetId,
      Value<int> colIndex,
      Value<double> rightPos,
      Value<int> rowid,
    });

final class $$ColRightPosTableReferences
    extends BaseReferences<_$AppDatabase, $ColRightPosTable, ColRightPo> {
  $$ColRightPosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.colRightPos.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ColRightPosTableFilterComposer
    extends Composer<_$AppDatabase, $ColRightPosTable> {
  $$ColRightPosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightPos => $composableBuilder(
    column: $table.rightPos,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColRightPosTableOrderingComposer
    extends Composer<_$AppDatabase, $ColRightPosTable> {
  $$ColRightPosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightPos => $composableBuilder(
    column: $table.rightPos,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColRightPosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColRightPosTable> {
  $$ColRightPosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get colIndex =>
      $composableBuilder(column: $table.colIndex, builder: (column) => column);

  GeneratedColumn<double> get rightPos =>
      $composableBuilder(column: $table.rightPos, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColRightPosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColRightPosTable,
          ColRightPo,
          $$ColRightPosTableFilterComposer,
          $$ColRightPosTableOrderingComposer,
          $$ColRightPosTableAnnotationComposer,
          $$ColRightPosTableCreateCompanionBuilder,
          $$ColRightPosTableUpdateCompanionBuilder,
          (ColRightPo, $$ColRightPosTableReferences),
          ColRightPo,
          PrefetchHooks Function({bool sheetId})
        > {
  $$ColRightPosTableTableManager(_$AppDatabase db, $ColRightPosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColRightPosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColRightPosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColRightPosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> colIndex = const Value.absent(),
                Value<double> rightPos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColRightPosCompanion(
                sheetId: sheetId,
                colIndex: colIndex,
                rightPos: rightPos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int colIndex,
                required double rightPos,
                Value<int> rowid = const Value.absent(),
              }) => ColRightPosCompanion.insert(
                sheetId: sheetId,
                colIndex: colIndex,
                rightPos: rightPos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColRightPosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$ColRightPosTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$ColRightPosTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ColRightPosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColRightPosTable,
      ColRightPo,
      $$ColRightPosTableFilterComposer,
      $$ColRightPosTableOrderingComposer,
      $$ColRightPosTableAnnotationComposer,
      $$ColRightPosTableCreateCompanionBuilder,
      $$ColRightPosTableUpdateCompanionBuilder,
      (ColRightPo, $$ColRightPosTableReferences),
      ColRightPo,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$RowsManuallyAdjustedHeightTableCreateCompanionBuilder =
    RowsManuallyAdjustedHeightCompanion Function({
      required int sheetId,
      required int rowIndex,
      required bool manuallyAdjusted,
      Value<int> rowid,
    });
typedef $$RowsManuallyAdjustedHeightTableUpdateCompanionBuilder =
    RowsManuallyAdjustedHeightCompanion Function({
      Value<int> sheetId,
      Value<int> rowIndex,
      Value<bool> manuallyAdjusted,
      Value<int> rowid,
    });

final class $$RowsManuallyAdjustedHeightTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RowsManuallyAdjustedHeightTable,
          RowsManuallyAdjustedHeightData
        > {
  $$RowsManuallyAdjustedHeightTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.rowsManuallyAdjustedHeight.sheetId,
          db.sheetDataTables.id,
        ),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RowsManuallyAdjustedHeightTableFilterComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTable> {
  $$RowsManuallyAdjustedHeightTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsManuallyAdjustedHeightTableOrderingComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTable> {
  $$RowsManuallyAdjustedHeightTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsManuallyAdjustedHeightTableAnnotationComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTable> {
  $$RowsManuallyAdjustedHeightTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => column,
  );

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RowsManuallyAdjustedHeightTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RowsManuallyAdjustedHeightTable,
          RowsManuallyAdjustedHeightData,
          $$RowsManuallyAdjustedHeightTableFilterComposer,
          $$RowsManuallyAdjustedHeightTableOrderingComposer,
          $$RowsManuallyAdjustedHeightTableAnnotationComposer,
          $$RowsManuallyAdjustedHeightTableCreateCompanionBuilder,
          $$RowsManuallyAdjustedHeightTableUpdateCompanionBuilder,
          (
            RowsManuallyAdjustedHeightData,
            $$RowsManuallyAdjustedHeightTableReferences,
          ),
          RowsManuallyAdjustedHeightData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$RowsManuallyAdjustedHeightTableTableManager(
    _$AppDatabase db,
    $RowsManuallyAdjustedHeightTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RowsManuallyAdjustedHeightTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RowsManuallyAdjustedHeightTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RowsManuallyAdjustedHeightTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<bool> manuallyAdjusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RowsManuallyAdjustedHeightCompanion(
                sheetId: sheetId,
                rowIndex: rowIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int rowIndex,
                required bool manuallyAdjusted,
                Value<int> rowid = const Value.absent(),
              }) => RowsManuallyAdjustedHeightCompanion.insert(
                sheetId: sheetId,
                rowIndex: rowIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RowsManuallyAdjustedHeightTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$RowsManuallyAdjustedHeightTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$RowsManuallyAdjustedHeightTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RowsManuallyAdjustedHeightTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RowsManuallyAdjustedHeightTable,
      RowsManuallyAdjustedHeightData,
      $$RowsManuallyAdjustedHeightTableFilterComposer,
      $$RowsManuallyAdjustedHeightTableOrderingComposer,
      $$RowsManuallyAdjustedHeightTableAnnotationComposer,
      $$RowsManuallyAdjustedHeightTableCreateCompanionBuilder,
      $$RowsManuallyAdjustedHeightTableUpdateCompanionBuilder,
      (
        RowsManuallyAdjustedHeightData,
        $$RowsManuallyAdjustedHeightTableReferences,
      ),
      RowsManuallyAdjustedHeightData,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$ColsManuallyAdjustedWidthTableCreateCompanionBuilder =
    ColsManuallyAdjustedWidthCompanion Function({
      required int sheetId,
      required int colIndex,
      required bool manuallyAdjusted,
      Value<int> rowid,
    });
typedef $$ColsManuallyAdjustedWidthTableUpdateCompanionBuilder =
    ColsManuallyAdjustedWidthCompanion Function({
      Value<int> sheetId,
      Value<int> colIndex,
      Value<bool> manuallyAdjusted,
      Value<int> rowid,
    });

final class $$ColsManuallyAdjustedWidthTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ColsManuallyAdjustedWidthTable,
          ColsManuallyAdjustedWidthData
        > {
  $$ColsManuallyAdjustedWidthTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.colsManuallyAdjustedWidth.sheetId,
          db.sheetDataTables.id,
        ),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ColsManuallyAdjustedWidthTableFilterComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTable> {
  $$ColsManuallyAdjustedWidthTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColsManuallyAdjustedWidthTableOrderingComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTable> {
  $$ColsManuallyAdjustedWidthTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get colIndex => $composableBuilder(
    column: $table.colIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColsManuallyAdjustedWidthTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTable> {
  $$ColsManuallyAdjustedWidthTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get colIndex =>
      $composableBuilder(column: $table.colIndex, builder: (column) => column);

  GeneratedColumn<bool> get manuallyAdjusted => $composableBuilder(
    column: $table.manuallyAdjusted,
    builder: (column) => column,
  );

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ColsManuallyAdjustedWidthTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColsManuallyAdjustedWidthTable,
          ColsManuallyAdjustedWidthData,
          $$ColsManuallyAdjustedWidthTableFilterComposer,
          $$ColsManuallyAdjustedWidthTableOrderingComposer,
          $$ColsManuallyAdjustedWidthTableAnnotationComposer,
          $$ColsManuallyAdjustedWidthTableCreateCompanionBuilder,
          $$ColsManuallyAdjustedWidthTableUpdateCompanionBuilder,
          (
            ColsManuallyAdjustedWidthData,
            $$ColsManuallyAdjustedWidthTableReferences,
          ),
          ColsManuallyAdjustedWidthData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$ColsManuallyAdjustedWidthTableTableManager(
    _$AppDatabase db,
    $ColsManuallyAdjustedWidthTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColsManuallyAdjustedWidthTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ColsManuallyAdjustedWidthTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ColsManuallyAdjustedWidthTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> colIndex = const Value.absent(),
                Value<bool> manuallyAdjusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColsManuallyAdjustedWidthCompanion(
                sheetId: sheetId,
                colIndex: colIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int colIndex,
                required bool manuallyAdjusted,
                Value<int> rowid = const Value.absent(),
              }) => ColsManuallyAdjustedWidthCompanion.insert(
                sheetId: sheetId,
                colIndex: colIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColsManuallyAdjustedWidthTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$ColsManuallyAdjustedWidthTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$ColsManuallyAdjustedWidthTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ColsManuallyAdjustedWidthTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColsManuallyAdjustedWidthTable,
      ColsManuallyAdjustedWidthData,
      $$ColsManuallyAdjustedWidthTableFilterComposer,
      $$ColsManuallyAdjustedWidthTableOrderingComposer,
      $$ColsManuallyAdjustedWidthTableAnnotationComposer,
      $$ColsManuallyAdjustedWidthTableCreateCompanionBuilder,
      $$ColsManuallyAdjustedWidthTableUpdateCompanionBuilder,
      (
        ColsManuallyAdjustedWidthData,
        $$ColsManuallyAdjustedWidthTableReferences,
      ),
      ColsManuallyAdjustedWidthData,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$SelectedCellsTableCreateCompanionBuilder =
    SelectedCellsCompanion Function({
      required int sheetId,
      required int cellIndex,
      required int row,
      required int col,
      Value<int> rowid,
    });
typedef $$SelectedCellsTableUpdateCompanionBuilder =
    SelectedCellsCompanion Function({
      Value<int> sheetId,
      Value<int> cellIndex,
      Value<int> row,
      Value<int> col,
      Value<int> rowid,
    });

final class $$SelectedCellsTableReferences
    extends BaseReferences<_$AppDatabase, $SelectedCellsTable, SelectedCell> {
  $$SelectedCellsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.selectedCells.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SelectedCellsTableFilterComposer
    extends Composer<_$AppDatabase, $SelectedCellsTable> {
  $$SelectedCellsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cellIndex => $composableBuilder(
    column: $table.cellIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get col => $composableBuilder(
    column: $table.col,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedCellsTableOrderingComposer
    extends Composer<_$AppDatabase, $SelectedCellsTable> {
  $$SelectedCellsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cellIndex => $composableBuilder(
    column: $table.cellIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get row => $composableBuilder(
    column: $table.row,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get col => $composableBuilder(
    column: $table.col,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedCellsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SelectedCellsTable> {
  $$SelectedCellsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cellIndex =>
      $composableBuilder(column: $table.cellIndex, builder: (column) => column);

  GeneratedColumn<int> get row =>
      $composableBuilder(column: $table.row, builder: (column) => column);

  GeneratedColumn<int> get col =>
      $composableBuilder(column: $table.col, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SelectedCellsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SelectedCellsTable,
          SelectedCell,
          $$SelectedCellsTableFilterComposer,
          $$SelectedCellsTableOrderingComposer,
          $$SelectedCellsTableAnnotationComposer,
          $$SelectedCellsTableCreateCompanionBuilder,
          $$SelectedCellsTableUpdateCompanionBuilder,
          (SelectedCell, $$SelectedCellsTableReferences),
          SelectedCell,
          PrefetchHooks Function({bool sheetId})
        > {
  $$SelectedCellsTableTableManager(_$AppDatabase db, $SelectedCellsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SelectedCellsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SelectedCellsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SelectedCellsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> cellIndex = const Value.absent(),
                Value<int> row = const Value.absent(),
                Value<int> col = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SelectedCellsCompanion(
                sheetId: sheetId,
                cellIndex: cellIndex,
                row: row,
                col: col,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int cellIndex,
                required int row,
                required int col,
                Value<int> rowid = const Value.absent(),
              }) => SelectedCellsCompanion.insert(
                sheetId: sheetId,
                cellIndex: cellIndex,
                row: row,
                col: col,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SelectedCellsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$SelectedCellsTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$SelectedCellsTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SelectedCellsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SelectedCellsTable,
      SelectedCell,
      $$SelectedCellsTableFilterComposer,
      $$SelectedCellsTableOrderingComposer,
      $$SelectedCellsTableAnnotationComposer,
      $$SelectedCellsTableCreateCompanionBuilder,
      $$SelectedCellsTableUpdateCompanionBuilder,
      (SelectedCell, $$SelectedCellsTableReferences),
      SelectedCell,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$BestSortFoundTableCreateCompanionBuilder =
    BestSortFoundCompanion Function({
      required int sheetId,
      required int sortIndex,
      required int value,
      Value<int> rowid,
    });
typedef $$BestSortFoundTableUpdateCompanionBuilder =
    BestSortFoundCompanion Function({
      Value<int> sheetId,
      Value<int> sortIndex,
      Value<int> value,
      Value<int> rowid,
    });

final class $$BestSortFoundTableReferences
    extends
        BaseReferences<_$AppDatabase, $BestSortFoundTable, BestSortFoundData> {
  $$BestSortFoundTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.bestSortFound.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BestSortFoundTableFilterComposer
    extends Composer<_$AppDatabase, $BestSortFoundTable> {
  $$BestSortFoundTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestSortFoundTableOrderingComposer
    extends Composer<_$AppDatabase, $BestSortFoundTable> {
  $$BestSortFoundTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestSortFoundTableAnnotationComposer
    extends Composer<_$AppDatabase, $BestSortFoundTable> {
  $$BestSortFoundTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestSortFoundTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BestSortFoundTable,
          BestSortFoundData,
          $$BestSortFoundTableFilterComposer,
          $$BestSortFoundTableOrderingComposer,
          $$BestSortFoundTableAnnotationComposer,
          $$BestSortFoundTableCreateCompanionBuilder,
          $$BestSortFoundTableUpdateCompanionBuilder,
          (BestSortFoundData, $$BestSortFoundTableReferences),
          BestSortFoundData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$BestSortFoundTableTableManager(_$AppDatabase db, $BestSortFoundTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BestSortFoundTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BestSortFoundTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BestSortFoundTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BestSortFoundCompanion(
                sheetId: sheetId,
                sortIndex: sortIndex,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int sortIndex,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => BestSortFoundCompanion.insert(
                sheetId: sheetId,
                sortIndex: sortIndex,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BestSortFoundTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$BestSortFoundTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$BestSortFoundTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BestSortFoundTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BestSortFoundTable,
      BestSortFoundData,
      $$BestSortFoundTableFilterComposer,
      $$BestSortFoundTableOrderingComposer,
      $$BestSortFoundTableAnnotationComposer,
      $$BestSortFoundTableCreateCompanionBuilder,
      $$BestSortFoundTableUpdateCompanionBuilder,
      (BestSortFoundData, $$BestSortFoundTableReferences),
      BestSortFoundData,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$CursorsTableCreateCompanionBuilder =
    CursorsCompanion Function({
      required int sheetId,
      required int cursorIndex,
      required int value,
      Value<int> rowid,
    });
typedef $$CursorsTableUpdateCompanionBuilder =
    CursorsCompanion Function({
      Value<int> sheetId,
      Value<int> cursorIndex,
      Value<int> value,
      Value<int> rowid,
    });

final class $$CursorsTableReferences
    extends BaseReferences<_$AppDatabase, $CursorsTable, Cursor> {
  $$CursorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.cursors.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CursorsTableFilterComposer
    extends Composer<_$AppDatabase, $CursorsTable> {
  $$CursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cursorIndex => $composableBuilder(
    column: $table.cursorIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $CursorsTable> {
  $$CursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cursorIndex => $composableBuilder(
    column: $table.cursorIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CursorsTable> {
  $$CursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cursorIndex => $composableBuilder(
    column: $table.cursorIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CursorsTable,
          Cursor,
          $$CursorsTableFilterComposer,
          $$CursorsTableOrderingComposer,
          $$CursorsTableAnnotationComposer,
          $$CursorsTableCreateCompanionBuilder,
          $$CursorsTableUpdateCompanionBuilder,
          (Cursor, $$CursorsTableReferences),
          Cursor,
          PrefetchHooks Function({bool sheetId})
        > {
  $$CursorsTableTableManager(_$AppDatabase db, $CursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> cursorIndex = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CursorsCompanion(
                sheetId: sheetId,
                cursorIndex: cursorIndex,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int cursorIndex,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => CursorsCompanion.insert(
                sheetId: sheetId,
                cursorIndex: cursorIndex,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CursorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$CursorsTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$CursorsTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CursorsTable,
      Cursor,
      $$CursorsTableFilterComposer,
      $$CursorsTableOrderingComposer,
      $$CursorsTableAnnotationComposer,
      $$CursorsTableCreateCompanionBuilder,
      $$CursorsTableUpdateCompanionBuilder,
      (Cursor, $$CursorsTableReferences),
      Cursor,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$PossibleIntsByIdTableCreateCompanionBuilder =
    PossibleIntsByIdCompanion Function({
      required int sheetId,
      required int id,
      required int intIndex,
      required int value,
      Value<int> rowid,
    });
typedef $$PossibleIntsByIdTableUpdateCompanionBuilder =
    PossibleIntsByIdCompanion Function({
      Value<int> sheetId,
      Value<int> id,
      Value<int> intIndex,
      Value<int> value,
      Value<int> rowid,
    });

final class $$PossibleIntsByIdTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PossibleIntsByIdTable,
          PossibleIntsByIdData
        > {
  $$PossibleIntsByIdTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.possibleIntsById.sheetId,
          db.sheetDataTables.id,
        ),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PossibleIntsByIdTableFilterComposer
    extends Composer<_$AppDatabase, $PossibleIntsByIdTable> {
  $$PossibleIntsByIdTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intIndex => $composableBuilder(
    column: $table.intIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PossibleIntsByIdTableOrderingComposer
    extends Composer<_$AppDatabase, $PossibleIntsByIdTable> {
  $$PossibleIntsByIdTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intIndex => $composableBuilder(
    column: $table.intIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PossibleIntsByIdTableAnnotationComposer
    extends Composer<_$AppDatabase, $PossibleIntsByIdTable> {
  $$PossibleIntsByIdTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get intIndex =>
      $composableBuilder(column: $table.intIndex, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PossibleIntsByIdTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PossibleIntsByIdTable,
          PossibleIntsByIdData,
          $$PossibleIntsByIdTableFilterComposer,
          $$PossibleIntsByIdTableOrderingComposer,
          $$PossibleIntsByIdTableAnnotationComposer,
          $$PossibleIntsByIdTableCreateCompanionBuilder,
          $$PossibleIntsByIdTableUpdateCompanionBuilder,
          (PossibleIntsByIdData, $$PossibleIntsByIdTableReferences),
          PossibleIntsByIdData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$PossibleIntsByIdTableTableManager(
    _$AppDatabase db,
    $PossibleIntsByIdTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PossibleIntsByIdTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PossibleIntsByIdTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PossibleIntsByIdTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> intIndex = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PossibleIntsByIdCompanion(
                sheetId: sheetId,
                id: id,
                intIndex: intIndex,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int id,
                required int intIndex,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => PossibleIntsByIdCompanion.insert(
                sheetId: sheetId,
                id: id,
                intIndex: intIndex,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PossibleIntsByIdTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable:
                                    $$PossibleIntsByIdTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$PossibleIntsByIdTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PossibleIntsByIdTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PossibleIntsByIdTable,
      PossibleIntsByIdData,
      $$PossibleIntsByIdTableFilterComposer,
      $$PossibleIntsByIdTableOrderingComposer,
      $$PossibleIntsByIdTableAnnotationComposer,
      $$PossibleIntsByIdTableCreateCompanionBuilder,
      $$PossibleIntsByIdTableUpdateCompanionBuilder,
      (PossibleIntsByIdData, $$PossibleIntsByIdTableReferences),
      PossibleIntsByIdData,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$ValidAreasByIdTableCreateCompanionBuilder =
    ValidAreasByIdCompanion Function({
      required int sheetId,
      required int id,
      required int intIndex,
      required int areaIndex,
      required int areaEdge,
      Value<int> rowid,
    });
typedef $$ValidAreasByIdTableUpdateCompanionBuilder =
    ValidAreasByIdCompanion Function({
      Value<int> sheetId,
      Value<int> id,
      Value<int> intIndex,
      Value<int> areaIndex,
      Value<int> areaEdge,
      Value<int> rowid,
    });

final class $$ValidAreasByIdTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ValidAreasByIdTable,
          ValidAreasByIdData
        > {
  $$ValidAreasByIdTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.validAreasById.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ValidAreasByIdTableFilterComposer
    extends Composer<_$AppDatabase, $ValidAreasByIdTable> {
  $$ValidAreasByIdTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intIndex => $composableBuilder(
    column: $table.intIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get areaIndex => $composableBuilder(
    column: $table.areaIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get areaEdge => $composableBuilder(
    column: $table.areaEdge,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValidAreasByIdTableOrderingComposer
    extends Composer<_$AppDatabase, $ValidAreasByIdTable> {
  $$ValidAreasByIdTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intIndex => $composableBuilder(
    column: $table.intIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get areaIndex => $composableBuilder(
    column: $table.areaIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get areaEdge => $composableBuilder(
    column: $table.areaEdge,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValidAreasByIdTableAnnotationComposer
    extends Composer<_$AppDatabase, $ValidAreasByIdTable> {
  $$ValidAreasByIdTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get intIndex =>
      $composableBuilder(column: $table.intIndex, builder: (column) => column);

  GeneratedColumn<int> get areaIndex =>
      $composableBuilder(column: $table.areaIndex, builder: (column) => column);

  GeneratedColumn<int> get areaEdge =>
      $composableBuilder(column: $table.areaEdge, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValidAreasByIdTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ValidAreasByIdTable,
          ValidAreasByIdData,
          $$ValidAreasByIdTableFilterComposer,
          $$ValidAreasByIdTableOrderingComposer,
          $$ValidAreasByIdTableAnnotationComposer,
          $$ValidAreasByIdTableCreateCompanionBuilder,
          $$ValidAreasByIdTableUpdateCompanionBuilder,
          (ValidAreasByIdData, $$ValidAreasByIdTableReferences),
          ValidAreasByIdData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$ValidAreasByIdTableTableManager(
    _$AppDatabase db,
    $ValidAreasByIdTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ValidAreasByIdTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ValidAreasByIdTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ValidAreasByIdTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> intIndex = const Value.absent(),
                Value<int> areaIndex = const Value.absent(),
                Value<int> areaEdge = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ValidAreasByIdCompanion(
                sheetId: sheetId,
                id: id,
                intIndex: intIndex,
                areaIndex: areaIndex,
                areaEdge: areaEdge,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int id,
                required int intIndex,
                required int areaIndex,
                required int areaEdge,
                Value<int> rowid = const Value.absent(),
              }) => ValidAreasByIdCompanion.insert(
                sheetId: sheetId,
                id: id,
                intIndex: intIndex,
                areaIndex: areaIndex,
                areaEdge: areaEdge,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ValidAreasByIdTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$ValidAreasByIdTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn:
                                    $$ValidAreasByIdTableReferences
                                        ._sheetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ValidAreasByIdTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ValidAreasByIdTable,
      ValidAreasByIdData,
      $$ValidAreasByIdTableFilterComposer,
      $$ValidAreasByIdTableOrderingComposer,
      $$ValidAreasByIdTableAnnotationComposer,
      $$ValidAreasByIdTableCreateCompanionBuilder,
      $$ValidAreasByIdTableUpdateCompanionBuilder,
      (ValidAreasByIdData, $$ValidAreasByIdTableReferences),
      ValidAreasByIdData,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$BestDistFoundTableCreateCompanionBuilder =
    BestDistFoundCompanion Function({
      required int sheetId,
      required int id,
      required int value,
      Value<int> rowid,
    });
typedef $$BestDistFoundTableUpdateCompanionBuilder =
    BestDistFoundCompanion Function({
      Value<int> sheetId,
      Value<int> id,
      Value<int> value,
      Value<int> rowid,
    });

final class $$BestDistFoundTableReferences
    extends
        BaseReferences<_$AppDatabase, $BestDistFoundTable, BestDistFoundData> {
  $$BestDistFoundTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.bestDistFound.sheetId, db.sheetDataTables.id),
      );

  $$SheetDataTablesTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetDataTablesTableTableManager(
      $_db,
      $_db.sheetDataTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BestDistFoundTableFilterComposer
    extends Composer<_$AppDatabase, $BestDistFoundTable> {
  $$BestDistFoundTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetDataTablesTableFilterComposer get sheetId {
    final $$SheetDataTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableFilterComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestDistFoundTableOrderingComposer
    extends Composer<_$AppDatabase, $BestDistFoundTable> {
  $$BestDistFoundTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetDataTablesTableOrderingComposer get sheetId {
    final $$SheetDataTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableOrderingComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestDistFoundTableAnnotationComposer
    extends Composer<_$AppDatabase, $BestDistFoundTable> {
  $$BestDistFoundTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$SheetDataTablesTableAnnotationComposer get sheetId {
    final $$SheetDataTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheetDataTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetDataTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetDataTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestDistFoundTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BestDistFoundTable,
          BestDistFoundData,
          $$BestDistFoundTableFilterComposer,
          $$BestDistFoundTableOrderingComposer,
          $$BestDistFoundTableAnnotationComposer,
          $$BestDistFoundTableCreateCompanionBuilder,
          $$BestDistFoundTableUpdateCompanionBuilder,
          (BestDistFoundData, $$BestDistFoundTableReferences),
          BestDistFoundData,
          PrefetchHooks Function({bool sheetId})
        > {
  $$BestDistFoundTableTableManager(_$AppDatabase db, $BestDistFoundTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BestDistFoundTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BestDistFoundTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BestDistFoundTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BestDistFoundCompanion(
                sheetId: sheetId,
                id: id,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sheetId,
                required int id,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => BestDistFoundCompanion.insert(
                sheetId: sheetId,
                id: id,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BestDistFoundTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$BestDistFoundTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$BestDistFoundTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BestDistFoundTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BestDistFoundTable,
      BestDistFoundData,
      $$BestDistFoundTableFilterComposer,
      $$BestDistFoundTableOrderingComposer,
      $$BestDistFoundTableAnnotationComposer,
      $$BestDistFoundTableCreateCompanionBuilder,
      $$BestDistFoundTableUpdateCompanionBuilder,
      (BestDistFoundData, $$BestDistFoundTableReferences),
      BestDistFoundData,
      PrefetchHooks Function({bool sheetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SheetDataTablesTableTableManager get sheetDataTables =>
      $$SheetDataTablesTableTableManager(_db, _db.sheetDataTables);
  $$SheetCellsTableTableManager get sheetCells =>
      $$SheetCellsTableTableManager(_db, _db.sheetCells);
  $$SheetColumnTypesTableTableManager get sheetColumnTypes =>
      $$SheetColumnTypesTableTableManager(_db, _db.sheetColumnTypes);
  $$UpdateHistoriesTableTableManager get updateHistories =>
      $$UpdateHistoriesTableTableManager(_db, _db.updateHistories);
  $$RowsBottomPosTableTableManager get rowsBottomPos =>
      $$RowsBottomPosTableTableManager(_db, _db.rowsBottomPos);
  $$ColRightPosTableTableManager get colRightPos =>
      $$ColRightPosTableTableManager(_db, _db.colRightPos);
  $$RowsManuallyAdjustedHeightTableTableManager
  get rowsManuallyAdjustedHeight =>
      $$RowsManuallyAdjustedHeightTableTableManager(
        _db,
        _db.rowsManuallyAdjustedHeight,
      );
  $$ColsManuallyAdjustedWidthTableTableManager get colsManuallyAdjustedWidth =>
      $$ColsManuallyAdjustedWidthTableTableManager(
        _db,
        _db.colsManuallyAdjustedWidth,
      );
  $$SelectedCellsTableTableManager get selectedCells =>
      $$SelectedCellsTableTableManager(_db, _db.selectedCells);
  $$BestSortFoundTableTableManager get bestSortFound =>
      $$BestSortFoundTableTableManager(_db, _db.bestSortFound);
  $$CursorsTableTableManager get cursors =>
      $$CursorsTableTableManager(_db, _db.cursors);
  $$PossibleIntsByIdTableTableManager get possibleIntsById =>
      $$PossibleIntsByIdTableTableManager(_db, _db.possibleIntsById);
  $$ValidAreasByIdTableTableManager get validAreasById =>
      $$ValidAreasByIdTableTableManager(_db, _db.validAreasById);
  $$BestDistFoundTableTableManager get bestDistFound =>
      $$BestDistFoundTableTableManager(_db, _db.bestDistFound);
}
