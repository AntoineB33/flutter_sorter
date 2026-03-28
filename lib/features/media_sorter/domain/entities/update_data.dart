import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

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

class CellPosition {
  final int rowId;
  final int colId;
  CellPosition(this.rowId, this.colId);
  
  factory CellPosition.fromJson(Map<String, dynamic> json) =>
      CellPosition(json['row'] as int, json['col'] as int);
  
  Map<String, dynamic> toJson() => {
        'row': rowId,
        'col': colId,
      };
}

@JsonSerializable()
class SheetDataUpdate extends UpdateUnit {
  final RecordType type = RecordType.sheetDataUpdate;
  final int sheetId;
  final bool addOtherwiseRemove;
  final String? newName;
  String? prevName;
  final DateTime? lastOpened;
  final int? historyIndex;
  final double? colHeaderHeight;
  double? prevColHeaderHeight;
  final double? rowHeaderWidth;
  double? prevRowHeaderWidth;
  final int? primarySelectedCellX;
  int? prevPrimarySelectedCellX;
  final int? primarySelectedCellY;
  int? prevPrimarySelectedCellY;
  final double? scrollOffsetX;
  double? prevScrollOffsetX;
  final double? scrollOffsetY;
  double? prevScrollOffsetY;
  final List<CellPosition>? selectedCells;
  final List<int>? bestSortFound;
  final List<int>? bestDistFound;
  final List<int>? cursors;
  final List<List<int>>? possibleInts;
  final List<List<List<int>>>? validAreas;
  final int? sortIndex;

  SheetDataUpdate(
    this.sheetId,
    this.addOtherwiseRemove, {
    this.newName,
    this.historyIndex,
    this.colHeaderHeight,
    this.rowHeaderWidth,
    this.primarySelectedCellX,
    this.primarySelectedCellY,
    this.scrollOffsetX,
    this.scrollOffsetY,
    this.selectedCells,
    this.bestSortFound,
    this.bestDistFound,
    this.cursors,
    this.possibleInts,
    this.validAreas,
    this.sortIndex,
  });

  @override
  String getKey() {
    return 'sheetDataUpdate:$sheetId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newSheetDataUpdate = newUpdate as SheetDataUpdate;

    // 1. Merge constructor parameters
    final merged = SheetDataUpdate(
      newSheetDataUpdate.sheetId,
      newSheetDataUpdate.addOtherwiseRemove, // Typically you'd want the newest boolean state
      newName: newSheetDataUpdate.newName ?? newName,
      historyIndex: newSheetDataUpdate.historyIndex ?? historyIndex,
      colHeaderHeight: newSheetDataUpdate.colHeaderHeight ?? colHeaderHeight,
      rowHeaderWidth: newSheetDataUpdate.rowHeaderWidth ?? rowHeaderWidth,
      primarySelectedCellX: newSheetDataUpdate.primarySelectedCellX ?? primarySelectedCellX,
      primarySelectedCellY: newSheetDataUpdate.primarySelectedCellY ?? primarySelectedCellY,
      scrollOffsetX: newSheetDataUpdate.scrollOffsetX ?? scrollOffsetX,
      scrollOffsetY: newSheetDataUpdate.scrollOffsetY ?? scrollOffsetY,
      selectedCells: newSheetDataUpdate.selectedCells ?? selectedCells,
      bestSortFound: newSheetDataUpdate.bestSortFound ?? bestSortFound,
      bestDistFound: newSheetDataUpdate.bestDistFound ?? bestDistFound,
      cursors: newSheetDataUpdate.cursors ?? cursors,
      possibleInts: newSheetDataUpdate.possibleInts ?? possibleInts,
      validAreas: newSheetDataUpdate.validAreas ?? validAreas,
      sortIndex: newSheetDataUpdate.sortIndex ?? sortIndex,
    );

    // 2. Merge the mutable 'prev' properties (since they aren't in the constructor)
    merged.prevName = newSheetDataUpdate.prevName ?? prevName;
    merged.prevColHeaderHeight = newSheetDataUpdate.prevColHeaderHeight ?? prevColHeaderHeight;
    merged.prevRowHeaderWidth = newSheetDataUpdate.prevRowHeaderWidth ?? prevRowHeaderWidth;
    merged.prevPrimarySelectedCellX = newSheetDataUpdate.prevPrimarySelectedCellX ?? prevPrimarySelectedCellX;
    merged.prevPrimarySelectedCellY = newSheetDataUpdate.prevPrimarySelectedCellY ?? prevPrimarySelectedCellY;
    merged.prevScrollOffsetX = newSheetDataUpdate.prevScrollOffsetX ?? prevScrollOffsetX;
    merged.prevScrollOffsetY = newSheetDataUpdate.prevScrollOffsetY ?? prevScrollOffsetY;

    return merged;
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
  String? prevValue;
  String newValue;
  CellUpdate(
    this.sheetId,
    this.rowId,
    this.colId,
    this.newValue);

  @override
  String getKey() {
    return 'cellUpdate:$sheetId:$rowId:$colId';
  }

  @override
  UpdateUnit merge(UpdateUnit newUpdate) {
    final newCellUpdate = newUpdate as CellUpdate;
    return CellUpdate(
      sheetId,
      rowId,
      colId,
      newCellUpdate.newValue, // Always take the latest value
    )..prevValue = newCellUpdate.prevValue ?? prevValue; // Keep the original prevValue if the new one is null
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
  ColumnType? previousColumnType;
  ColumnTypeUpdate(
    this.sheetId,
    this.colId,
    this.newColumnType);

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
    )..previousColumnType = newColumnTypeUpdate.previousColumnType ?? previousColumnType; // Keep the original previousColumnType if the new one is null
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
  final Map<String, UpdateUnit> updates;
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

    for (var entry in updates.entries) {
      updates.update(entry.key, (existing) => existing.merge(entry.value));
    }
    // 1. Merge constructor parameters
    final merged = UpdateData(
      chronoId,
      sheetId,
      updates,
      addOtherwiseRemove || newUpdateData.addOtherwiseRemove,
      timestamp: newUpdateData.timestamp.isAfter(timestamp) ? newUpdateData.timestamp : timestamp, // Keep the latest timestamp
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
  bool addOtherwiseRemove;
  final int rowIndex;
  final double newBottomPos;
  double? prevBottomPos;

  RowsBottomPosUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.rowIndex,
    this.newBottomPos, {
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
      addOtherwiseRemove || newRowsBottomPosUpdate.addOtherwiseRemove,
      rowIndex,
      newRowsBottomPosUpdate.newBottomPos, // Always take the latest value
    )..prevBottomPos = newRowsBottomPosUpdate.prevBottomPos ?? prevBottomPos; // Keep the original prevBottomPos if the new one is null
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
    )..prevRightPos = newColRightPosUpdate.prevRightPos ?? prevRightPos; // Keep the original prevRightPos if the new one is null
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
    final newRowsManuallyAdjustedHeightUpdate = newUpdate as RowsManuallyAdjustedHeightUpdate;
    return RowsManuallyAdjustedHeightUpdate(
      sheetId,
      addOtherwiseRemove || newRowsManuallyAdjustedHeightUpdate.addOtherwiseRemove,
      rowIndex,
      newRowsManuallyAdjustedHeightUpdate.manuallyAdjusted, // Always take the latest value
    )..prevManuallyAdjusted = newRowsManuallyAdjustedHeightUpdate.prevManuallyAdjusted ?? prevManuallyAdjusted; // Keep the original prevManuallyAdjusted if the new one is null
  }

  factory RowsManuallyAdjustedHeightUpdate.fromJson(Map<String, dynamic> json) =>
      _$RowsManuallyAdjustedHeightUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RowsManuallyAdjustedHeightUpdateToJson(this);
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
    final newColsManuallyAdjustedWidthUpdate = newUpdate as ColsManuallyAdjustedWidthUpdate;
    return ColsManuallyAdjustedWidthUpdate(
      sheetId,
      addOtherwiseRemove || newColsManuallyAdjustedWidthUpdate.addOtherwiseRemove,
      colIndex,
      newColsManuallyAdjustedWidthUpdate.manuallyAdjusted, // Always take the latest value
    )..prevManuallyAdjusted = newColsManuallyAdjustedWidthUpdate.prevManuallyAdjusted ?? prevManuallyAdjusted; // Keep the original prevManuallyAdjusted if the new one is null
  }

  factory ColsManuallyAdjustedWidthUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColsManuallyAdjustedWidthUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColsManuallyAdjustedWidthUpdateToJson(this);
}
