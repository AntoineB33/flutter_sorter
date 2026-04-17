import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';

part 'update_data.g.dart';

enum RecordType {
  cellUpdate,
  columnTypeUpdate,
  sheetDataUpdate,
  updateData,
  rowsBottomPosUpdate,
  colRightPosUpdate,
  rowsManuallyAdjustedHeightUpdate,
  colsManuallyAdjustedWidthUpdate,
}

sealed class UpdateUnit {
  const UpdateUnit();

  String getKey();

  //ignore: avoid_unused_parameters
  UpdateUnit merge(UpdateUnit newUpdate);

  factory UpdateUnit.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case RecordType.cellUpdate:
        return CellUpdate.fromJson(json);
      case RecordType.columnTypeUpdate:
        return ColumnTypeUpdate.fromJson(json);
      case RecordType.sheetDataUpdate:
        return SheetDataUpdate.fromJson(json);
      case RecordType.updateData:
        return UpdateData.fromJson(json);
      case RecordType.rowsBottomPosUpdate:
        return RowsBottomPosUpdate.fromJson(json);
      case RecordType.colRightPosUpdate:
        return ColRightPosUpdate.fromJson(json);
      case RecordType.rowsManuallyAdjustedHeightUpdate:
        return RowsManuallyAdjustedHeightUpdate.fromJson(json);
      case RecordType.colsManuallyAdjustedWidthUpdate:
        return ColsManuallyAdjustedWidthUpdate.fromJson(json);
      default:
        throw Exception('Unknown UpdateUnit type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class CellPosition {
  final int rowId;
  final int colId;
  CellPosition(this.rowId, this.colId);

  factory CellPosition.fromJson(Map<String, dynamic> json) =>
      _$CellPositionFromJson(json);
  Map<String, dynamic> toJson() => _$CellPositionToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => CellPosition(0, 0).toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          rowId == other.rowId &&
          colId == other.colId;

  @override
  int get hashCode => rowId.hashCode ^ colId.hashCode;
}

enum SheetDataUpdateFieldDouble {
  colHeaderHeight,
  prevColHeaderHeight,
  rowHeaderWidth,
  prevRowHeaderWidth,
  scrollOffsetX,
  scrollOffsetY,
}

enum SheetDataUpdateFieldListInt {
  usedRows,
  usedCols,

  bestSortFound,
  bestDistFound,
  cursors,
}

enum SheetDataUpdateFieldBool {
  sortInProgress,
  toApplyNextBestSort,
  toAlwaysApplyCurrentBestSort,
  analysisDone,
}

@JsonSerializable(explicitToJson: true)
class SheetDataUpdate extends UpdateUnit {
  final RecordType type = RecordType.sheetDataUpdate;
  final int sheetId;
  final bool addOtherwiseRemove;
  final String? newName;
  final String? prevName;
  final DateTime? lastOpened;

  final Map<SheetDataUpdateFieldDouble, double> doubleFields;
  final Map<SheetDataUpdateFieldListInt, List<int>> listIntFields;
  final Map<SheetDataUpdateFieldBool, bool> boolFields;

  final int? historyIndex;
  final SelectionData? selectionHistory;

  final List<List<int>>? possibleInts;
  final List<List<List<int>>>? validAreas;
  final int? sortIndex;

  final AnalysisResult? analysisResult;

  SheetDataUpdate(
    this.sheetId,
    this.addOtherwiseRemove, {
    this.newName,
    this.prevName,
    this.lastOpened,
    this.usedRows,
    this.usedCols,
    this.historyIndex,
    this.colHeaderHeight,
    this.prevColHeaderHeight,
    this.rowHeaderWidth,
    this.prevRowHeaderWidth,
    this.selectionHistory,
    this.scrollOffsetX,
    this.scrollOffsetY,
    this.bestSortFound,
    this.bestDistFound,
    this.cursors,
    this.possibleInts,
    this.validAreas,
    this.sortIndex,
    this.analysisResult,
    this.sortInProgress,
    this.toApplyNextBestSort,
    this.toAlwaysApplyCurrentBestSort,
    this.analysisDone,
  });

  factory SheetDataUpdate.initial(int sheetId) {
    return SheetDataUpdate(sheetId, true);
  }

  @override
  String getKey() {
    return 'sheetDataUpdate:$sheetId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    var newSheetDataUpdate = newUpdate as SheetDataUpdate;

    if (!newSheetDataUpdate.addOtherwiseRemove) {
      return SheetDataUpdate.initial(
        sheetId,
      ); // Replaced reassignment with direct return
    }

    // 1. Convert the current object to a Map
    final currentJson = toJson();

    // 2. Convert the new update to a Map, but STRIP OUT all null values.
    // This perfectly mimics your existing `new ?? old` logic.
    final newJson = newSheetDataUpdate.toJson()
      ..removeWhere((key, value) => value == null);

    // 3. Merge the maps. Because newJson is second, its non-null values
    // will overwrite the values in currentJson.
    final mergedJson = {...currentJson, ...newJson};

    // 4. Rebuild and return the object!
    return SheetDataUpdate.fromJson(mergedJson);
  }

  factory SheetDataUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetDataUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SheetDataUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  final RecordType type = RecordType.cellUpdate;
  final int sheetId;
  final int rowId;
  final int colId;
  final String prevValue;
  final String newValue;

  CellUpdate(
    this.sheetId,
    this.rowId,
    this.colId,
    this.newValue,
    this.prevValue,
  );

  @override
  String getKey() {
    return 'cellUpdate:$sheetId:$rowId:$colId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newCellUpdate = newUpdate as CellUpdate;
    return CellUpdate(sheetId, rowId, colId, newCellUpdate.newValue, prevValue);
  }

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColumnTypeUpdate extends UpdateUnit {
  final RecordType type = RecordType.columnTypeUpdate;
  final int sheetId;
  final int colId;
  final ColumnType newColumnType;
  final ColumnType previousColumnType;
  ColumnTypeUpdate(
    this.sheetId,
    this.colId,
    this.newColumnType,
    this.previousColumnType,
  );

  @override
  String getKey() {
    return 'ColumnTypeUpdate:$sheetId:$colId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newColumnTypeUpdate = newUpdate as ColumnTypeUpdate;
    return ColumnTypeUpdate(
      sheetId,
      colId,
      newColumnTypeUpdate.newColumnType, // Always take the latest value
      previousColumnType, // Keep the original previousColumnType
    );
  }

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateData extends UpdateUnit {
  final RecordType type = RecordType.updateData;
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final IMap<String, UpdateUnit> updates;
  bool addOtherwiseRemove;
  UpdateData(
    this.chronoId,
    this.sheetId,
    this.updates,
    this.addOtherwiseRemove, {
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String getKey() {
    return 'updateData:$timestamp:$chronoId:$sheetId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newUpdateData = newUpdate as UpdateData;

    final Map<String, UpdateUnit> mergedUpdates = {};
    for (var entry in updates.entries) {
      mergedUpdates[entry.key] = entry.value;
    }
    for (var entry in newUpdateData.updates.entries) {
      mergedUpdates.update(
        entry.key,
        (existing) => existing.merge(entry.value),
        ifAbsent: () => entry.value,
      );
    }
    // 1. Merge constructor parameters
    final merged = UpdateData(
      chronoId,
      sheetId,
      mergedUpdates.lock,
      addOtherwiseRemove || newUpdateData.addOtherwiseRemove,
      timestamp: newUpdateData.timestamp.isAfter(timestamp)
          ? newUpdateData.timestamp
          : timestamp, // Keep the latest timestamp
    );

    return merged;
  }

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
}

@JsonSerializable()
class RowsBottomPosUpdate extends UpdateUnit {
  final RecordType type = RecordType.rowsBottomPosUpdate;
  final int sheetId;
  final int rowIndex;
  final double? newBottomPos;
  final double? prevBottomPos;

  RowsBottomPosUpdate(
    this.sheetId,
    this.rowIndex, {
    this.newBottomPos,
    this.prevBottomPos,
  });

  @override
  String getKey() {
    return 'RowsBottomPosUpdate:$sheetId:$rowIndex';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newRowsBottomPosUpdate = newUpdate as RowsBottomPosUpdate;
    return RowsBottomPosUpdate(
      sheetId,
      rowIndex,
      newBottomPos: newRowsBottomPosUpdate.newBottomPos,
      prevBottomPos: newRowsBottomPosUpdate.prevBottomPos ?? prevBottomPos,
    );
  }

  factory RowsBottomPosUpdate.fromJson(Map<String, dynamic> json) =>
      _$RowsBottomPosUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RowsBottomPosUpdateToJson(this);
}

@JsonSerializable()
class ColRightPosUpdate extends UpdateUnit {
  final RecordType type = RecordType.colRightPosUpdate;
  final int sheetId;
  bool addOtherwiseRemove;
  final int colIndex;
  final double newRightPos;
  double? prevRightPos;

  ColRightPosUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.colIndex,
    this.newRightPos, {
    this.prevRightPos,
  });

  @override
  String getKey() {
    return 'ColRightPosUpdate:$sheetId:$colIndex';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newColRightPosUpdate = newUpdate as ColRightPosUpdate;
    return ColRightPosUpdate(
        sheetId,
        addOtherwiseRemove || newColRightPosUpdate.addOtherwiseRemove,
        colIndex,
        newColRightPosUpdate.newRightPos, // Always take the latest value
      )
      ..prevRightPos =
          newColRightPosUpdate.prevRightPos ??
          prevRightPos; // Keep the original prevRightPos if the new one is null
  }

  factory ColRightPosUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColRightPosUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColRightPosUpdateToJson(this);
}

@JsonSerializable()
class RowsManuallyAdjustedHeightUpdate extends UpdateUnit {
  final RecordType type = RecordType.rowsManuallyAdjustedHeightUpdate;
  final int sheetId;
  final bool addOtherwiseRemove;
  final int rowIndex;
  final bool manuallyAdjusted;
  bool? prevManuallyAdjusted;

  RowsManuallyAdjustedHeightUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.rowIndex,
    this.manuallyAdjusted, {
    this.prevManuallyAdjusted,
  });

  @override
  String getKey() {
    return 'RowsManuallyAdjustedHeightUpdate:$sheetId:$rowIndex';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newRowsManuallyAdjustedHeightUpdate =
        newUpdate as RowsManuallyAdjustedHeightUpdate;
    return RowsManuallyAdjustedHeightUpdate(
        sheetId,
        addOtherwiseRemove ||
            newRowsManuallyAdjustedHeightUpdate.addOtherwiseRemove,
        rowIndex,
        newRowsManuallyAdjustedHeightUpdate
            .manuallyAdjusted, // Always take the latest value
      )
      ..prevManuallyAdjusted =
          newRowsManuallyAdjustedHeightUpdate.prevManuallyAdjusted ??
          prevManuallyAdjusted; // Keep the original prevManuallyAdjusted if the new one is null
  }

  factory RowsManuallyAdjustedHeightUpdate.fromJson(
    Map<String, dynamic> json,
  ) => _$RowsManuallyAdjustedHeightUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$RowsManuallyAdjustedHeightUpdateToJson(this);
}

@JsonSerializable()
class ColsManuallyAdjustedWidthUpdate extends UpdateUnit {
  final RecordType type = RecordType.colsManuallyAdjustedWidthUpdate;
  final int sheetId;
  final bool addOtherwiseRemove;
  final int colIndex;
  final bool manuallyAdjusted;
  bool? prevManuallyAdjusted;

  ColsManuallyAdjustedWidthUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.colIndex,
    this.manuallyAdjusted, {
    this.prevManuallyAdjusted,
  });

  @override
  String getKey() {
    return 'ColsManuallyAdjustedWidthUpdate:$sheetId:$colIndex';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newColsManuallyAdjustedWidthUpdate =
        newUpdate as ColsManuallyAdjustedWidthUpdate;
    return ColsManuallyAdjustedWidthUpdate(
        sheetId,
        addOtherwiseRemove ||
            newColsManuallyAdjustedWidthUpdate.addOtherwiseRemove,
        colIndex,
        newColsManuallyAdjustedWidthUpdate
            .manuallyAdjusted, // Always take the latest value
      )
      ..prevManuallyAdjusted =
          newColsManuallyAdjustedWidthUpdate.prevManuallyAdjusted ??
          prevManuallyAdjusted; // Keep the original prevManuallyAdjusted if the new one is null
  }

  factory ColsManuallyAdjustedWidthUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColsManuallyAdjustedWidthUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ColsManuallyAdjustedWidthUpdateToJson(this);
}
