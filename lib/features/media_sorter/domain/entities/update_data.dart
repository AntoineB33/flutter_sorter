import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'update_data.g.dart';

enum RecordType {
  cellUpdate,
  columnTypeUpdate,
  sheetDataUpdate,
}

sealed class UpdateUnit {
  const UpdateUnit();

  String getKey();

  factory UpdateUnit.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case RecordType.cellUpdate:
        return CellUpdate.fromJson(json);
      case RecordType.columnTypeUpdate:
        return ColumnTypeUpdate.fromJson(json);
      case RecordType.sheetDataUpdate:
        return SheetDataUpdate.fromJson(json);
      default:
        throw Exception('Unknown UpdateUnit type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class SheetDataUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final String? newName;
  String? prevName;
  final int? historyIndex;
  int? prevHistoryIndex;
  final double? colHeaderHeight;
  double? prevColHeaderHeight;
  final double? rowHeaderWidth;
  double? prevRowHeaderWidth;
  final int? primarySelectedCellX;
  double? prevPrimarySelectedCellX;
  final int? primarySelectedCellY;
  double? prevPrimarySelectedCellY;
  final double? scrollOffsetX;
  double? prevScrollOffsetX;
  final double? scrollOffsetY;
  double? prevScrollOffsetY;
  final List<int>? bestDistFound;
  final int? sortIndex;
  int? prevSortIndex;

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
    this.bestDistFound,
    this.sortIndex,
  });

  @override
  String getKey() {
    return 'sheetDataUpdate:$sheetId';
  }

  factory SheetDataUpdate.fromJson(Map<String, dynamic> json) =>
      _$SheetDataUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SheetDataUpdateToJson(this);
}

@JsonSerializable()
class CellUpdate extends UpdateUnit {
  final int sheetId;
  final int rowId;
  final int colId;
  String? prevValue;
  String newValue;
  CellUpdate(
    this.sheetId,
    this.rowId,
    this.colId,
    this.newValue, {
    this.prevValue,
  });

  @override
  String getKey() {
    return 'cellUpdate:$sheetId:$rowId:$colId';
  }

  factory CellUpdate.fromJson(Map<String, dynamic> json) =>
      _$CellUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ColumnTypeUpdate extends UpdateUnit {
  final int sheetId;
  final int colId;
  final ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate(
    this.sheetId,
    this.colId,
    this.newColumnType, {
    this.previousColumnType,
  });

  @override
  String getKey() {
    return 'ColumnTypeUpdate:$sheetId:$colId';
  }

  factory ColumnTypeUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColumnTypeUpdateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UpdateData extends UpdateUnit {
  final DateTime timestamp;
  final int chronoId;
  final int sheetId;
  final Map<Record, UpdateUnit> updates;
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

  factory UpdateData.fromJson(Map<String, dynamic> json) =>
      _$UpdateDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateDataToJson(this);
}

@JsonSerializable()
class RowsBottomPosUpdate extends UpdateUnit {
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

  factory RowsBottomPosUpdate.fromJson(Map<String, dynamic> json) =>
      _$RowsBottomPosUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RowsBottomPosUpdateToJson(this);
}

class ColRightPosUpdate extends UpdateUnit {
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

  factory ColRightPosUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColRightPosUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColRightPosUpdateToJson(this);
}

class RowsManuallyAdjustedHeightUpdate extends UpdateUnit {
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

  factory RowsManuallyAdjustedHeightUpdate.fromJson(Map<String, dynamic> json) =>
      _$RowsManuallyAdjustedHeightUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RowsManuallyAdjustedHeightUpdateToJson(this);
}

class ColsManuallyAdjustedWidthUpdate extends UpdateUnit {
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

  factory ColsManuallyAdjustedWidthUpdate.fromJson(Map<String, dynamic> json) =>
      _$ColsManuallyAdjustedWidthUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColsManuallyAdjustedWidthUpdateToJson(this);
}

class SelectedCellsUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final int cellIndex;
  final int row;
  final int col;

  SelectedCellsUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.cellIndex,
    this.row,
    this.col,
  );

  @override
  String getKey() {
    return 'SelectedCellsUpdate:$sheetId:$cellIndex';
  }

  factory SelectedCellsUpdate.fromJson(Map<String, dynamic> json) =>
      _$SelectedCellsUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SelectedCellsUpdateToJson(this);
}

class BestSortFoundUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final int sortIndex;
  final int value;

  BestSortFoundUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.sortIndex,
    this.value,
  );

  @override
  String getKey() {
    return 'BestSortFoundUpdate:$sheetId:$sortIndex';
  }

  factory BestSortFoundUpdate.fromJson(Map<String, dynamic> json) =>
      _$BestSortFoundUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BestSortFoundUpdateToJson(this);
}

class CursorsUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final int cursorIndex;
  final int value;

  CursorsUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.cursorIndex,
    this.value,
  );

  @override
  String getKey() {
    return 'CursorsUpdate:$sheetId:$cursorIndex';
  }

  factory CursorsUpdate.fromJson(Map<String, dynamic> json) =>
      _$CursorsUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CursorsUpdateToJson(this);
}

class PossibleIntsByIdUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final int id;
  final int intIndex;
  final int value;

  PossibleIntsByIdUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.id,
    this.intIndex,
    this.value,
  );

  @override
  String getKey() {
    return 'PossibleIntsByIdUpdate:$sheetId:$id:$intIndex';
  }

  factory PossibleIntsByIdUpdate.fromJson(Map<String, dynamic> json) =>
      _$PossibleIntsByIdUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PossibleIntsByIdUpdateToJson(this);
}

class ValidAreasByIdUpdate extends UpdateUnit {
  final int sheetId;
  final bool addOtherwiseRemove;
  final int id;
  final int intIndex;
  final int areaIndex;
  final int areaEdge;

  ValidAreasByIdUpdate(
    this.sheetId,
    this.addOtherwiseRemove,
    this.id,
    this.intIndex,
    this.areaIndex,
    this.areaEdge,
  );

  @override
  String getKey() {
    return 'ValidAreasByIdUpdate:$sheetId:$id:$intIndex:$areaIndex';
  }

  factory ValidAreasByIdUpdate.fromJson(Map<String, dynamic> json) =>
      _$ValidAreasByIdUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ValidAreasByIdUpdateToJson(this);
}


