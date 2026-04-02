// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SheetDataTablesTable extends SheetDataTables
    with TableInfo<$SheetDataTablesTable, SheetDataEntity> {
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedMeta = const VerificationMeta(
    'lastOpened',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpened = GeneratedColumn<DateTime>(
    'last_opened',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> usedRows =
      GeneratedColumn<String>(
        'used_rows',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($SheetDataTablesTable.$converterusedRows);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> usedCols =
      GeneratedColumn<String>(
        'used_cols',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($SheetDataTablesTable.$converterusedCols);
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
  @override
  late final GeneratedColumnWithTypeConverter<List<CellPosition>, String>
  primSelHistory =
      GeneratedColumn<String>(
        'prim_sel_history',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<CellPosition>>(
        $SheetDataTablesTable.$converterprimSelHistory,
      );
  static const VerificationMeta _primSelHistoryIdMeta = const VerificationMeta(
    'primSelHistoryId',
  );
  @override
  late final GeneratedColumn<int> primSelHistoryId = GeneratedColumn<int>(
    'prim_sel_history_id',
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
  @override
  late final GeneratedColumnWithTypeConverter<Set<CellPosition>, String>
  selectedCells =
      GeneratedColumn<String>(
        'selected_cells',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<CellPosition>>(
        $SheetDataTablesTable.$converterselectedCells,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> bestSortFound =
      GeneratedColumn<String>(
        'best_sort_found',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($SheetDataTablesTable.$converterbestSortFound);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> bestDistFound =
      GeneratedColumn<String>(
        'best_dist_found',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($SheetDataTablesTable.$converterbestDistFound);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> cursors =
      GeneratedColumn<String>(
        'cursors',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<int>>($SheetDataTablesTable.$convertercursors);
  @override
  late final GeneratedColumnWithTypeConverter<List<List<int>>, String>
  possibleInts =
      GeneratedColumn<String>(
        'possible_ints',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<List<int>>>(
        $SheetDataTablesTable.$converterpossibleInts,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<List<List<int>>>, String>
  validAreas =
      GeneratedColumn<String>(
        'valid_areas',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<List<List<int>>>>(
        $SheetDataTablesTable.$convertervalidAreas,
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
  static const VerificationMeta _validSortIsImpossibleMeta =
      const VerificationMeta('validSortIsImpossible');
  @override
  late final GeneratedColumn<bool> validSortIsImpossible =
      GeneratedColumn<bool>(
        'valid_sort_is_impossible',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("valid_sort_is_impossible" IN (0, 1))',
        ),
      );
  static const VerificationMeta _isFindingBestSortMeta = const VerificationMeta(
    'isFindingBestSort',
  );
  @override
  late final GeneratedColumn<bool> isFindingBestSort = GeneratedColumn<bool>(
    'is_finding_best_sort',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_finding_best_sort" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortedWithValidSortMeta =
      const VerificationMeta('sortedWithValidSort');
  @override
  late final GeneratedColumn<bool> sortedWithValidSort = GeneratedColumn<bool>(
    'sorted_with_valid_sort',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sorted_with_valid_sort" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortedWithCurrentBestSortMeta =
      const VerificationMeta('sortedWithCurrentBestSort');
  @override
  late final GeneratedColumn<bool> sortedWithCurrentBestSort =
      GeneratedColumn<bool>(
        'sorted_with_current_best_sort',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sorted_with_current_best_sort" IN (0, 1))',
        ),
      );
  static const VerificationMeta _bestSortPossibleFoundMeta =
      const VerificationMeta('bestSortPossibleFound');
  @override
  late final GeneratedColumn<bool> bestSortPossibleFound =
      GeneratedColumn<bool>(
        'best_sort_possible_found',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("best_sort_possible_found" IN (0, 1))',
        ),
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
    title,
    lastOpened,
    usedRows,
    usedCols,
    historyIndex,
    colHeaderHeight,
    rowHeaderWidth,
    primSelHistory,
    primSelHistoryId,
    scrollOffsetX,
    scrollOffsetY,
    selectedCells,
    bestSortFound,
    bestDistFound,
    cursors,
    possibleInts,
    validAreas,
    sortIndex,
    analysisResult,
    validSortIsImpossible,
    isFindingBestSort,
    sortedWithValidSort,
    sortedWithCurrentBestSort,
    bestSortPossibleFound,
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
    Insertable<SheetDataEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('last_opened')) {
      context.handle(
        _lastOpenedMeta,
        lastOpened.isAcceptableOrUnknown(data['last_opened']!, _lastOpenedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedMeta);
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
    if (data.containsKey('prim_sel_history_id')) {
      context.handle(
        _primSelHistoryIdMeta,
        primSelHistoryId.isAcceptableOrUnknown(
          data['prim_sel_history_id']!,
          _primSelHistoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primSelHistoryIdMeta);
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
    if (data.containsKey('valid_sort_is_impossible')) {
      context.handle(
        _validSortIsImpossibleMeta,
        validSortIsImpossible.isAcceptableOrUnknown(
          data['valid_sort_is_impossible']!,
          _validSortIsImpossibleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_validSortIsImpossibleMeta);
    }
    if (data.containsKey('is_finding_best_sort')) {
      context.handle(
        _isFindingBestSortMeta,
        isFindingBestSort.isAcceptableOrUnknown(
          data['is_finding_best_sort']!,
          _isFindingBestSortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isFindingBestSortMeta);
    }
    if (data.containsKey('sorted_with_valid_sort')) {
      context.handle(
        _sortedWithValidSortMeta,
        sortedWithValidSort.isAcceptableOrUnknown(
          data['sorted_with_valid_sort']!,
          _sortedWithValidSortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sortedWithValidSortMeta);
    }
    if (data.containsKey('sorted_with_current_best_sort')) {
      context.handle(
        _sortedWithCurrentBestSortMeta,
        sortedWithCurrentBestSort.isAcceptableOrUnknown(
          data['sorted_with_current_best_sort']!,
          _sortedWithCurrentBestSortMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sortedWithCurrentBestSortMeta);
    }
    if (data.containsKey('best_sort_possible_found')) {
      context.handle(
        _bestSortPossibleFoundMeta,
        bestSortPossibleFound.isAcceptableOrUnknown(
          data['best_sort_possible_found']!,
          _bestSortPossibleFoundMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bestSortPossibleFoundMeta);
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
  SheetDataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetDataEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      lastOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened'],
      )!,
      usedRows: $SheetDataTablesTable.$converterusedRows.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}used_rows'],
        )!,
      ),
      usedCols: $SheetDataTablesTable.$converterusedCols.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}used_cols'],
        )!,
      ),
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
      primSelHistory: $SheetDataTablesTable.$converterprimSelHistory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prim_sel_history'],
        )!,
      ),
      primSelHistoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prim_sel_history_id'],
      )!,
      scrollOffsetX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_offset_x'],
      )!,
      scrollOffsetY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scroll_offset_y'],
      )!,
      selectedCells: $SheetDataTablesTable.$converterselectedCells.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_cells'],
        )!,
      ),
      bestSortFound: $SheetDataTablesTable.$converterbestSortFound.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}best_sort_found'],
        )!,
      ),
      bestDistFound: $SheetDataTablesTable.$converterbestDistFound.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}best_dist_found'],
        )!,
      ),
      cursors: $SheetDataTablesTable.$convertercursors.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cursors'],
        )!,
      ),
      possibleInts: $SheetDataTablesTable.$converterpossibleInts.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}possible_ints'],
        )!,
      ),
      validAreas: $SheetDataTablesTable.$convertervalidAreas.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}valid_areas'],
        )!,
      ),
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
      validSortIsImpossible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}valid_sort_is_impossible'],
      )!,
      isFindingBestSort: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_finding_best_sort'],
      )!,
      sortedWithValidSort: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sorted_with_valid_sort'],
      )!,
      sortedWithCurrentBestSort: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sorted_with_current_best_sort'],
      )!,
      bestSortPossibleFound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}best_sort_possible_found'],
      )!,
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

  static TypeConverter<List<int>, String> $converterusedRows =
      const ListIntConverter();
  static TypeConverter<List<int>, String> $converterusedCols =
      const ListIntConverter();
  static TypeConverter<List<CellPosition>, String> $converterprimSelHistory =
      const ListPointConverter();
  static TypeConverter<Set<CellPosition>, String> $converterselectedCells =
      const SetPointConverter();
  static TypeConverter<List<int>, String> $converterbestSortFound =
      const ListIntConverter();
  static TypeConverter<List<int>, String> $converterbestDistFound =
      const ListIntConverter();
  static TypeConverter<List<int>, String> $convertercursors =
      const ListIntConverter();
  static TypeConverter<List<List<int>>, String> $converterpossibleInts =
      const ListListIntConverter();
  static TypeConverter<List<List<List<int>>>, String> $convertervalidAreas =
      const ListListListIntConverter();
  static TypeConverter<AnalysisResult, String> $converteranalysisResult =
      const AnalysisResultConverter();
}

class SheetDataEntity extends DataClass implements Insertable<SheetDataEntity> {
  final int id;
  final String title;
  final DateTime lastOpened;
  final List<int> usedRows;
  final List<int> usedCols;
  final int historyIndex;
  final double colHeaderHeight;
  final double rowHeaderWidth;
  final List<CellPosition> primSelHistory;
  final int primSelHistoryId;
  final double scrollOffsetX;
  final double scrollOffsetY;
  final Set<CellPosition> selectedCells;
  final List<int> bestSortFound;
  final List<int> bestDistFound;
  final List<int> cursors;
  final List<List<int>> possibleInts;
  final List<List<List<int>>> validAreas;
  final int sortIndex;
  final AnalysisResult analysisResult;
  final bool validSortIsImpossible;
  final bool isFindingBestSort;
  final bool sortedWithValidSort;
  final bool sortedWithCurrentBestSort;
  final bool bestSortPossibleFound;
  final bool sortInProgress;
  final bool toApplyNextBestSort;
  final bool toAlwaysApplyCurrentBestSort;
  final bool analysisDone;
  const SheetDataEntity({
    required this.id,
    required this.title,
    required this.lastOpened,
    required this.usedRows,
    required this.usedCols,
    required this.historyIndex,
    required this.colHeaderHeight,
    required this.rowHeaderWidth,
    required this.primSelHistory,
    required this.primSelHistoryId,
    required this.scrollOffsetX,
    required this.scrollOffsetY,
    required this.selectedCells,
    required this.bestSortFound,
    required this.bestDistFound,
    required this.cursors,
    required this.possibleInts,
    required this.validAreas,
    required this.sortIndex,
    required this.analysisResult,
    required this.validSortIsImpossible,
    required this.isFindingBestSort,
    required this.sortedWithValidSort,
    required this.sortedWithCurrentBestSort,
    required this.bestSortPossibleFound,
    required this.sortInProgress,
    required this.toApplyNextBestSort,
    required this.toAlwaysApplyCurrentBestSort,
    required this.analysisDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['last_opened'] = Variable<DateTime>(lastOpened);
    {
      map['used_rows'] = Variable<String>(
        $SheetDataTablesTable.$converterusedRows.toSql(usedRows),
      );
    }
    {
      map['used_cols'] = Variable<String>(
        $SheetDataTablesTable.$converterusedCols.toSql(usedCols),
      );
    }
    map['history_index'] = Variable<int>(historyIndex);
    map['col_header_height'] = Variable<double>(colHeaderHeight);
    map['row_header_width'] = Variable<double>(rowHeaderWidth);
    {
      map['prim_sel_history'] = Variable<String>(
        $SheetDataTablesTable.$converterprimSelHistory.toSql(primSelHistory),
      );
    }
    map['prim_sel_history_id'] = Variable<int>(primSelHistoryId);
    map['scroll_offset_x'] = Variable<double>(scrollOffsetX);
    map['scroll_offset_y'] = Variable<double>(scrollOffsetY);
    {
      map['selected_cells'] = Variable<String>(
        $SheetDataTablesTable.$converterselectedCells.toSql(selectedCells),
      );
    }
    {
      map['best_sort_found'] = Variable<String>(
        $SheetDataTablesTable.$converterbestSortFound.toSql(bestSortFound),
      );
    }
    {
      map['best_dist_found'] = Variable<String>(
        $SheetDataTablesTable.$converterbestDistFound.toSql(bestDistFound),
      );
    }
    {
      map['cursors'] = Variable<String>(
        $SheetDataTablesTable.$convertercursors.toSql(cursors),
      );
    }
    {
      map['possible_ints'] = Variable<String>(
        $SheetDataTablesTable.$converterpossibleInts.toSql(possibleInts),
      );
    }
    {
      map['valid_areas'] = Variable<String>(
        $SheetDataTablesTable.$convertervalidAreas.toSql(validAreas),
      );
    }
    map['sort_index'] = Variable<int>(sortIndex);
    {
      map['analysis_result'] = Variable<String>(
        $SheetDataTablesTable.$converteranalysisResult.toSql(analysisResult),
      );
    }
    map['valid_sort_is_impossible'] = Variable<bool>(validSortIsImpossible);
    map['is_finding_best_sort'] = Variable<bool>(isFindingBestSort);
    map['sorted_with_valid_sort'] = Variable<bool>(sortedWithValidSort);
    map['sorted_with_current_best_sort'] = Variable<bool>(
      sortedWithCurrentBestSort,
    );
    map['best_sort_possible_found'] = Variable<bool>(bestSortPossibleFound);
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
      title: Value(title),
      lastOpened: Value(lastOpened),
      usedRows: Value(usedRows),
      usedCols: Value(usedCols),
      historyIndex: Value(historyIndex),
      colHeaderHeight: Value(colHeaderHeight),
      rowHeaderWidth: Value(rowHeaderWidth),
      primSelHistory: Value(primSelHistory),
      primSelHistoryId: Value(primSelHistoryId),
      scrollOffsetX: Value(scrollOffsetX),
      scrollOffsetY: Value(scrollOffsetY),
      selectedCells: Value(selectedCells),
      bestSortFound: Value(bestSortFound),
      bestDistFound: Value(bestDistFound),
      cursors: Value(cursors),
      possibleInts: Value(possibleInts),
      validAreas: Value(validAreas),
      sortIndex: Value(sortIndex),
      analysisResult: Value(analysisResult),
      validSortIsImpossible: Value(validSortIsImpossible),
      isFindingBestSort: Value(isFindingBestSort),
      sortedWithValidSort: Value(sortedWithValidSort),
      sortedWithCurrentBestSort: Value(sortedWithCurrentBestSort),
      bestSortPossibleFound: Value(bestSortPossibleFound),
      sortInProgress: Value(sortInProgress),
      toApplyNextBestSort: Value(toApplyNextBestSort),
      toAlwaysApplyCurrentBestSort: Value(toAlwaysApplyCurrentBestSort),
      analysisDone: Value(analysisDone),
    );
  }

  factory SheetDataEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetDataEntity(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      lastOpened: serializer.fromJson<DateTime>(json['lastOpened']),
      usedRows: serializer.fromJson<List<int>>(json['usedRows']),
      usedCols: serializer.fromJson<List<int>>(json['usedCols']),
      historyIndex: serializer.fromJson<int>(json['historyIndex']),
      colHeaderHeight: serializer.fromJson<double>(json['colHeaderHeight']),
      rowHeaderWidth: serializer.fromJson<double>(json['rowHeaderWidth']),
      primSelHistory: serializer.fromJson<List<CellPosition>>(
        json['primSelHistory'],
      ),
      primSelHistoryId: serializer.fromJson<int>(json['primSelHistoryId']),
      scrollOffsetX: serializer.fromJson<double>(json['scrollOffsetX']),
      scrollOffsetY: serializer.fromJson<double>(json['scrollOffsetY']),
      selectedCells: serializer.fromJson<Set<CellPosition>>(
        json['selectedCells'],
      ),
      bestSortFound: serializer.fromJson<List<int>>(json['bestSortFound']),
      bestDistFound: serializer.fromJson<List<int>>(json['bestDistFound']),
      cursors: serializer.fromJson<List<int>>(json['cursors']),
      possibleInts: serializer.fromJson<List<List<int>>>(json['possibleInts']),
      validAreas: serializer.fromJson<List<List<List<int>>>>(
        json['validAreas'],
      ),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      analysisResult: serializer.fromJson<AnalysisResult>(
        json['analysisResult'],
      ),
      validSortIsImpossible: serializer.fromJson<bool>(
        json['validSortIsImpossible'],
      ),
      isFindingBestSort: serializer.fromJson<bool>(json['isFindingBestSort']),
      sortedWithValidSort: serializer.fromJson<bool>(
        json['sortedWithValidSort'],
      ),
      sortedWithCurrentBestSort: serializer.fromJson<bool>(
        json['sortedWithCurrentBestSort'],
      ),
      bestSortPossibleFound: serializer.fromJson<bool>(
        json['bestSortPossibleFound'],
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
      'title': serializer.toJson<String>(title),
      'lastOpened': serializer.toJson<DateTime>(lastOpened),
      'usedRows': serializer.toJson<List<int>>(usedRows),
      'usedCols': serializer.toJson<List<int>>(usedCols),
      'historyIndex': serializer.toJson<int>(historyIndex),
      'colHeaderHeight': serializer.toJson<double>(colHeaderHeight),
      'rowHeaderWidth': serializer.toJson<double>(rowHeaderWidth),
      'primSelHistory': serializer.toJson<List<CellPosition>>(primSelHistory),
      'primSelHistoryId': serializer.toJson<int>(primSelHistoryId),
      'scrollOffsetX': serializer.toJson<double>(scrollOffsetX),
      'scrollOffsetY': serializer.toJson<double>(scrollOffsetY),
      'selectedCells': serializer.toJson<Set<CellPosition>>(selectedCells),
      'bestSortFound': serializer.toJson<List<int>>(bestSortFound),
      'bestDistFound': serializer.toJson<List<int>>(bestDistFound),
      'cursors': serializer.toJson<List<int>>(cursors),
      'possibleInts': serializer.toJson<List<List<int>>>(possibleInts),
      'validAreas': serializer.toJson<List<List<List<int>>>>(validAreas),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'analysisResult': serializer.toJson<AnalysisResult>(analysisResult),
      'validSortIsImpossible': serializer.toJson<bool>(validSortIsImpossible),
      'isFindingBestSort': serializer.toJson<bool>(isFindingBestSort),
      'sortedWithValidSort': serializer.toJson<bool>(sortedWithValidSort),
      'sortedWithCurrentBestSort': serializer.toJson<bool>(
        sortedWithCurrentBestSort,
      ),
      'bestSortPossibleFound': serializer.toJson<bool>(bestSortPossibleFound),
      'sortInProgress': serializer.toJson<bool>(sortInProgress),
      'toApplyNextBestSort': serializer.toJson<bool>(toApplyNextBestSort),
      'toAlwaysApplyCurrentBestSort': serializer.toJson<bool>(
        toAlwaysApplyCurrentBestSort,
      ),
      'analysisDone': serializer.toJson<bool>(analysisDone),
    };
  }

  SheetDataEntity copyWith({
    int? id,
    String? title,
    DateTime? lastOpened,
    List<int>? usedRows,
    List<int>? usedCols,
    int? historyIndex,
    double? colHeaderHeight,
    double? rowHeaderWidth,
    List<CellPosition>? primSelHistory,
    int? primSelHistoryId,
    double? scrollOffsetX,
    double? scrollOffsetY,
    Set<CellPosition>? selectedCells,
    List<int>? bestSortFound,
    List<int>? bestDistFound,
    List<int>? cursors,
    List<List<int>>? possibleInts,
    List<List<List<int>>>? validAreas,
    int? sortIndex,
    AnalysisResult? analysisResult,
    bool? validSortIsImpossible,
    bool? isFindingBestSort,
    bool? sortedWithValidSort,
    bool? sortedWithCurrentBestSort,
    bool? bestSortPossibleFound,
    bool? sortInProgress,
    bool? toApplyNextBestSort,
    bool? toAlwaysApplyCurrentBestSort,
    bool? analysisDone,
  }) => SheetDataEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    lastOpened: lastOpened ?? this.lastOpened,
    usedRows: usedRows ?? this.usedRows,
    usedCols: usedCols ?? this.usedCols,
    historyIndex: historyIndex ?? this.historyIndex,
    colHeaderHeight: colHeaderHeight ?? this.colHeaderHeight,
    rowHeaderWidth: rowHeaderWidth ?? this.rowHeaderWidth,
    primSelHistory: primSelHistory ?? this.primSelHistory,
    primSelHistoryId: primSelHistoryId ?? this.primSelHistoryId,
    scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
    scrollOffsetY: scrollOffsetY ?? this.scrollOffsetY,
    selectedCells: selectedCells ?? this.selectedCells,
    bestSortFound: bestSortFound ?? this.bestSortFound,
    bestDistFound: bestDistFound ?? this.bestDistFound,
    cursors: cursors ?? this.cursors,
    possibleInts: possibleInts ?? this.possibleInts,
    validAreas: validAreas ?? this.validAreas,
    sortIndex: sortIndex ?? this.sortIndex,
    analysisResult: analysisResult ?? this.analysisResult,
    validSortIsImpossible: validSortIsImpossible ?? this.validSortIsImpossible,
    isFindingBestSort: isFindingBestSort ?? this.isFindingBestSort,
    sortedWithValidSort: sortedWithValidSort ?? this.sortedWithValidSort,
    sortedWithCurrentBestSort:
        sortedWithCurrentBestSort ?? this.sortedWithCurrentBestSort,
    bestSortPossibleFound: bestSortPossibleFound ?? this.bestSortPossibleFound,
    sortInProgress: sortInProgress ?? this.sortInProgress,
    toApplyNextBestSort: toApplyNextBestSort ?? this.toApplyNextBestSort,
    toAlwaysApplyCurrentBestSort:
        toAlwaysApplyCurrentBestSort ?? this.toAlwaysApplyCurrentBestSort,
    analysisDone: analysisDone ?? this.analysisDone,
  );
  SheetDataEntity copyWithCompanion(SheetDataTablesCompanion data) {
    return SheetDataEntity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      lastOpened: data.lastOpened.present
          ? data.lastOpened.value
          : this.lastOpened,
      usedRows: data.usedRows.present ? data.usedRows.value : this.usedRows,
      usedCols: data.usedCols.present ? data.usedCols.value : this.usedCols,
      historyIndex: data.historyIndex.present
          ? data.historyIndex.value
          : this.historyIndex,
      colHeaderHeight: data.colHeaderHeight.present
          ? data.colHeaderHeight.value
          : this.colHeaderHeight,
      rowHeaderWidth: data.rowHeaderWidth.present
          ? data.rowHeaderWidth.value
          : this.rowHeaderWidth,
      primSelHistory: data.primSelHistory.present
          ? data.primSelHistory.value
          : this.primSelHistory,
      primSelHistoryId: data.primSelHistoryId.present
          ? data.primSelHistoryId.value
          : this.primSelHistoryId,
      scrollOffsetX: data.scrollOffsetX.present
          ? data.scrollOffsetX.value
          : this.scrollOffsetX,
      scrollOffsetY: data.scrollOffsetY.present
          ? data.scrollOffsetY.value
          : this.scrollOffsetY,
      selectedCells: data.selectedCells.present
          ? data.selectedCells.value
          : this.selectedCells,
      bestSortFound: data.bestSortFound.present
          ? data.bestSortFound.value
          : this.bestSortFound,
      bestDistFound: data.bestDistFound.present
          ? data.bestDistFound.value
          : this.bestDistFound,
      cursors: data.cursors.present ? data.cursors.value : this.cursors,
      possibleInts: data.possibleInts.present
          ? data.possibleInts.value
          : this.possibleInts,
      validAreas: data.validAreas.present
          ? data.validAreas.value
          : this.validAreas,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      analysisResult: data.analysisResult.present
          ? data.analysisResult.value
          : this.analysisResult,
      validSortIsImpossible: data.validSortIsImpossible.present
          ? data.validSortIsImpossible.value
          : this.validSortIsImpossible,
      isFindingBestSort: data.isFindingBestSort.present
          ? data.isFindingBestSort.value
          : this.isFindingBestSort,
      sortedWithValidSort: data.sortedWithValidSort.present
          ? data.sortedWithValidSort.value
          : this.sortedWithValidSort,
      sortedWithCurrentBestSort: data.sortedWithCurrentBestSort.present
          ? data.sortedWithCurrentBestSort.value
          : this.sortedWithCurrentBestSort,
      bestSortPossibleFound: data.bestSortPossibleFound.present
          ? data.bestSortPossibleFound.value
          : this.bestSortPossibleFound,
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
    return (StringBuffer('SheetDataEntity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lastOpened: $lastOpened, ')
          ..write('usedRows: $usedRows, ')
          ..write('usedCols: $usedCols, ')
          ..write('historyIndex: $historyIndex, ')
          ..write('colHeaderHeight: $colHeaderHeight, ')
          ..write('rowHeaderWidth: $rowHeaderWidth, ')
          ..write('primSelHistory: $primSelHistory, ')
          ..write('primSelHistoryId: $primSelHistoryId, ')
          ..write('scrollOffsetX: $scrollOffsetX, ')
          ..write('scrollOffsetY: $scrollOffsetY, ')
          ..write('selectedCells: $selectedCells, ')
          ..write('bestSortFound: $bestSortFound, ')
          ..write('bestDistFound: $bestDistFound, ')
          ..write('cursors: $cursors, ')
          ..write('possibleInts: $possibleInts, ')
          ..write('validAreas: $validAreas, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('analysisResult: $analysisResult, ')
          ..write('validSortIsImpossible: $validSortIsImpossible, ')
          ..write('isFindingBestSort: $isFindingBestSort, ')
          ..write('sortedWithValidSort: $sortedWithValidSort, ')
          ..write('sortedWithCurrentBestSort: $sortedWithCurrentBestSort, ')
          ..write('bestSortPossibleFound: $bestSortPossibleFound, ')
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
  int get hashCode => Object.hashAll([
    id,
    title,
    lastOpened,
    usedRows,
    usedCols,
    historyIndex,
    colHeaderHeight,
    rowHeaderWidth,
    primSelHistory,
    primSelHistoryId,
    scrollOffsetX,
    scrollOffsetY,
    selectedCells,
    bestSortFound,
    bestDistFound,
    cursors,
    possibleInts,
    validAreas,
    sortIndex,
    analysisResult,
    validSortIsImpossible,
    isFindingBestSort,
    sortedWithValidSort,
    sortedWithCurrentBestSort,
    bestSortPossibleFound,
    sortInProgress,
    toApplyNextBestSort,
    toAlwaysApplyCurrentBestSort,
    analysisDone,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SheetDataEntity &&
          other.id == this.id &&
          other.title == this.title &&
          other.lastOpened == this.lastOpened &&
          other.usedRows == this.usedRows &&
          other.usedCols == this.usedCols &&
          other.historyIndex == this.historyIndex &&
          other.colHeaderHeight == this.colHeaderHeight &&
          other.rowHeaderWidth == this.rowHeaderWidth &&
          other.primSelHistory == this.primSelHistory &&
          other.primSelHistoryId == this.primSelHistoryId &&
          other.scrollOffsetX == this.scrollOffsetX &&
          other.scrollOffsetY == this.scrollOffsetY &&
          other.selectedCells == this.selectedCells &&
          other.bestSortFound == this.bestSortFound &&
          other.bestDistFound == this.bestDistFound &&
          other.cursors == this.cursors &&
          other.possibleInts == this.possibleInts &&
          other.validAreas == this.validAreas &&
          other.sortIndex == this.sortIndex &&
          other.analysisResult == this.analysisResult &&
          other.validSortIsImpossible == this.validSortIsImpossible &&
          other.isFindingBestSort == this.isFindingBestSort &&
          other.sortedWithValidSort == this.sortedWithValidSort &&
          other.sortedWithCurrentBestSort == this.sortedWithCurrentBestSort &&
          other.bestSortPossibleFound == this.bestSortPossibleFound &&
          other.sortInProgress == this.sortInProgress &&
          other.toApplyNextBestSort == this.toApplyNextBestSort &&
          other.toAlwaysApplyCurrentBestSort ==
              this.toAlwaysApplyCurrentBestSort &&
          other.analysisDone == this.analysisDone);
}

class SheetDataTablesCompanion extends UpdateCompanion<SheetDataEntity> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> lastOpened;
  final Value<List<int>> usedRows;
  final Value<List<int>> usedCols;
  final Value<int> historyIndex;
  final Value<double> colHeaderHeight;
  final Value<double> rowHeaderWidth;
  final Value<List<CellPosition>> primSelHistory;
  final Value<int> primSelHistoryId;
  final Value<double> scrollOffsetX;
  final Value<double> scrollOffsetY;
  final Value<Set<CellPosition>> selectedCells;
  final Value<List<int>> bestSortFound;
  final Value<List<int>> bestDistFound;
  final Value<List<int>> cursors;
  final Value<List<List<int>>> possibleInts;
  final Value<List<List<List<int>>>> validAreas;
  final Value<int> sortIndex;
  final Value<AnalysisResult> analysisResult;
  final Value<bool> validSortIsImpossible;
  final Value<bool> isFindingBestSort;
  final Value<bool> sortedWithValidSort;
  final Value<bool> sortedWithCurrentBestSort;
  final Value<bool> bestSortPossibleFound;
  final Value<bool> sortInProgress;
  final Value<bool> toApplyNextBestSort;
  final Value<bool> toAlwaysApplyCurrentBestSort;
  final Value<bool> analysisDone;
  const SheetDataTablesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.lastOpened = const Value.absent(),
    this.usedRows = const Value.absent(),
    this.usedCols = const Value.absent(),
    this.historyIndex = const Value.absent(),
    this.colHeaderHeight = const Value.absent(),
    this.rowHeaderWidth = const Value.absent(),
    this.primSelHistory = const Value.absent(),
    this.primSelHistoryId = const Value.absent(),
    this.scrollOffsetX = const Value.absent(),
    this.scrollOffsetY = const Value.absent(),
    this.selectedCells = const Value.absent(),
    this.bestSortFound = const Value.absent(),
    this.bestDistFound = const Value.absent(),
    this.cursors = const Value.absent(),
    this.possibleInts = const Value.absent(),
    this.validAreas = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.analysisResult = const Value.absent(),
    this.validSortIsImpossible = const Value.absent(),
    this.isFindingBestSort = const Value.absent(),
    this.sortedWithValidSort = const Value.absent(),
    this.sortedWithCurrentBestSort = const Value.absent(),
    this.bestSortPossibleFound = const Value.absent(),
    this.sortInProgress = const Value.absent(),
    this.toApplyNextBestSort = const Value.absent(),
    this.toAlwaysApplyCurrentBestSort = const Value.absent(),
    this.analysisDone = const Value.absent(),
  });
  SheetDataTablesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime lastOpened,
    required List<int> usedRows,
    required List<int> usedCols,
    required int historyIndex,
    required double colHeaderHeight,
    required double rowHeaderWidth,
    required List<CellPosition> primSelHistory,
    required int primSelHistoryId,
    required double scrollOffsetX,
    required double scrollOffsetY,
    required Set<CellPosition> selectedCells,
    required List<int> bestSortFound,
    required List<int> bestDistFound,
    required List<int> cursors,
    required List<List<int>> possibleInts,
    required List<List<List<int>>> validAreas,
    required int sortIndex,
    required AnalysisResult analysisResult,
    required bool validSortIsImpossible,
    required bool isFindingBestSort,
    required bool sortedWithValidSort,
    required bool sortedWithCurrentBestSort,
    required bool bestSortPossibleFound,
    required bool sortInProgress,
    required bool toApplyNextBestSort,
    required bool toAlwaysApplyCurrentBestSort,
    required bool analysisDone,
  }) : title = Value(title),
       lastOpened = Value(lastOpened),
       usedRows = Value(usedRows),
       usedCols = Value(usedCols),
       historyIndex = Value(historyIndex),
       colHeaderHeight = Value(colHeaderHeight),
       rowHeaderWidth = Value(rowHeaderWidth),
       primSelHistory = Value(primSelHistory),
       primSelHistoryId = Value(primSelHistoryId),
       scrollOffsetX = Value(scrollOffsetX),
       scrollOffsetY = Value(scrollOffsetY),
       selectedCells = Value(selectedCells),
       bestSortFound = Value(bestSortFound),
       bestDistFound = Value(bestDistFound),
       cursors = Value(cursors),
       possibleInts = Value(possibleInts),
       validAreas = Value(validAreas),
       sortIndex = Value(sortIndex),
       analysisResult = Value(analysisResult),
       validSortIsImpossible = Value(validSortIsImpossible),
       isFindingBestSort = Value(isFindingBestSort),
       sortedWithValidSort = Value(sortedWithValidSort),
       sortedWithCurrentBestSort = Value(sortedWithCurrentBestSort),
       bestSortPossibleFound = Value(bestSortPossibleFound),
       sortInProgress = Value(sortInProgress),
       toApplyNextBestSort = Value(toApplyNextBestSort),
       toAlwaysApplyCurrentBestSort = Value(toAlwaysApplyCurrentBestSort),
       analysisDone = Value(analysisDone);
  static Insertable<SheetDataEntity> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? lastOpened,
    Expression<String>? usedRows,
    Expression<String>? usedCols,
    Expression<int>? historyIndex,
    Expression<double>? colHeaderHeight,
    Expression<double>? rowHeaderWidth,
    Expression<String>? primSelHistory,
    Expression<int>? primSelHistoryId,
    Expression<double>? scrollOffsetX,
    Expression<double>? scrollOffsetY,
    Expression<String>? selectedCells,
    Expression<String>? bestSortFound,
    Expression<String>? bestDistFound,
    Expression<String>? cursors,
    Expression<String>? possibleInts,
    Expression<String>? validAreas,
    Expression<int>? sortIndex,
    Expression<String>? analysisResult,
    Expression<bool>? validSortIsImpossible,
    Expression<bool>? isFindingBestSort,
    Expression<bool>? sortedWithValidSort,
    Expression<bool>? sortedWithCurrentBestSort,
    Expression<bool>? bestSortPossibleFound,
    Expression<bool>? sortInProgress,
    Expression<bool>? toApplyNextBestSort,
    Expression<bool>? toAlwaysApplyCurrentBestSort,
    Expression<bool>? analysisDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (lastOpened != null) 'last_opened': lastOpened,
      if (usedRows != null) 'used_rows': usedRows,
      if (usedCols != null) 'used_cols': usedCols,
      if (historyIndex != null) 'history_index': historyIndex,
      if (colHeaderHeight != null) 'col_header_height': colHeaderHeight,
      if (rowHeaderWidth != null) 'row_header_width': rowHeaderWidth,
      if (primSelHistory != null) 'prim_sel_history': primSelHistory,
      if (primSelHistoryId != null) 'prim_sel_history_id': primSelHistoryId,
      if (scrollOffsetX != null) 'scroll_offset_x': scrollOffsetX,
      if (scrollOffsetY != null) 'scroll_offset_y': scrollOffsetY,
      if (selectedCells != null) 'selected_cells': selectedCells,
      if (bestSortFound != null) 'best_sort_found': bestSortFound,
      if (bestDistFound != null) 'best_dist_found': bestDistFound,
      if (cursors != null) 'cursors': cursors,
      if (possibleInts != null) 'possible_ints': possibleInts,
      if (validAreas != null) 'valid_areas': validAreas,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (analysisResult != null) 'analysis_result': analysisResult,
      if (validSortIsImpossible != null)
        'valid_sort_is_impossible': validSortIsImpossible,
      if (isFindingBestSort != null) 'is_finding_best_sort': isFindingBestSort,
      if (sortedWithValidSort != null)
        'sorted_with_valid_sort': sortedWithValidSort,
      if (sortedWithCurrentBestSort != null)
        'sorted_with_current_best_sort': sortedWithCurrentBestSort,
      if (bestSortPossibleFound != null)
        'best_sort_possible_found': bestSortPossibleFound,
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
    Value<String>? title,
    Value<DateTime>? lastOpened,
    Value<List<int>>? usedRows,
    Value<List<int>>? usedCols,
    Value<int>? historyIndex,
    Value<double>? colHeaderHeight,
    Value<double>? rowHeaderWidth,
    Value<List<CellPosition>>? primSelHistory,
    Value<int>? primSelHistoryId,
    Value<double>? scrollOffsetX,
    Value<double>? scrollOffsetY,
    Value<Set<CellPosition>>? selectedCells,
    Value<List<int>>? bestSortFound,
    Value<List<int>>? bestDistFound,
    Value<List<int>>? cursors,
    Value<List<List<int>>>? possibleInts,
    Value<List<List<List<int>>>>? validAreas,
    Value<int>? sortIndex,
    Value<AnalysisResult>? analysisResult,
    Value<bool>? validSortIsImpossible,
    Value<bool>? isFindingBestSort,
    Value<bool>? sortedWithValidSort,
    Value<bool>? sortedWithCurrentBestSort,
    Value<bool>? bestSortPossibleFound,
    Value<bool>? sortInProgress,
    Value<bool>? toApplyNextBestSort,
    Value<bool>? toAlwaysApplyCurrentBestSort,
    Value<bool>? analysisDone,
  }) {
    return SheetDataTablesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      lastOpened: lastOpened ?? this.lastOpened,
      usedRows: usedRows ?? this.usedRows,
      usedCols: usedCols ?? this.usedCols,
      historyIndex: historyIndex ?? this.historyIndex,
      colHeaderHeight: colHeaderHeight ?? this.colHeaderHeight,
      rowHeaderWidth: rowHeaderWidth ?? this.rowHeaderWidth,
      primSelHistory: primSelHistory ?? this.primSelHistory,
      primSelHistoryId: primSelHistoryId ?? this.primSelHistoryId,
      scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
      scrollOffsetY: scrollOffsetY ?? this.scrollOffsetY,
      selectedCells: selectedCells ?? this.selectedCells,
      bestSortFound: bestSortFound ?? this.bestSortFound,
      bestDistFound: bestDistFound ?? this.bestDistFound,
      cursors: cursors ?? this.cursors,
      possibleInts: possibleInts ?? this.possibleInts,
      validAreas: validAreas ?? this.validAreas,
      sortIndex: sortIndex ?? this.sortIndex,
      analysisResult: analysisResult ?? this.analysisResult,
      validSortIsImpossible:
          validSortIsImpossible ?? this.validSortIsImpossible,
      isFindingBestSort: isFindingBestSort ?? this.isFindingBestSort,
      sortedWithValidSort: sortedWithValidSort ?? this.sortedWithValidSort,
      sortedWithCurrentBestSort:
          sortedWithCurrentBestSort ?? this.sortedWithCurrentBestSort,
      bestSortPossibleFound:
          bestSortPossibleFound ?? this.bestSortPossibleFound,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastOpened.present) {
      map['last_opened'] = Variable<DateTime>(lastOpened.value);
    }
    if (usedRows.present) {
      map['used_rows'] = Variable<String>(
        $SheetDataTablesTable.$converterusedRows.toSql(usedRows.value),
      );
    }
    if (usedCols.present) {
      map['used_cols'] = Variable<String>(
        $SheetDataTablesTable.$converterusedCols.toSql(usedCols.value),
      );
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
    if (primSelHistory.present) {
      map['prim_sel_history'] = Variable<String>(
        $SheetDataTablesTable.$converterprimSelHistory.toSql(
          primSelHistory.value,
        ),
      );
    }
    if (primSelHistoryId.present) {
      map['prim_sel_history_id'] = Variable<int>(primSelHistoryId.value);
    }
    if (scrollOffsetX.present) {
      map['scroll_offset_x'] = Variable<double>(scrollOffsetX.value);
    }
    if (scrollOffsetY.present) {
      map['scroll_offset_y'] = Variable<double>(scrollOffsetY.value);
    }
    if (selectedCells.present) {
      map['selected_cells'] = Variable<String>(
        $SheetDataTablesTable.$converterselectedCells.toSql(
          selectedCells.value,
        ),
      );
    }
    if (bestSortFound.present) {
      map['best_sort_found'] = Variable<String>(
        $SheetDataTablesTable.$converterbestSortFound.toSql(
          bestSortFound.value,
        ),
      );
    }
    if (bestDistFound.present) {
      map['best_dist_found'] = Variable<String>(
        $SheetDataTablesTable.$converterbestDistFound.toSql(
          bestDistFound.value,
        ),
      );
    }
    if (cursors.present) {
      map['cursors'] = Variable<String>(
        $SheetDataTablesTable.$convertercursors.toSql(cursors.value),
      );
    }
    if (possibleInts.present) {
      map['possible_ints'] = Variable<String>(
        $SheetDataTablesTable.$converterpossibleInts.toSql(possibleInts.value),
      );
    }
    if (validAreas.present) {
      map['valid_areas'] = Variable<String>(
        $SheetDataTablesTable.$convertervalidAreas.toSql(validAreas.value),
      );
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
    if (validSortIsImpossible.present) {
      map['valid_sort_is_impossible'] = Variable<bool>(
        validSortIsImpossible.value,
      );
    }
    if (isFindingBestSort.present) {
      map['is_finding_best_sort'] = Variable<bool>(isFindingBestSort.value);
    }
    if (sortedWithValidSort.present) {
      map['sorted_with_valid_sort'] = Variable<bool>(sortedWithValidSort.value);
    }
    if (sortedWithCurrentBestSort.present) {
      map['sorted_with_current_best_sort'] = Variable<bool>(
        sortedWithCurrentBestSort.value,
      );
    }
    if (bestSortPossibleFound.present) {
      map['best_sort_possible_found'] = Variable<bool>(
        bestSortPossibleFound.value,
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
          ..write('title: $title, ')
          ..write('lastOpened: $lastOpened, ')
          ..write('usedRows: $usedRows, ')
          ..write('usedCols: $usedCols, ')
          ..write('historyIndex: $historyIndex, ')
          ..write('colHeaderHeight: $colHeaderHeight, ')
          ..write('rowHeaderWidth: $rowHeaderWidth, ')
          ..write('primSelHistory: $primSelHistory, ')
          ..write('primSelHistoryId: $primSelHistoryId, ')
          ..write('scrollOffsetX: $scrollOffsetX, ')
          ..write('scrollOffsetY: $scrollOffsetY, ')
          ..write('selectedCells: $selectedCells, ')
          ..write('bestSortFound: $bestSortFound, ')
          ..write('bestDistFound: $bestDistFound, ')
          ..write('cursors: $cursors, ')
          ..write('possibleInts: $possibleInts, ')
          ..write('validAreas: $validAreas, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('analysisResult: $analysisResult, ')
          ..write('validSortIsImpossible: $validSortIsImpossible, ')
          ..write('isFindingBestSort: $isFindingBestSort, ')
          ..write('sortedWithValidSort: $sortedWithValidSort, ')
          ..write('sortedWithCurrentBestSort: $sortedWithCurrentBestSort, ')
          ..write('bestSortPossibleFound: $bestSortPossibleFound, ')
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

class $SheetCellsTableTable extends SheetCellsTable
    with TableInfo<$SheetCellsTableTable, SheetCellEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetCellsTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'sheet_cells_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetCellEntity> instance, {
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
  SheetCellEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetCellEntity(
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
  $SheetCellsTableTable createAlias(String alias) {
    return $SheetCellsTableTable(attachedDatabase, alias);
  }
}

class SheetCellEntity extends DataClass implements Insertable<SheetCellEntity> {
  final int sheetId;
  final int row;
  final int col;
  final String content;
  const SheetCellEntity({
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

  SheetCellsTableCompanion toCompanion(bool nullToAbsent) {
    return SheetCellsTableCompanion(
      sheetId: Value(sheetId),
      row: Value(row),
      col: Value(col),
      content: Value(content),
    );
  }

  factory SheetCellEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetCellEntity(
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

  SheetCellEntity copyWith({
    int? sheetId,
    int? row,
    int? col,
    String? content,
  }) => SheetCellEntity(
    sheetId: sheetId ?? this.sheetId,
    row: row ?? this.row,
    col: col ?? this.col,
    content: content ?? this.content,
  );
  SheetCellEntity copyWithCompanion(SheetCellsTableCompanion data) {
    return SheetCellEntity(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      row: data.row.present ? data.row.value : this.row,
      col: data.col.present ? data.col.value : this.col,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SheetCellEntity(')
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
      (other is SheetCellEntity &&
          other.sheetId == this.sheetId &&
          other.row == this.row &&
          other.col == this.col &&
          other.content == this.content);
}

class SheetCellsTableCompanion extends UpdateCompanion<SheetCellEntity> {
  final Value<int> sheetId;
  final Value<int> row;
  final Value<int> col;
  final Value<String> content;
  final Value<int> rowid;
  const SheetCellsTableCompanion({
    this.sheetId = const Value.absent(),
    this.row = const Value.absent(),
    this.col = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SheetCellsTableCompanion.insert({
    required int sheetId,
    required int row,
    required int col,
    required String content,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       row = Value(row),
       col = Value(col),
       content = Value(content);
  static Insertable<SheetCellEntity> custom({
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

  SheetCellsTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? row,
    Value<int>? col,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return SheetCellsTableCompanion(
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
    return (StringBuffer('SheetCellsTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('row: $row, ')
          ..write('col: $col, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SheetColumnTypesTableTable extends SheetColumnTypesTable
    with TableInfo<$SheetColumnTypesTableTable, SheetColumnTypeEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetColumnTypesTableTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<ColumnType>(
        $SheetColumnTypesTableTable.$convertercolumnType,
      );
  @override
  List<GeneratedColumn> get $columns => [sheetId, columnIndex, columnType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheet_column_types_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetColumnTypeEntity> instance, {
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
  SheetColumnTypeEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetColumnTypeEntity(
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      columnIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}column_index'],
      )!,
      columnType: $SheetColumnTypesTableTable.$convertercolumnType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}column_type'],
        )!,
      ),
    );
  }

  @override
  $SheetColumnTypesTableTable createAlias(String alias) {
    return $SheetColumnTypesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ColumnType, int, int> $convertercolumnType =
      const EnumIndexConverter<ColumnType>(ColumnType.values);
}

class SheetColumnTypeEntity extends DataClass
    implements Insertable<SheetColumnTypeEntity> {
  final int sheetId;
  final int columnIndex;
  final ColumnType columnType;
  const SheetColumnTypeEntity({
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
        $SheetColumnTypesTableTable.$convertercolumnType.toSql(columnType),
      );
    }
    return map;
  }

  SheetColumnTypesTableCompanion toCompanion(bool nullToAbsent) {
    return SheetColumnTypesTableCompanion(
      sheetId: Value(sheetId),
      columnIndex: Value(columnIndex),
      columnType: Value(columnType),
    );
  }

  factory SheetColumnTypeEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetColumnTypeEntity(
      sheetId: serializer.fromJson<int>(json['sheetId']),
      columnIndex: serializer.fromJson<int>(json['columnIndex']),
      columnType: $SheetColumnTypesTableTable.$convertercolumnType.fromJson(
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
        $SheetColumnTypesTableTable.$convertercolumnType.toJson(columnType),
      ),
    };
  }

  SheetColumnTypeEntity copyWith({
    int? sheetId,
    int? columnIndex,
    ColumnType? columnType,
  }) => SheetColumnTypeEntity(
    sheetId: sheetId ?? this.sheetId,
    columnIndex: columnIndex ?? this.columnIndex,
    columnType: columnType ?? this.columnType,
  );
  SheetColumnTypeEntity copyWithCompanion(SheetColumnTypesTableCompanion data) {
    return SheetColumnTypeEntity(
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
    return (StringBuffer('SheetColumnTypeEntity(')
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
      (other is SheetColumnTypeEntity &&
          other.sheetId == this.sheetId &&
          other.columnIndex == this.columnIndex &&
          other.columnType == this.columnType);
}

class SheetColumnTypesTableCompanion
    extends UpdateCompanion<SheetColumnTypeEntity> {
  final Value<int> sheetId;
  final Value<int> columnIndex;
  final Value<ColumnType> columnType;
  final Value<int> rowid;
  const SheetColumnTypesTableCompanion({
    this.sheetId = const Value.absent(),
    this.columnIndex = const Value.absent(),
    this.columnType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SheetColumnTypesTableCompanion.insert({
    required int sheetId,
    required int columnIndex,
    required ColumnType columnType,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       columnIndex = Value(columnIndex),
       columnType = Value(columnType);
  static Insertable<SheetColumnTypeEntity> custom({
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

  SheetColumnTypesTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? columnIndex,
    Value<ColumnType>? columnType,
    Value<int>? rowid,
  }) {
    return SheetColumnTypesTableCompanion(
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
        $SheetColumnTypesTableTable.$convertercolumnType.toSql(
          columnType.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetColumnTypesTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('columnIndex: $columnIndex, ')
          ..write('columnType: $columnType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UpdateHistoriesTableTable extends UpdateHistoriesTable
    with TableInfo<$UpdateHistoriesTableTable, UpdateHistoriesEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpdateHistoriesTableTable(this.attachedDatabase, [this._alias]);
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
        $UpdateHistoriesTableTable.$converterupdates,
      );
  @override
  List<GeneratedColumn> get $columns => [timestamp, chronoId, sheetId, updates];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'update_histories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpdateHistoriesEntity> instance, {
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
  UpdateHistoriesEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpdateHistoriesEntity(
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
      updates: $UpdateHistoriesTableTable.$converterupdates.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updates'],
        )!,
      ),
    );
  }

  @override
  $UpdateHistoriesTableTable createAlias(String alias) {
    return $UpdateHistoriesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, UpdateUnit>, String> $converterupdates =
      const UpdateUnitMapConverter();
}

class UpdateHistoriesEntity extends DataClass
    implements Insertable<UpdateHistoriesEntity> {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final Map<String, UpdateUnit> updates;
  const UpdateHistoriesEntity({
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
        $UpdateHistoriesTableTable.$converterupdates.toSql(updates),
      );
    }
    return map;
  }

  UpdateHistoriesTableCompanion toCompanion(bool nullToAbsent) {
    return UpdateHistoriesTableCompanion(
      timestamp: Value(timestamp),
      chronoId: Value(chronoId),
      sheetId: Value(sheetId),
      updates: Value(updates),
    );
  }

  factory UpdateHistoriesEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpdateHistoriesEntity(
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

  UpdateHistoriesEntity copyWith({
    DateTime? timestamp,
    int? chronoId,
    int? sheetId,
    Map<String, UpdateUnit>? updates,
  }) => UpdateHistoriesEntity(
    timestamp: timestamp ?? this.timestamp,
    chronoId: chronoId ?? this.chronoId,
    sheetId: sheetId ?? this.sheetId,
    updates: updates ?? this.updates,
  );
  UpdateHistoriesEntity copyWithCompanion(UpdateHistoriesTableCompanion data) {
    return UpdateHistoriesEntity(
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      chronoId: data.chronoId.present ? data.chronoId.value : this.chronoId,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      updates: data.updates.present ? data.updates.value : this.updates,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistoriesEntity(')
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
      (other is UpdateHistoriesEntity &&
          other.timestamp == this.timestamp &&
          other.chronoId == this.chronoId &&
          other.sheetId == this.sheetId &&
          other.updates == this.updates);
}

class UpdateHistoriesTableCompanion
    extends UpdateCompanion<UpdateHistoriesEntity> {
  final Value<DateTime> timestamp;
  final Value<int> chronoId;
  final Value<int> sheetId;
  final Value<Map<String, UpdateUnit>> updates;
  final Value<int> rowid;
  const UpdateHistoriesTableCompanion({
    this.timestamp = const Value.absent(),
    this.chronoId = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.updates = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UpdateHistoriesTableCompanion.insert({
    required DateTime timestamp,
    required int chronoId,
    required int sheetId,
    required Map<String, UpdateUnit> updates,
    this.rowid = const Value.absent(),
  }) : timestamp = Value(timestamp),
       chronoId = Value(chronoId),
       sheetId = Value(sheetId),
       updates = Value(updates);
  static Insertable<UpdateHistoriesEntity> custom({
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

  UpdateHistoriesTableCompanion copyWith({
    Value<DateTime>? timestamp,
    Value<int>? chronoId,
    Value<int>? sheetId,
    Value<Map<String, UpdateUnit>>? updates,
    Value<int>? rowid,
  }) {
    return UpdateHistoriesTableCompanion(
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
        $UpdateHistoriesTableTable.$converterupdates.toSql(updates.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpdateHistoriesTableCompanion(')
          ..write('timestamp: $timestamp, ')
          ..write('chronoId: $chronoId, ')
          ..write('sheetId: $sheetId, ')
          ..write('updates: $updates, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RowsBottomPosTableTable extends RowsBottomPosTable
    with TableInfo<$RowsBottomPosTableTable, RowsBottomPosEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RowsBottomPosTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'rows_bottom_pos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RowsBottomPosEntity> instance, {
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
  RowsBottomPosEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RowsBottomPosEntity(
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
  $RowsBottomPosTableTable createAlias(String alias) {
    return $RowsBottomPosTableTable(attachedDatabase, alias);
  }
}

class RowsBottomPosEntity extends DataClass
    implements Insertable<RowsBottomPosEntity> {
  final int sheetId;
  final int rowIndex;
  final double bottomPos;
  const RowsBottomPosEntity({
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

  RowsBottomPosTableCompanion toCompanion(bool nullToAbsent) {
    return RowsBottomPosTableCompanion(
      sheetId: Value(sheetId),
      rowIndex: Value(rowIndex),
      bottomPos: Value(bottomPos),
    );
  }

  factory RowsBottomPosEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RowsBottomPosEntity(
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

  RowsBottomPosEntity copyWith({
    int? sheetId,
    int? rowIndex,
    double? bottomPos,
  }) => RowsBottomPosEntity(
    sheetId: sheetId ?? this.sheetId,
    rowIndex: rowIndex ?? this.rowIndex,
    bottomPos: bottomPos ?? this.bottomPos,
  );
  RowsBottomPosEntity copyWithCompanion(RowsBottomPosTableCompanion data) {
    return RowsBottomPosEntity(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      bottomPos: data.bottomPos.present ? data.bottomPos.value : this.bottomPos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RowsBottomPosEntity(')
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
      (other is RowsBottomPosEntity &&
          other.sheetId == this.sheetId &&
          other.rowIndex == this.rowIndex &&
          other.bottomPos == this.bottomPos);
}

class RowsBottomPosTableCompanion extends UpdateCompanion<RowsBottomPosEntity> {
  final Value<int> sheetId;
  final Value<int> rowIndex;
  final Value<double> bottomPos;
  final Value<int> rowid;
  const RowsBottomPosTableCompanion({
    this.sheetId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.bottomPos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RowsBottomPosTableCompanion.insert({
    required int sheetId,
    required int rowIndex,
    required double bottomPos,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       rowIndex = Value(rowIndex),
       bottomPos = Value(bottomPos);
  static Insertable<RowsBottomPosEntity> custom({
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

  RowsBottomPosTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? rowIndex,
    Value<double>? bottomPos,
    Value<int>? rowid,
  }) {
    return RowsBottomPosTableCompanion(
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
    return (StringBuffer('RowsBottomPosTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('bottomPos: $bottomPos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColRightPosTableTable extends ColRightPosTable
    with TableInfo<$ColRightPosTableTable, ColRightPosEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColRightPosTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'col_right_pos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColRightPosEntity> instance, {
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
  ColRightPosEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColRightPosEntity(
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
  $ColRightPosTableTable createAlias(String alias) {
    return $ColRightPosTableTable(attachedDatabase, alias);
  }
}

class ColRightPosEntity extends DataClass
    implements Insertable<ColRightPosEntity> {
  final int sheetId;
  final int colIndex;
  final double rightPos;
  const ColRightPosEntity({
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

  ColRightPosTableCompanion toCompanion(bool nullToAbsent) {
    return ColRightPosTableCompanion(
      sheetId: Value(sheetId),
      colIndex: Value(colIndex),
      rightPos: Value(rightPos),
    );
  }

  factory ColRightPosEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColRightPosEntity(
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

  ColRightPosEntity copyWith({int? sheetId, int? colIndex, double? rightPos}) =>
      ColRightPosEntity(
        sheetId: sheetId ?? this.sheetId,
        colIndex: colIndex ?? this.colIndex,
        rightPos: rightPos ?? this.rightPos,
      );
  ColRightPosEntity copyWithCompanion(ColRightPosTableCompanion data) {
    return ColRightPosEntity(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      colIndex: data.colIndex.present ? data.colIndex.value : this.colIndex,
      rightPos: data.rightPos.present ? data.rightPos.value : this.rightPos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColRightPosEntity(')
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
      (other is ColRightPosEntity &&
          other.sheetId == this.sheetId &&
          other.colIndex == this.colIndex &&
          other.rightPos == this.rightPos);
}

class ColRightPosTableCompanion extends UpdateCompanion<ColRightPosEntity> {
  final Value<int> sheetId;
  final Value<int> colIndex;
  final Value<double> rightPos;
  final Value<int> rowid;
  const ColRightPosTableCompanion({
    this.sheetId = const Value.absent(),
    this.colIndex = const Value.absent(),
    this.rightPos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColRightPosTableCompanion.insert({
    required int sheetId,
    required int colIndex,
    required double rightPos,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       colIndex = Value(colIndex),
       rightPos = Value(rightPos);
  static Insertable<ColRightPosEntity> custom({
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

  ColRightPosTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? colIndex,
    Value<double>? rightPos,
    Value<int>? rowid,
  }) {
    return ColRightPosTableCompanion(
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
    return (StringBuffer('ColRightPosTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('rightPos: $rightPos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RowsManuallyAdjustedHeightTableTable
    extends RowsManuallyAdjustedHeightTable
    with
        TableInfo<
          $RowsManuallyAdjustedHeightTableTable,
          RowsManuallyAdjustedHeightEntity
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RowsManuallyAdjustedHeightTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'rows_manually_adjusted_height_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RowsManuallyAdjustedHeightEntity> instance, {
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
  RowsManuallyAdjustedHeightEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RowsManuallyAdjustedHeightEntity(
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
  $RowsManuallyAdjustedHeightTableTable createAlias(String alias) {
    return $RowsManuallyAdjustedHeightTableTable(attachedDatabase, alias);
  }
}

class RowsManuallyAdjustedHeightEntity extends DataClass
    implements Insertable<RowsManuallyAdjustedHeightEntity> {
  final int sheetId;
  final int rowIndex;
  final bool manuallyAdjusted;
  const RowsManuallyAdjustedHeightEntity({
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

  RowsManuallyAdjustedHeightTableCompanion toCompanion(bool nullToAbsent) {
    return RowsManuallyAdjustedHeightTableCompanion(
      sheetId: Value(sheetId),
      rowIndex: Value(rowIndex),
      manuallyAdjusted: Value(manuallyAdjusted),
    );
  }

  factory RowsManuallyAdjustedHeightEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RowsManuallyAdjustedHeightEntity(
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

  RowsManuallyAdjustedHeightEntity copyWith({
    int? sheetId,
    int? rowIndex,
    bool? manuallyAdjusted,
  }) => RowsManuallyAdjustedHeightEntity(
    sheetId: sheetId ?? this.sheetId,
    rowIndex: rowIndex ?? this.rowIndex,
    manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
  );
  RowsManuallyAdjustedHeightEntity copyWithCompanion(
    RowsManuallyAdjustedHeightTableCompanion data,
  ) {
    return RowsManuallyAdjustedHeightEntity(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      manuallyAdjusted: data.manuallyAdjusted.present
          ? data.manuallyAdjusted.value
          : this.manuallyAdjusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RowsManuallyAdjustedHeightEntity(')
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
      (other is RowsManuallyAdjustedHeightEntity &&
          other.sheetId == this.sheetId &&
          other.rowIndex == this.rowIndex &&
          other.manuallyAdjusted == this.manuallyAdjusted);
}

class RowsManuallyAdjustedHeightTableCompanion
    extends UpdateCompanion<RowsManuallyAdjustedHeightEntity> {
  final Value<int> sheetId;
  final Value<int> rowIndex;
  final Value<bool> manuallyAdjusted;
  final Value<int> rowid;
  const RowsManuallyAdjustedHeightTableCompanion({
    this.sheetId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.manuallyAdjusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RowsManuallyAdjustedHeightTableCompanion.insert({
    required int sheetId,
    required int rowIndex,
    required bool manuallyAdjusted,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       rowIndex = Value(rowIndex),
       manuallyAdjusted = Value(manuallyAdjusted);
  static Insertable<RowsManuallyAdjustedHeightEntity> custom({
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

  RowsManuallyAdjustedHeightTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? rowIndex,
    Value<bool>? manuallyAdjusted,
    Value<int>? rowid,
  }) {
    return RowsManuallyAdjustedHeightTableCompanion(
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
    return (StringBuffer('RowsManuallyAdjustedHeightTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColsManuallyAdjustedWidthTableTable
    extends ColsManuallyAdjustedWidthTable
    with
        TableInfo<
          $ColsManuallyAdjustedWidthTableTable,
          ColsManuallyAdjustedWidthEntity
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColsManuallyAdjustedWidthTableTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'cols_manually_adjusted_width_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColsManuallyAdjustedWidthEntity> instance, {
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
  ColsManuallyAdjustedWidthEntity map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColsManuallyAdjustedWidthEntity(
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
  $ColsManuallyAdjustedWidthTableTable createAlias(String alias) {
    return $ColsManuallyAdjustedWidthTableTable(attachedDatabase, alias);
  }
}

class ColsManuallyAdjustedWidthEntity extends DataClass
    implements Insertable<ColsManuallyAdjustedWidthEntity> {
  final int sheetId;
  final int colIndex;
  final bool manuallyAdjusted;
  const ColsManuallyAdjustedWidthEntity({
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

  ColsManuallyAdjustedWidthTableCompanion toCompanion(bool nullToAbsent) {
    return ColsManuallyAdjustedWidthTableCompanion(
      sheetId: Value(sheetId),
      colIndex: Value(colIndex),
      manuallyAdjusted: Value(manuallyAdjusted),
    );
  }

  factory ColsManuallyAdjustedWidthEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColsManuallyAdjustedWidthEntity(
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

  ColsManuallyAdjustedWidthEntity copyWith({
    int? sheetId,
    int? colIndex,
    bool? manuallyAdjusted,
  }) => ColsManuallyAdjustedWidthEntity(
    sheetId: sheetId ?? this.sheetId,
    colIndex: colIndex ?? this.colIndex,
    manuallyAdjusted: manuallyAdjusted ?? this.manuallyAdjusted,
  );
  ColsManuallyAdjustedWidthEntity copyWithCompanion(
    ColsManuallyAdjustedWidthTableCompanion data,
  ) {
    return ColsManuallyAdjustedWidthEntity(
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      colIndex: data.colIndex.present ? data.colIndex.value : this.colIndex,
      manuallyAdjusted: data.manuallyAdjusted.present
          ? data.manuallyAdjusted.value
          : this.manuallyAdjusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColsManuallyAdjustedWidthEntity(')
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
      (other is ColsManuallyAdjustedWidthEntity &&
          other.sheetId == this.sheetId &&
          other.colIndex == this.colIndex &&
          other.manuallyAdjusted == this.manuallyAdjusted);
}

class ColsManuallyAdjustedWidthTableCompanion
    extends UpdateCompanion<ColsManuallyAdjustedWidthEntity> {
  final Value<int> sheetId;
  final Value<int> colIndex;
  final Value<bool> manuallyAdjusted;
  final Value<int> rowid;
  const ColsManuallyAdjustedWidthTableCompanion({
    this.sheetId = const Value.absent(),
    this.colIndex = const Value.absent(),
    this.manuallyAdjusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColsManuallyAdjustedWidthTableCompanion.insert({
    required int sheetId,
    required int colIndex,
    required bool manuallyAdjusted,
    this.rowid = const Value.absent(),
  }) : sheetId = Value(sheetId),
       colIndex = Value(colIndex),
       manuallyAdjusted = Value(manuallyAdjusted);
  static Insertable<ColsManuallyAdjustedWidthEntity> custom({
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

  ColsManuallyAdjustedWidthTableCompanion copyWith({
    Value<int>? sheetId,
    Value<int>? colIndex,
    Value<bool>? manuallyAdjusted,
    Value<int>? rowid,
  }) {
    return ColsManuallyAdjustedWidthTableCompanion(
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
    return (StringBuffer('ColsManuallyAdjustedWidthTableCompanion(')
          ..write('sheetId: $sheetId, ')
          ..write('colIndex: $colIndex, ')
          ..write('manuallyAdjusted: $manuallyAdjusted, ')
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
  late final $SheetCellsTableTable sheetCellsTable = $SheetCellsTableTable(
    this,
  );
  late final $SheetColumnTypesTableTable sheetColumnTypesTable =
      $SheetColumnTypesTableTable(this);
  late final $UpdateHistoriesTableTable updateHistoriesTable =
      $UpdateHistoriesTableTable(this);
  late final $RowsBottomPosTableTable rowsBottomPosTable =
      $RowsBottomPosTableTable(this);
  late final $ColRightPosTableTable colRightPosTable = $ColRightPosTableTable(
    this,
  );
  late final $RowsManuallyAdjustedHeightTableTable
  rowsManuallyAdjustedHeightTable = $RowsManuallyAdjustedHeightTableTable(this);
  late final $ColsManuallyAdjustedWidthTableTable
  colsManuallyAdjustedWidthTable = $ColsManuallyAdjustedWidthTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sheetDataTables,
    sheetCellsTable,
    sheetColumnTypesTable,
    updateHistoriesTable,
    rowsBottomPosTable,
    colRightPosTable,
    rowsManuallyAdjustedHeightTable,
    colsManuallyAdjustedWidthTable,
  ];
}

typedef $$SheetDataTablesTableCreateCompanionBuilder =
    SheetDataTablesCompanion Function({
      Value<int> id,
      required String title,
      required DateTime lastOpened,
      required List<int> usedRows,
      required List<int> usedCols,
      required int historyIndex,
      required double colHeaderHeight,
      required double rowHeaderWidth,
      required List<CellPosition> primSelHistory,
      required int primSelHistoryId,
      required double scrollOffsetX,
      required double scrollOffsetY,
      required Set<CellPosition> selectedCells,
      required List<int> bestSortFound,
      required List<int> bestDistFound,
      required List<int> cursors,
      required List<List<int>> possibleInts,
      required List<List<List<int>>> validAreas,
      required int sortIndex,
      required AnalysisResult analysisResult,
      required bool validSortIsImpossible,
      required bool isFindingBestSort,
      required bool sortedWithValidSort,
      required bool sortedWithCurrentBestSort,
      required bool bestSortPossibleFound,
      required bool sortInProgress,
      required bool toApplyNextBestSort,
      required bool toAlwaysApplyCurrentBestSort,
      required bool analysisDone,
    });
typedef $$SheetDataTablesTableUpdateCompanionBuilder =
    SheetDataTablesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> lastOpened,
      Value<List<int>> usedRows,
      Value<List<int>> usedCols,
      Value<int> historyIndex,
      Value<double> colHeaderHeight,
      Value<double> rowHeaderWidth,
      Value<List<CellPosition>> primSelHistory,
      Value<int> primSelHistoryId,
      Value<double> scrollOffsetX,
      Value<double> scrollOffsetY,
      Value<Set<CellPosition>> selectedCells,
      Value<List<int>> bestSortFound,
      Value<List<int>> bestDistFound,
      Value<List<int>> cursors,
      Value<List<List<int>>> possibleInts,
      Value<List<List<List<int>>>> validAreas,
      Value<int> sortIndex,
      Value<AnalysisResult> analysisResult,
      Value<bool> validSortIsImpossible,
      Value<bool> isFindingBestSort,
      Value<bool> sortedWithValidSort,
      Value<bool> sortedWithCurrentBestSort,
      Value<bool> bestSortPossibleFound,
      Value<bool> sortInProgress,
      Value<bool> toApplyNextBestSort,
      Value<bool> toAlwaysApplyCurrentBestSort,
      Value<bool> analysisDone,
    });

final class $$SheetDataTablesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SheetDataTablesTable, SheetDataEntity> {
  $$SheetDataTablesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SheetCellsTableTable, List<SheetCellEntity>>
  _sheetCellsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sheetCellsTable,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.sheetCellsTable.sheetId,
    ),
  );

  $$SheetCellsTableTableProcessedTableManager get sheetCellsTableRefs {
    final manager = $$SheetCellsTableTableTableManager(
      $_db,
      $_db.sheetCellsTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sheetCellsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SheetColumnTypesTableTable,
    List<SheetColumnTypeEntity>
  >
  _sheetColumnTypesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sheetColumnTypesTable,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.sheetColumnTypesTable.sheetId,
        ),
      );

  $$SheetColumnTypesTableTableProcessedTableManager
  get sheetColumnTypesTableRefs {
    final manager = $$SheetColumnTypesTableTableTableManager(
      $_db,
      $_db.sheetColumnTypesTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sheetColumnTypesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $UpdateHistoriesTableTable,
    List<UpdateHistoriesEntity>
  >
  _updateHistoriesTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.updateHistoriesTable,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.updateHistoriesTable.sheetId,
        ),
      );

  $$UpdateHistoriesTableTableProcessedTableManager
  get updateHistoriesTableRefs {
    final manager = $$UpdateHistoriesTableTableTableManager(
      $_db,
      $_db.updateHistoriesTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _updateHistoriesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RowsBottomPosTableTable,
    List<RowsBottomPosEntity>
  >
  _rowsBottomPosTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rowsBottomPosTable,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.rowsBottomPosTable.sheetId,
        ),
      );

  $$RowsBottomPosTableTableProcessedTableManager get rowsBottomPosTableRefs {
    final manager = $$RowsBottomPosTableTableTableManager(
      $_db,
      $_db.rowsBottomPosTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rowsBottomPosTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ColRightPosTableTable, List<ColRightPosEntity>>
  _colRightPosTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.colRightPosTable,
    aliasName: $_aliasNameGenerator(
      db.sheetDataTables.id,
      db.colRightPosTable.sheetId,
    ),
  );

  $$ColRightPosTableTableProcessedTableManager get colRightPosTableRefs {
    final manager = $$ColRightPosTableTableTableManager(
      $_db,
      $_db.colRightPosTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _colRightPosTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RowsManuallyAdjustedHeightTableTable,
    List<RowsManuallyAdjustedHeightEntity>
  >
  _rowsManuallyAdjustedHeightTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.rowsManuallyAdjustedHeightTable,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.rowsManuallyAdjustedHeightTable.sheetId,
        ),
      );

  $$RowsManuallyAdjustedHeightTableTableProcessedTableManager
  get rowsManuallyAdjustedHeightTableRefs {
    final manager = $$RowsManuallyAdjustedHeightTableTableTableManager(
      $_db,
      $_db.rowsManuallyAdjustedHeightTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rowsManuallyAdjustedHeightTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ColsManuallyAdjustedWidthTableTable,
    List<ColsManuallyAdjustedWidthEntity>
  >
  _colsManuallyAdjustedWidthTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.colsManuallyAdjustedWidthTable,
        aliasName: $_aliasNameGenerator(
          db.sheetDataTables.id,
          db.colsManuallyAdjustedWidthTable.sheetId,
        ),
      );

  $$ColsManuallyAdjustedWidthTableTableProcessedTableManager
  get colsManuallyAdjustedWidthTableRefs {
    final manager = $$ColsManuallyAdjustedWidthTableTableTableManager(
      $_db,
      $_db.colsManuallyAdjustedWidthTable,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _colsManuallyAdjustedWidthTableRefsTable($_db),
    );
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpened => $composableBuilder(
    column: $table.lastOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get usedRows =>
      $composableBuilder(
        column: $table.usedRows,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get usedCols =>
      $composableBuilder(
        column: $table.usedCols,
        builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnWithTypeConverterFilters<List<CellPosition>, List<CellPosition>, String>
  get primSelHistory => $composableBuilder(
    column: $table.primSelHistory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get primSelHistoryId => $composableBuilder(
    column: $table.primSelHistoryId,
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

  ColumnWithTypeConverterFilters<Set<CellPosition>, Set<CellPosition>, String>
  get selectedCells => $composableBuilder(
    column: $table.selectedCells,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get bestSortFound => $composableBuilder(
    column: $table.bestSortFound,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get bestDistFound => $composableBuilder(
    column: $table.bestDistFound,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get cursors =>
      $composableBuilder(
        column: $table.cursors,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<List<int>>, List<List<int>>, String>
  get possibleInts => $composableBuilder(
    column: $table.possibleInts,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<List<List<int>>>,
    List<List<List<int>>>,
    String
  >
  get validAreas => $composableBuilder(
    column: $table.validAreas,
    builder: (column) => ColumnWithTypeConverterFilters(column),
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

  ColumnFilters<bool> get validSortIsImpossible => $composableBuilder(
    column: $table.validSortIsImpossible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFindingBestSort => $composableBuilder(
    column: $table.isFindingBestSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sortedWithValidSort => $composableBuilder(
    column: $table.sortedWithValidSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sortedWithCurrentBestSort => $composableBuilder(
    column: $table.sortedWithCurrentBestSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bestSortPossibleFound => $composableBuilder(
    column: $table.bestSortPossibleFound,
    builder: (column) => ColumnFilters(column),
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

  Expression<bool> sheetCellsTableRefs(
    Expression<bool> Function($$SheetCellsTableTableFilterComposer f) f,
  ) {
    final $$SheetCellsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetCellsTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetCellsTableTableFilterComposer(
            $db: $db,
            $table: $db.sheetCellsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sheetColumnTypesTableRefs(
    Expression<bool> Function($$SheetColumnTypesTableTableFilterComposer f) f,
  ) {
    final $$SheetColumnTypesTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sheetColumnTypesTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SheetColumnTypesTableTableFilterComposer(
                $db: $db,
                $table: $db.sheetColumnTypesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> updateHistoriesTableRefs(
    Expression<bool> Function($$UpdateHistoriesTableTableFilterComposer f) f,
  ) {
    final $$UpdateHistoriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.updateHistoriesTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpdateHistoriesTableTableFilterComposer(
            $db: $db,
            $table: $db.updateHistoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rowsBottomPosTableRefs(
    Expression<bool> Function($$RowsBottomPosTableTableFilterComposer f) f,
  ) {
    final $$RowsBottomPosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rowsBottomPosTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RowsBottomPosTableTableFilterComposer(
            $db: $db,
            $table: $db.rowsBottomPosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> colRightPosTableRefs(
    Expression<bool> Function($$ColRightPosTableTableFilterComposer f) f,
  ) {
    final $$ColRightPosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.colRightPosTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColRightPosTableTableFilterComposer(
            $db: $db,
            $table: $db.colRightPosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rowsManuallyAdjustedHeightTableRefs(
    Expression<bool> Function(
      $$RowsManuallyAdjustedHeightTableTableFilterComposer f,
    )
    f,
  ) {
    final $$RowsManuallyAdjustedHeightTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rowsManuallyAdjustedHeightTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RowsManuallyAdjustedHeightTableTableFilterComposer(
                $db: $db,
                $table: $db.rowsManuallyAdjustedHeightTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> colsManuallyAdjustedWidthTableRefs(
    Expression<bool> Function(
      $$ColsManuallyAdjustedWidthTableTableFilterComposer f,
    )
    f,
  ) {
    final $$ColsManuallyAdjustedWidthTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.colsManuallyAdjustedWidthTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ColsManuallyAdjustedWidthTableTableFilterComposer(
                $db: $db,
                $table: $db.colsManuallyAdjustedWidthTable,
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpened => $composableBuilder(
    column: $table.lastOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usedRows => $composableBuilder(
    column: $table.usedRows,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usedCols => $composableBuilder(
    column: $table.usedCols,
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

  ColumnOrderings<String> get primSelHistory => $composableBuilder(
    column: $table.primSelHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get primSelHistoryId => $composableBuilder(
    column: $table.primSelHistoryId,
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

  ColumnOrderings<String> get selectedCells => $composableBuilder(
    column: $table.selectedCells,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestSortFound => $composableBuilder(
    column: $table.bestSortFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestDistFound => $composableBuilder(
    column: $table.bestDistFound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursors => $composableBuilder(
    column: $table.cursors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get possibleInts => $composableBuilder(
    column: $table.possibleInts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validAreas => $composableBuilder(
    column: $table.validAreas,
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

  ColumnOrderings<bool> get validSortIsImpossible => $composableBuilder(
    column: $table.validSortIsImpossible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFindingBestSort => $composableBuilder(
    column: $table.isFindingBestSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sortedWithValidSort => $composableBuilder(
    column: $table.sortedWithValidSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sortedWithCurrentBestSort => $composableBuilder(
    column: $table.sortedWithCurrentBestSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bestSortPossibleFound => $composableBuilder(
    column: $table.bestSortPossibleFound,
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpened => $composableBuilder(
    column: $table.lastOpened,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get usedRows =>
      $composableBuilder(column: $table.usedRows, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get usedCols =>
      $composableBuilder(column: $table.usedCols, builder: (column) => column);

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

  GeneratedColumnWithTypeConverter<List<CellPosition>, String>
  get primSelHistory => $composableBuilder(
    column: $table.primSelHistory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get primSelHistoryId => $composableBuilder(
    column: $table.primSelHistoryId,
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

  GeneratedColumnWithTypeConverter<Set<CellPosition>, String>
  get selectedCells => $composableBuilder(
    column: $table.selectedCells,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<int>, String> get bestSortFound =>
      $composableBuilder(
        column: $table.bestSortFound,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<int>, String> get bestDistFound =>
      $composableBuilder(
        column: $table.bestDistFound,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<int>, String> get cursors =>
      $composableBuilder(column: $table.cursors, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<List<int>>, String> get possibleInts =>
      $composableBuilder(
        column: $table.possibleInts,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<List<List<int>>>, String>
  get validAreas => $composableBuilder(
    column: $table.validAreas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AnalysisResult, String> get analysisResult =>
      $composableBuilder(
        column: $table.analysisResult,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get validSortIsImpossible => $composableBuilder(
    column: $table.validSortIsImpossible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFindingBestSort => $composableBuilder(
    column: $table.isFindingBestSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sortedWithValidSort => $composableBuilder(
    column: $table.sortedWithValidSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sortedWithCurrentBestSort => $composableBuilder(
    column: $table.sortedWithCurrentBestSort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bestSortPossibleFound => $composableBuilder(
    column: $table.bestSortPossibleFound,
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

  Expression<T> sheetCellsTableRefs<T extends Object>(
    Expression<T> Function($$SheetCellsTableTableAnnotationComposer a) f,
  ) {
    final $$SheetCellsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sheetCellsTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetCellsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sheetCellsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sheetColumnTypesTableRefs<T extends Object>(
    Expression<T> Function($$SheetColumnTypesTableTableAnnotationComposer a) f,
  ) {
    final $$SheetColumnTypesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sheetColumnTypesTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SheetColumnTypesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.sheetColumnTypesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> updateHistoriesTableRefs<T extends Object>(
    Expression<T> Function($$UpdateHistoriesTableTableAnnotationComposer a) f,
  ) {
    final $$UpdateHistoriesTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.updateHistoriesTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UpdateHistoriesTableTableAnnotationComposer(
                $db: $db,
                $table: $db.updateHistoriesTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> rowsBottomPosTableRefs<T extends Object>(
    Expression<T> Function($$RowsBottomPosTableTableAnnotationComposer a) f,
  ) {
    final $$RowsBottomPosTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rowsBottomPosTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RowsBottomPosTableTableAnnotationComposer(
                $db: $db,
                $table: $db.rowsBottomPosTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> colRightPosTableRefs<T extends Object>(
    Expression<T> Function($$ColRightPosTableTableAnnotationComposer a) f,
  ) {
    final $$ColRightPosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.colRightPosTable,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColRightPosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.colRightPosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rowsManuallyAdjustedHeightTableRefs<T extends Object>(
    Expression<T> Function(
      $$RowsManuallyAdjustedHeightTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RowsManuallyAdjustedHeightTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.rowsManuallyAdjustedHeightTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RowsManuallyAdjustedHeightTableTableAnnotationComposer(
                $db: $db,
                $table: $db.rowsManuallyAdjustedHeightTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> colsManuallyAdjustedWidthTableRefs<T extends Object>(
    Expression<T> Function(
      $$ColsManuallyAdjustedWidthTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ColsManuallyAdjustedWidthTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.colsManuallyAdjustedWidthTable,
          getReferencedColumn: (t) => t.sheetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ColsManuallyAdjustedWidthTableTableAnnotationComposer(
                $db: $db,
                $table: $db.colsManuallyAdjustedWidthTable,
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
          SheetDataEntity,
          $$SheetDataTablesTableFilterComposer,
          $$SheetDataTablesTableOrderingComposer,
          $$SheetDataTablesTableAnnotationComposer,
          $$SheetDataTablesTableCreateCompanionBuilder,
          $$SheetDataTablesTableUpdateCompanionBuilder,
          (SheetDataEntity, $$SheetDataTablesTableReferences),
          SheetDataEntity,
          PrefetchHooks Function({
            bool sheetCellsTableRefs,
            bool sheetColumnTypesTableRefs,
            bool updateHistoriesTableRefs,
            bool rowsBottomPosTableRefs,
            bool colRightPosTableRefs,
            bool rowsManuallyAdjustedHeightTableRefs,
            bool colsManuallyAdjustedWidthTableRefs,
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
                Value<String> title = const Value.absent(),
                Value<DateTime> lastOpened = const Value.absent(),
                Value<List<int>> usedRows = const Value.absent(),
                Value<List<int>> usedCols = const Value.absent(),
                Value<int> historyIndex = const Value.absent(),
                Value<double> colHeaderHeight = const Value.absent(),
                Value<double> rowHeaderWidth = const Value.absent(),
                Value<List<CellPosition>> primSelHistory = const Value.absent(),
                Value<int> primSelHistoryId = const Value.absent(),
                Value<double> scrollOffsetX = const Value.absent(),
                Value<double> scrollOffsetY = const Value.absent(),
                Value<Set<CellPosition>> selectedCells = const Value.absent(),
                Value<List<int>> bestSortFound = const Value.absent(),
                Value<List<int>> bestDistFound = const Value.absent(),
                Value<List<int>> cursors = const Value.absent(),
                Value<List<List<int>>> possibleInts = const Value.absent(),
                Value<List<List<List<int>>>> validAreas = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<AnalysisResult> analysisResult = const Value.absent(),
                Value<bool> validSortIsImpossible = const Value.absent(),
                Value<bool> isFindingBestSort = const Value.absent(),
                Value<bool> sortedWithValidSort = const Value.absent(),
                Value<bool> sortedWithCurrentBestSort = const Value.absent(),
                Value<bool> bestSortPossibleFound = const Value.absent(),
                Value<bool> sortInProgress = const Value.absent(),
                Value<bool> toApplyNextBestSort = const Value.absent(),
                Value<bool> toAlwaysApplyCurrentBestSort = const Value.absent(),
                Value<bool> analysisDone = const Value.absent(),
              }) => SheetDataTablesCompanion(
                id: id,
                title: title,
                lastOpened: lastOpened,
                usedRows: usedRows,
                usedCols: usedCols,
                historyIndex: historyIndex,
                colHeaderHeight: colHeaderHeight,
                rowHeaderWidth: rowHeaderWidth,
                primSelHistory: primSelHistory,
                primSelHistoryId: primSelHistoryId,
                scrollOffsetX: scrollOffsetX,
                scrollOffsetY: scrollOffsetY,
                selectedCells: selectedCells,
                bestSortFound: bestSortFound,
                bestDistFound: bestDistFound,
                cursors: cursors,
                possibleInts: possibleInts,
                validAreas: validAreas,
                sortIndex: sortIndex,
                analysisResult: analysisResult,
                validSortIsImpossible: validSortIsImpossible,
                isFindingBestSort: isFindingBestSort,
                sortedWithValidSort: sortedWithValidSort,
                sortedWithCurrentBestSort: sortedWithCurrentBestSort,
                bestSortPossibleFound: bestSortPossibleFound,
                sortInProgress: sortInProgress,
                toApplyNextBestSort: toApplyNextBestSort,
                toAlwaysApplyCurrentBestSort: toAlwaysApplyCurrentBestSort,
                analysisDone: analysisDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime lastOpened,
                required List<int> usedRows,
                required List<int> usedCols,
                required int historyIndex,
                required double colHeaderHeight,
                required double rowHeaderWidth,
                required List<CellPosition> primSelHistory,
                required int primSelHistoryId,
                required double scrollOffsetX,
                required double scrollOffsetY,
                required Set<CellPosition> selectedCells,
                required List<int> bestSortFound,
                required List<int> bestDistFound,
                required List<int> cursors,
                required List<List<int>> possibleInts,
                required List<List<List<int>>> validAreas,
                required int sortIndex,
                required AnalysisResult analysisResult,
                required bool validSortIsImpossible,
                required bool isFindingBestSort,
                required bool sortedWithValidSort,
                required bool sortedWithCurrentBestSort,
                required bool bestSortPossibleFound,
                required bool sortInProgress,
                required bool toApplyNextBestSort,
                required bool toAlwaysApplyCurrentBestSort,
                required bool analysisDone,
              }) => SheetDataTablesCompanion.insert(
                id: id,
                title: title,
                lastOpened: lastOpened,
                usedRows: usedRows,
                usedCols: usedCols,
                historyIndex: historyIndex,
                colHeaderHeight: colHeaderHeight,
                rowHeaderWidth: rowHeaderWidth,
                primSelHistory: primSelHistory,
                primSelHistoryId: primSelHistoryId,
                scrollOffsetX: scrollOffsetX,
                scrollOffsetY: scrollOffsetY,
                selectedCells: selectedCells,
                bestSortFound: bestSortFound,
                bestDistFound: bestDistFound,
                cursors: cursors,
                possibleInts: possibleInts,
                validAreas: validAreas,
                sortIndex: sortIndex,
                analysisResult: analysisResult,
                validSortIsImpossible: validSortIsImpossible,
                isFindingBestSort: isFindingBestSort,
                sortedWithValidSort: sortedWithValidSort,
                sortedWithCurrentBestSort: sortedWithCurrentBestSort,
                bestSortPossibleFound: bestSortPossibleFound,
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
                sheetCellsTableRefs = false,
                sheetColumnTypesTableRefs = false,
                updateHistoriesTableRefs = false,
                rowsBottomPosTableRefs = false,
                colRightPosTableRefs = false,
                rowsManuallyAdjustedHeightTableRefs = false,
                colsManuallyAdjustedWidthTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sheetCellsTableRefs) db.sheetCellsTable,
                    if (sheetColumnTypesTableRefs) db.sheetColumnTypesTable,
                    if (updateHistoriesTableRefs) db.updateHistoriesTable,
                    if (rowsBottomPosTableRefs) db.rowsBottomPosTable,
                    if (colRightPosTableRefs) db.colRightPosTable,
                    if (rowsManuallyAdjustedHeightTableRefs)
                      db.rowsManuallyAdjustedHeightTable,
                    if (colsManuallyAdjustedWidthTableRefs)
                      db.colsManuallyAdjustedWidthTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sheetCellsTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          SheetCellEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._sheetCellsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).sheetCellsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sheetColumnTypesTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          SheetColumnTypeEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._sheetColumnTypesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).sheetColumnTypesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (updateHistoriesTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          UpdateHistoriesEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._updateHistoriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).updateHistoriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rowsBottomPosTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          RowsBottomPosEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._rowsBottomPosTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).rowsBottomPosTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (colRightPosTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          ColRightPosEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._colRightPosTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).colRightPosTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (rowsManuallyAdjustedHeightTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          RowsManuallyAdjustedHeightEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._rowsManuallyAdjustedHeightTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).rowsManuallyAdjustedHeightTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sheetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (colsManuallyAdjustedWidthTableRefs)
                        await $_getPrefetchedData<
                          SheetDataEntity,
                          $SheetDataTablesTable,
                          ColsManuallyAdjustedWidthEntity
                        >(
                          currentTable: table,
                          referencedTable: $$SheetDataTablesTableReferences
                              ._colsManuallyAdjustedWidthTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SheetDataTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).colsManuallyAdjustedWidthTableRefs,
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
      SheetDataEntity,
      $$SheetDataTablesTableFilterComposer,
      $$SheetDataTablesTableOrderingComposer,
      $$SheetDataTablesTableAnnotationComposer,
      $$SheetDataTablesTableCreateCompanionBuilder,
      $$SheetDataTablesTableUpdateCompanionBuilder,
      (SheetDataEntity, $$SheetDataTablesTableReferences),
      SheetDataEntity,
      PrefetchHooks Function({
        bool sheetCellsTableRefs,
        bool sheetColumnTypesTableRefs,
        bool updateHistoriesTableRefs,
        bool rowsBottomPosTableRefs,
        bool colRightPosTableRefs,
        bool rowsManuallyAdjustedHeightTableRefs,
        bool colsManuallyAdjustedWidthTableRefs,
      })
    >;
typedef $$SheetCellsTableTableCreateCompanionBuilder =
    SheetCellsTableCompanion Function({
      required int sheetId,
      required int row,
      required int col,
      required String content,
      Value<int> rowid,
    });
typedef $$SheetCellsTableTableUpdateCompanionBuilder =
    SheetCellsTableCompanion Function({
      Value<int> sheetId,
      Value<int> row,
      Value<int> col,
      Value<String> content,
      Value<int> rowid,
    });

final class $$SheetCellsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $SheetCellsTableTable, SheetCellEntity> {
  $$SheetCellsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(db.sheetCellsTable.sheetId, db.sheetDataTables.id),
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

class $$SheetCellsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SheetCellsTableTable> {
  $$SheetCellsTableTableFilterComposer({
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

class $$SheetCellsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetCellsTableTable> {
  $$SheetCellsTableTableOrderingComposer({
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

class $$SheetCellsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetCellsTableTable> {
  $$SheetCellsTableTableAnnotationComposer({
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

class $$SheetCellsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetCellsTableTable,
          SheetCellEntity,
          $$SheetCellsTableTableFilterComposer,
          $$SheetCellsTableTableOrderingComposer,
          $$SheetCellsTableTableAnnotationComposer,
          $$SheetCellsTableTableCreateCompanionBuilder,
          $$SheetCellsTableTableUpdateCompanionBuilder,
          (SheetCellEntity, $$SheetCellsTableTableReferences),
          SheetCellEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$SheetCellsTableTableTableManager(
    _$AppDatabase db,
    $SheetCellsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetCellsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetCellsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetCellsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> row = const Value.absent(),
                Value<int> col = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SheetCellsTableCompanion(
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
              }) => SheetCellsTableCompanion.insert(
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
                  $$SheetCellsTableTableReferences(db, table, e),
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
                                    $$SheetCellsTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$SheetCellsTableTableReferences
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

typedef $$SheetCellsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetCellsTableTable,
      SheetCellEntity,
      $$SheetCellsTableTableFilterComposer,
      $$SheetCellsTableTableOrderingComposer,
      $$SheetCellsTableTableAnnotationComposer,
      $$SheetCellsTableTableCreateCompanionBuilder,
      $$SheetCellsTableTableUpdateCompanionBuilder,
      (SheetCellEntity, $$SheetCellsTableTableReferences),
      SheetCellEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$SheetColumnTypesTableTableCreateCompanionBuilder =
    SheetColumnTypesTableCompanion Function({
      required int sheetId,
      required int columnIndex,
      required ColumnType columnType,
      Value<int> rowid,
    });
typedef $$SheetColumnTypesTableTableUpdateCompanionBuilder =
    SheetColumnTypesTableCompanion Function({
      Value<int> sheetId,
      Value<int> columnIndex,
      Value<ColumnType> columnType,
      Value<int> rowid,
    });

final class $$SheetColumnTypesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SheetColumnTypesTableTable,
          SheetColumnTypeEntity
        > {
  $$SheetColumnTypesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.sheetColumnTypesTable.sheetId,
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

class $$SheetColumnTypesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTableTable> {
  $$SheetColumnTypesTableTableFilterComposer({
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

class $$SheetColumnTypesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTableTable> {
  $$SheetColumnTypesTableTableOrderingComposer({
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

class $$SheetColumnTypesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetColumnTypesTableTable> {
  $$SheetColumnTypesTableTableAnnotationComposer({
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

class $$SheetColumnTypesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetColumnTypesTableTable,
          SheetColumnTypeEntity,
          $$SheetColumnTypesTableTableFilterComposer,
          $$SheetColumnTypesTableTableOrderingComposer,
          $$SheetColumnTypesTableTableAnnotationComposer,
          $$SheetColumnTypesTableTableCreateCompanionBuilder,
          $$SheetColumnTypesTableTableUpdateCompanionBuilder,
          (SheetColumnTypeEntity, $$SheetColumnTypesTableTableReferences),
          SheetColumnTypeEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$SheetColumnTypesTableTableTableManager(
    _$AppDatabase db,
    $SheetColumnTypesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetColumnTypesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SheetColumnTypesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SheetColumnTypesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> columnIndex = const Value.absent(),
                Value<ColumnType> columnType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SheetColumnTypesTableCompanion(
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
              }) => SheetColumnTypesTableCompanion.insert(
                sheetId: sheetId,
                columnIndex: columnIndex,
                columnType: columnType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SheetColumnTypesTableTableReferences(db, table, e),
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
                                    $$SheetColumnTypesTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$SheetColumnTypesTableTableReferences
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

typedef $$SheetColumnTypesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetColumnTypesTableTable,
      SheetColumnTypeEntity,
      $$SheetColumnTypesTableTableFilterComposer,
      $$SheetColumnTypesTableTableOrderingComposer,
      $$SheetColumnTypesTableTableAnnotationComposer,
      $$SheetColumnTypesTableTableCreateCompanionBuilder,
      $$SheetColumnTypesTableTableUpdateCompanionBuilder,
      (SheetColumnTypeEntity, $$SheetColumnTypesTableTableReferences),
      SheetColumnTypeEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$UpdateHistoriesTableTableCreateCompanionBuilder =
    UpdateHistoriesTableCompanion Function({
      required DateTime timestamp,
      required int chronoId,
      required int sheetId,
      required Map<String, UpdateUnit> updates,
      Value<int> rowid,
    });
typedef $$UpdateHistoriesTableTableUpdateCompanionBuilder =
    UpdateHistoriesTableCompanion Function({
      Value<DateTime> timestamp,
      Value<int> chronoId,
      Value<int> sheetId,
      Value<Map<String, UpdateUnit>> updates,
      Value<int> rowid,
    });

final class $$UpdateHistoriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UpdateHistoriesTableTable,
          UpdateHistoriesEntity
        > {
  $$UpdateHistoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.updateHistoriesTable.sheetId,
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

class $$UpdateHistoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTableTable> {
  $$UpdateHistoriesTableTableFilterComposer({
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

class $$UpdateHistoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTableTable> {
  $$UpdateHistoriesTableTableOrderingComposer({
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

class $$UpdateHistoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpdateHistoriesTableTable> {
  $$UpdateHistoriesTableTableAnnotationComposer({
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

class $$UpdateHistoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpdateHistoriesTableTable,
          UpdateHistoriesEntity,
          $$UpdateHistoriesTableTableFilterComposer,
          $$UpdateHistoriesTableTableOrderingComposer,
          $$UpdateHistoriesTableTableAnnotationComposer,
          $$UpdateHistoriesTableTableCreateCompanionBuilder,
          $$UpdateHistoriesTableTableUpdateCompanionBuilder,
          (UpdateHistoriesEntity, $$UpdateHistoriesTableTableReferences),
          UpdateHistoriesEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$UpdateHistoriesTableTableTableManager(
    _$AppDatabase db,
    $UpdateHistoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpdateHistoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpdateHistoriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UpdateHistoriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> chronoId = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<Map<String, UpdateUnit>> updates = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UpdateHistoriesTableCompanion(
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
              }) => UpdateHistoriesTableCompanion.insert(
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
                  $$UpdateHistoriesTableTableReferences(db, table, e),
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
                                    $$UpdateHistoriesTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$UpdateHistoriesTableTableReferences
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

typedef $$UpdateHistoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpdateHistoriesTableTable,
      UpdateHistoriesEntity,
      $$UpdateHistoriesTableTableFilterComposer,
      $$UpdateHistoriesTableTableOrderingComposer,
      $$UpdateHistoriesTableTableAnnotationComposer,
      $$UpdateHistoriesTableTableCreateCompanionBuilder,
      $$UpdateHistoriesTableTableUpdateCompanionBuilder,
      (UpdateHistoriesEntity, $$UpdateHistoriesTableTableReferences),
      UpdateHistoriesEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$RowsBottomPosTableTableCreateCompanionBuilder =
    RowsBottomPosTableCompanion Function({
      required int sheetId,
      required int rowIndex,
      required double bottomPos,
      Value<int> rowid,
    });
typedef $$RowsBottomPosTableTableUpdateCompanionBuilder =
    RowsBottomPosTableCompanion Function({
      Value<int> sheetId,
      Value<int> rowIndex,
      Value<double> bottomPos,
      Value<int> rowid,
    });

final class $$RowsBottomPosTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RowsBottomPosTableTable,
          RowsBottomPosEntity
        > {
  $$RowsBottomPosTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.rowsBottomPosTable.sheetId,
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

class $$RowsBottomPosTableTableFilterComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTableTable> {
  $$RowsBottomPosTableTableFilterComposer({
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

class $$RowsBottomPosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTableTable> {
  $$RowsBottomPosTableTableOrderingComposer({
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

class $$RowsBottomPosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RowsBottomPosTableTable> {
  $$RowsBottomPosTableTableAnnotationComposer({
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

class $$RowsBottomPosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RowsBottomPosTableTable,
          RowsBottomPosEntity,
          $$RowsBottomPosTableTableFilterComposer,
          $$RowsBottomPosTableTableOrderingComposer,
          $$RowsBottomPosTableTableAnnotationComposer,
          $$RowsBottomPosTableTableCreateCompanionBuilder,
          $$RowsBottomPosTableTableUpdateCompanionBuilder,
          (RowsBottomPosEntity, $$RowsBottomPosTableTableReferences),
          RowsBottomPosEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$RowsBottomPosTableTableTableManager(
    _$AppDatabase db,
    $RowsBottomPosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RowsBottomPosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RowsBottomPosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RowsBottomPosTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<double> bottomPos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RowsBottomPosTableCompanion(
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
              }) => RowsBottomPosTableCompanion.insert(
                sheetId: sheetId,
                rowIndex: rowIndex,
                bottomPos: bottomPos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RowsBottomPosTableTableReferences(db, table, e),
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
                                    $$RowsBottomPosTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$RowsBottomPosTableTableReferences
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

typedef $$RowsBottomPosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RowsBottomPosTableTable,
      RowsBottomPosEntity,
      $$RowsBottomPosTableTableFilterComposer,
      $$RowsBottomPosTableTableOrderingComposer,
      $$RowsBottomPosTableTableAnnotationComposer,
      $$RowsBottomPosTableTableCreateCompanionBuilder,
      $$RowsBottomPosTableTableUpdateCompanionBuilder,
      (RowsBottomPosEntity, $$RowsBottomPosTableTableReferences),
      RowsBottomPosEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$ColRightPosTableTableCreateCompanionBuilder =
    ColRightPosTableCompanion Function({
      required int sheetId,
      required int colIndex,
      required double rightPos,
      Value<int> rowid,
    });
typedef $$ColRightPosTableTableUpdateCompanionBuilder =
    ColRightPosTableCompanion Function({
      Value<int> sheetId,
      Value<int> colIndex,
      Value<double> rightPos,
      Value<int> rowid,
    });

final class $$ColRightPosTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ColRightPosTableTable,
          ColRightPosEntity
        > {
  $$ColRightPosTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.colRightPosTable.sheetId,
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

class $$ColRightPosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ColRightPosTableTable> {
  $$ColRightPosTableTableFilterComposer({
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

class $$ColRightPosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ColRightPosTableTable> {
  $$ColRightPosTableTableOrderingComposer({
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

class $$ColRightPosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColRightPosTableTable> {
  $$ColRightPosTableTableAnnotationComposer({
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

class $$ColRightPosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColRightPosTableTable,
          ColRightPosEntity,
          $$ColRightPosTableTableFilterComposer,
          $$ColRightPosTableTableOrderingComposer,
          $$ColRightPosTableTableAnnotationComposer,
          $$ColRightPosTableTableCreateCompanionBuilder,
          $$ColRightPosTableTableUpdateCompanionBuilder,
          (ColRightPosEntity, $$ColRightPosTableTableReferences),
          ColRightPosEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$ColRightPosTableTableTableManager(
    _$AppDatabase db,
    $ColRightPosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColRightPosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColRightPosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColRightPosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> colIndex = const Value.absent(),
                Value<double> rightPos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColRightPosTableCompanion(
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
              }) => ColRightPosTableCompanion.insert(
                sheetId: sheetId,
                colIndex: colIndex,
                rightPos: rightPos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColRightPosTableTableReferences(db, table, e),
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
                                    $$ColRightPosTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$ColRightPosTableTableReferences
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

typedef $$ColRightPosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColRightPosTableTable,
      ColRightPosEntity,
      $$ColRightPosTableTableFilterComposer,
      $$ColRightPosTableTableOrderingComposer,
      $$ColRightPosTableTableAnnotationComposer,
      $$ColRightPosTableTableCreateCompanionBuilder,
      $$ColRightPosTableTableUpdateCompanionBuilder,
      (ColRightPosEntity, $$ColRightPosTableTableReferences),
      ColRightPosEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$RowsManuallyAdjustedHeightTableTableCreateCompanionBuilder =
    RowsManuallyAdjustedHeightTableCompanion Function({
      required int sheetId,
      required int rowIndex,
      required bool manuallyAdjusted,
      Value<int> rowid,
    });
typedef $$RowsManuallyAdjustedHeightTableTableUpdateCompanionBuilder =
    RowsManuallyAdjustedHeightTableCompanion Function({
      Value<int> sheetId,
      Value<int> rowIndex,
      Value<bool> manuallyAdjusted,
      Value<int> rowid,
    });

final class $$RowsManuallyAdjustedHeightTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RowsManuallyAdjustedHeightTableTable,
          RowsManuallyAdjustedHeightEntity
        > {
  $$RowsManuallyAdjustedHeightTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.rowsManuallyAdjustedHeightTable.sheetId,
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

class $$RowsManuallyAdjustedHeightTableTableFilterComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTableTable> {
  $$RowsManuallyAdjustedHeightTableTableFilterComposer({
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

class $$RowsManuallyAdjustedHeightTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTableTable> {
  $$RowsManuallyAdjustedHeightTableTableOrderingComposer({
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

class $$RowsManuallyAdjustedHeightTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RowsManuallyAdjustedHeightTableTable> {
  $$RowsManuallyAdjustedHeightTableTableAnnotationComposer({
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

class $$RowsManuallyAdjustedHeightTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RowsManuallyAdjustedHeightTableTable,
          RowsManuallyAdjustedHeightEntity,
          $$RowsManuallyAdjustedHeightTableTableFilterComposer,
          $$RowsManuallyAdjustedHeightTableTableOrderingComposer,
          $$RowsManuallyAdjustedHeightTableTableAnnotationComposer,
          $$RowsManuallyAdjustedHeightTableTableCreateCompanionBuilder,
          $$RowsManuallyAdjustedHeightTableTableUpdateCompanionBuilder,
          (
            RowsManuallyAdjustedHeightEntity,
            $$RowsManuallyAdjustedHeightTableTableReferences,
          ),
          RowsManuallyAdjustedHeightEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$RowsManuallyAdjustedHeightTableTableTableManager(
    _$AppDatabase db,
    $RowsManuallyAdjustedHeightTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RowsManuallyAdjustedHeightTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RowsManuallyAdjustedHeightTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RowsManuallyAdjustedHeightTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<bool> manuallyAdjusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RowsManuallyAdjustedHeightTableCompanion(
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
              }) => RowsManuallyAdjustedHeightTableCompanion.insert(
                sheetId: sheetId,
                rowIndex: rowIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RowsManuallyAdjustedHeightTableTableReferences(
                    db,
                    table,
                    e,
                  ),
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
                                    $$RowsManuallyAdjustedHeightTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$RowsManuallyAdjustedHeightTableTableReferences
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

typedef $$RowsManuallyAdjustedHeightTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RowsManuallyAdjustedHeightTableTable,
      RowsManuallyAdjustedHeightEntity,
      $$RowsManuallyAdjustedHeightTableTableFilterComposer,
      $$RowsManuallyAdjustedHeightTableTableOrderingComposer,
      $$RowsManuallyAdjustedHeightTableTableAnnotationComposer,
      $$RowsManuallyAdjustedHeightTableTableCreateCompanionBuilder,
      $$RowsManuallyAdjustedHeightTableTableUpdateCompanionBuilder,
      (
        RowsManuallyAdjustedHeightEntity,
        $$RowsManuallyAdjustedHeightTableTableReferences,
      ),
      RowsManuallyAdjustedHeightEntity,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$ColsManuallyAdjustedWidthTableTableCreateCompanionBuilder =
    ColsManuallyAdjustedWidthTableCompanion Function({
      required int sheetId,
      required int colIndex,
      required bool manuallyAdjusted,
      Value<int> rowid,
    });
typedef $$ColsManuallyAdjustedWidthTableTableUpdateCompanionBuilder =
    ColsManuallyAdjustedWidthTableCompanion Function({
      Value<int> sheetId,
      Value<int> colIndex,
      Value<bool> manuallyAdjusted,
      Value<int> rowid,
    });

final class $$ColsManuallyAdjustedWidthTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ColsManuallyAdjustedWidthTableTable,
          ColsManuallyAdjustedWidthEntity
        > {
  $$ColsManuallyAdjustedWidthTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SheetDataTablesTable _sheetIdTable(_$AppDatabase db) =>
      db.sheetDataTables.createAlias(
        $_aliasNameGenerator(
          db.colsManuallyAdjustedWidthTable.sheetId,
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

class $$ColsManuallyAdjustedWidthTableTableFilterComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTableTable> {
  $$ColsManuallyAdjustedWidthTableTableFilterComposer({
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

class $$ColsManuallyAdjustedWidthTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTableTable> {
  $$ColsManuallyAdjustedWidthTableTableOrderingComposer({
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

class $$ColsManuallyAdjustedWidthTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColsManuallyAdjustedWidthTableTable> {
  $$ColsManuallyAdjustedWidthTableTableAnnotationComposer({
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

class $$ColsManuallyAdjustedWidthTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColsManuallyAdjustedWidthTableTable,
          ColsManuallyAdjustedWidthEntity,
          $$ColsManuallyAdjustedWidthTableTableFilterComposer,
          $$ColsManuallyAdjustedWidthTableTableOrderingComposer,
          $$ColsManuallyAdjustedWidthTableTableAnnotationComposer,
          $$ColsManuallyAdjustedWidthTableTableCreateCompanionBuilder,
          $$ColsManuallyAdjustedWidthTableTableUpdateCompanionBuilder,
          (
            ColsManuallyAdjustedWidthEntity,
            $$ColsManuallyAdjustedWidthTableTableReferences,
          ),
          ColsManuallyAdjustedWidthEntity,
          PrefetchHooks Function({bool sheetId})
        > {
  $$ColsManuallyAdjustedWidthTableTableTableManager(
    _$AppDatabase db,
    $ColsManuallyAdjustedWidthTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColsManuallyAdjustedWidthTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ColsManuallyAdjustedWidthTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ColsManuallyAdjustedWidthTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> sheetId = const Value.absent(),
                Value<int> colIndex = const Value.absent(),
                Value<bool> manuallyAdjusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColsManuallyAdjustedWidthTableCompanion(
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
              }) => ColsManuallyAdjustedWidthTableCompanion.insert(
                sheetId: sheetId,
                colIndex: colIndex,
                manuallyAdjusted: manuallyAdjusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColsManuallyAdjustedWidthTableTableReferences(db, table, e),
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
                                    $$ColsManuallyAdjustedWidthTableTableReferences
                                        ._sheetIdTable(db),
                                referencedColumn:
                                    $$ColsManuallyAdjustedWidthTableTableReferences
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

typedef $$ColsManuallyAdjustedWidthTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColsManuallyAdjustedWidthTableTable,
      ColsManuallyAdjustedWidthEntity,
      $$ColsManuallyAdjustedWidthTableTableFilterComposer,
      $$ColsManuallyAdjustedWidthTableTableOrderingComposer,
      $$ColsManuallyAdjustedWidthTableTableAnnotationComposer,
      $$ColsManuallyAdjustedWidthTableTableCreateCompanionBuilder,
      $$ColsManuallyAdjustedWidthTableTableUpdateCompanionBuilder,
      (
        ColsManuallyAdjustedWidthEntity,
        $$ColsManuallyAdjustedWidthTableTableReferences,
      ),
      ColsManuallyAdjustedWidthEntity,
      PrefetchHooks Function({bool sheetId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SheetDataTablesTableTableManager get sheetDataTables =>
      $$SheetDataTablesTableTableManager(_db, _db.sheetDataTables);
  $$SheetCellsTableTableTableManager get sheetCellsTable =>
      $$SheetCellsTableTableTableManager(_db, _db.sheetCellsTable);
  $$SheetColumnTypesTableTableTableManager get sheetColumnTypesTable =>
      $$SheetColumnTypesTableTableTableManager(_db, _db.sheetColumnTypesTable);
  $$UpdateHistoriesTableTableTableManager get updateHistoriesTable =>
      $$UpdateHistoriesTableTableTableManager(_db, _db.updateHistoriesTable);
  $$RowsBottomPosTableTableTableManager get rowsBottomPosTable =>
      $$RowsBottomPosTableTableTableManager(_db, _db.rowsBottomPosTable);
  $$ColRightPosTableTableTableManager get colRightPosTable =>
      $$ColRightPosTableTableTableManager(_db, _db.colRightPosTable);
  $$RowsManuallyAdjustedHeightTableTableTableManager
  get rowsManuallyAdjustedHeightTable =>
      $$RowsManuallyAdjustedHeightTableTableTableManager(
        _db,
        _db.rowsManuallyAdjustedHeightTable,
      );
  $$ColsManuallyAdjustedWidthTableTableTableManager
  get colsManuallyAdjustedWidthTable =>
      $$ColsManuallyAdjustedWidthTableTableTableManager(
        _db,
        _db.colsManuallyAdjustedWidthTable,
      );
}
