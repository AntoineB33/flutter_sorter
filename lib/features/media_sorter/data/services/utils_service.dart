import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/core/error/failures.dart';

class UrilsService {
  static bool isValidSheetName(String name) {
    return name.isNotEmpty && !name.contains(RegExp(r'[\\/:*?"<>|]'));
  }

  static Future<Either<Failure, T>> handleDataSourceCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      return Right(await call());
    } on CacheParsingException catch (e) {
      return Left(CacheParsingFailure(e));
    } on FileSystemException catch (e) {
      return Left(FileNotFoundFailure(e));
    } on CacheException catch (e) {
      return Left(CacheFailure(e));
    } catch (e) {
      // Catch generic unexpected errors
      return Left(CacheFailure(CacheException(e)));
    }
  }
}
