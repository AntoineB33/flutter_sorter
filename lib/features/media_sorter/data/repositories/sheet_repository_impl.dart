import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class SheetRepositoryImpl implements SheetRepository {
  final FileSheetLocalDataSource dataSource;

  SheetRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, SelectionData>> getLastSelection() async {
    try {
      final selection = await dataSource.getLastSelection();
      return Right(selection);
    } on CacheNotFoundException {
      return Left(CacheNotFoundFailure());
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<CacheFailure, void>> saveLastSelection(SelectionData selection) async {
    try {
      await dataSource.saveLastSelection(selection);
      return Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> recentSheetIds() async {
    try {
      final sheetIds = await dataSource.recentSheetIds();
      return Right(sheetIds);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecentSheetIds(List<String> sheetIds) async {
    try {
      await dataSource.saveRecentSheetIds(sheetIds);
      return Right(null);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, SheetData>> loadSheet(String sheetName) async {
    try {
      final sheet = await dataSource.getSheet(sheetName);
      return Right(sheet);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSheet(String sheetName, SheetData sheet) async {
    try {
      await dataSource.saveSheet(sheetName, sheet);
      return Right(null);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, Map<String, SelectionData>>> getAllLastSelected() async {
    try {
      final cells = await dataSource.getAllLastSelected();
      return Right(cells);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveAllLastSelected(Map<String, SelectionData> cells) async {
    try {
      await dataSource.saveAllLastSelected(cells);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, Map<String, SortStatus>>> getAllSortStatus() async {
    try {
      final sortStatus = await dataSource.getAllSortStatus();
      return Right(sortStatus);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveAllSortStatus(
    Map<String, SortStatus> sortStatusBySheet,
  ) async {
    try {
      await dataSource.saveAllSortStatus(sortStatusBySheet);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, AnalysisResult>> getAnalysisResult(String sheetName) async {
    try {
      final result = await dataSource.getAnalysisResult(sheetName);
      return Right(result);
    } on FileSystemException catch (e) {
      return Left(FileNotFoundFailure(e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveAnalysisResult(
    String sheetName,
    AnalysisResult result,
  ) async {
    try {
      await dataSource.saveAnalysisResult(sheetName, result);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, SortProgressData>> getSortProgression(String sheetName) async {
    try {
      final progress = await dataSource.getSortProgression(sheetName);
      return Right(progress);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(e.e));
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<Either<Failure, void>> saveSortProgression(
    String sheetName,
    SortProgressData progress,
  ) async {
    try {
      await dataSource.saveSortProgression(sheetName, progress);
      return Right(null);
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e.e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.e));
    }
  }

  @override
  Future<void> clearAllData() async {
    return await dataSource.clearAllData();
  }
}
