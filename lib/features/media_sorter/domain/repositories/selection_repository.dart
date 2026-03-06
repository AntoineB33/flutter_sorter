import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';

abstract class SelectionRepository {
  Stream<String> get updateData;
  void init();
  Future<void> getAllLastSelected();
  Future<void> loadLastSelection();
  Future<Either<CacheFailure, void>> saveLastSelection();
  Future<Either<Failure, void>> saveAllLastSelected();
}