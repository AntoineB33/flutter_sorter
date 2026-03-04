import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trying_flutter/features/media_sorter/data/store/sort_status_cache.dart';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';


class SortSaveRepository extends ChangeNotifier {
  final FileSheetLocalDataSource dataSource;
  final SortStatusCache sortStatusCache;

  Failure? _syncFailure;
  Failure? get syncFailure => _syncFailure;

  SortSaveRepository(this.dataSource, this.sortStatusCache) {
    sortStatusCache.addListener(_onCacheUpdated);
  }

  void _onCacheUpdated() {
    _performBackgroundSave();
  }

  void _performBackgroundSave() {
    sortStatusCache.saveSortStatusExecutor.execute(() async {
      try {
        await dataSource.saveAllSortStatus(sortStatusCache.sortStatusBySheet);
        if (_syncFailure != null) {
          _syncFailure = null;
          notifyListeners(); 
        }
      } on FormatException catch (e) {
        _setFailure(CacheParsingFailure(e));
      } catch (e) {
        _setFailure(CacheFailure(e));
      }
    });
  }

  void _setFailure(Failure failure) {
    _syncFailure = failure;
    notifyListeners();
  }

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

  Future<void> saveAllSortStatus() async {
    sortStatusCache.saveSortStatusExecutor.execute(() async {
      await dataSource.saveAllSortStatus(sortStatusCache.sortStatusBySheet);
    });
  }
}